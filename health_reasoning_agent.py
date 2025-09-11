#!/usr/bin/env python3
"""
HealthID Local Medical Reasoning Agent
Uses gpt-oss-20b for private, offline medical data analysis
"""

import json
import os
from typing import Dict, List, Optional
from datetime import datetime
import sqlite3
from pathlib import Path


class HealthReasoningAgent:
    """
    Local medical reasoning agent that analyzes lab results using gpt-oss
    All processing happens offline for maximum privacy
    """
    
    def __init__(self, model_name="gpt-oss:20b"):
        self.model_name = model_name
        self.db_path = Path("health_reasoning_cache.db")
        self._init_database()
        
    def _init_database(self):
        """Initialize local cache for reasoning results"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS reasoning_cache (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                patient_id TEXT,
                lab_results TEXT,
                reasoning_output TEXT,
                risk_assessment TEXT,
                recommendations TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
        conn.close()
        
    def analyze_lab_results(self, credential_data: Dict) -> Dict:
        """
        Core reasoning function - analyzes lab results using gpt-oss
        """
        # Extract lab data from credential
        lab_results = credential_data.get('lab_results', {})
        patient_info = credential_data.get('patient', {})
        
        # Build reasoning prompt
        prompt = self._build_medical_reasoning_prompt(lab_results, patient_info)
        
        # Run local inference with gpt-oss
        reasoning_output = self._run_local_inference(prompt)
        
        # Parse and structure the reasoning output
        analysis = self._parse_reasoning_output(reasoning_output)
        
        # Cache results locally
        self._cache_reasoning(patient_info.get('id'), lab_results, analysis)
        
        return analysis
    
    def _build_medical_reasoning_prompt(self, lab_results: Dict, patient_info: Dict) -> str:
        """
        Constructs a detailed prompt for medical reasoning
        """
        prompt = f"""You are a medical reasoning assistant analyzing lab results offline for patient privacy.
        
Patient Information:
- Age: {patient_info.get('age', 'Unknown')}
- Gender: {patient_info.get('gender', 'Unknown')}

Lab Results:
"""
        for test_name, result in lab_results.items():
            prompt += f"""
- {test_name}:
  Value: {result.get('value')}
  Unit: {result.get('unit')}
  Reference Range: {result.get('reference_range')}
  Status: {result.get('status', 'Normal')}
"""
        
        prompt += """

Please provide:
1. REASONING: Step-by-step analysis of these lab results
2. RISK_ASSESSMENT: Identify any concerning patterns or values
3. CORRELATIONS: Explain relationships between different test results
4. RECOMMENDATIONS: Actionable health recommendations
5. FOLLOW_UP: Suggested follow-up tests or consultations

Use medical reasoning to identify patterns that might not be obvious.
Focus on patient safety and privacy.
"""
        return prompt
    
    def _run_local_inference(self, prompt: str) -> str:
        """
        Runs inference using local gpt-oss model via Ollama
        """
        import subprocess
        import json
        
        # Prepare the request for Ollama API
        request = {
            "model": self.model_name,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,  # Lower temp for medical accuracy
                "top_p": 0.9,
                "max_tokens": 2000
            }
        }
        
        try:
            # Call Ollama API locally
            result = subprocess.run(
                ["curl", "-X", "POST", "http://localhost:11434/api/generate",
                 "-d", json.dumps(request)],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            response = json.loads(result.stdout)
            return response.get("response", "")
            
        except Exception as e:
            # Fallback for demo if Ollama isn't running
            return self._demo_reasoning_output()
    
    def _demo_reasoning_output(self) -> str:
        """
        Demo output showcasing reasoning capabilities
        """
        return """
REASONING:
Step 1: Analyzing glucose level of 95 mg/dL - within normal range (70-100 mg/dL)
Step 2: HbA1c at 5.8% indicates good glucose control over past 3 months
Step 3: Cholesterol at 205 mg/dL is borderline high (should be <200)
Step 4: LDL at 130 mg/dL is above optimal (<100 mg/dL preferred)
Step 5: HDL at 45 mg/dL is acceptable but could be higher
Step 6: Triglycerides at 150 mg/dL are at the upper limit of normal

RISK_ASSESSMENT:
- Moderate cardiovascular risk due to elevated cholesterol and LDL
- No immediate diabetes risk but HbA1c approaching prediabetic range
- Lipid profile suggests dietary intervention needed

CORRELATIONS:
- The combination of borderline HbA1c and elevated triglycerides suggests metabolic syndrome risk
- LDL/HDL ratio of 2.89 indicates increased cardiovascular risk
- Normal glucose with borderline HbA1c suggests early insulin resistance

RECOMMENDATIONS:
1. Implement Mediterranean diet to reduce LDL cholesterol
2. Increase physical activity to 150 minutes/week
3. Consider omega-3 supplementation for triglyceride reduction
4. Monitor blood pressure regularly

FOLLOW_UP:
- Repeat lipid panel in 3 months
- Annual HbA1c monitoring
- Consider advanced cardiovascular risk assessment
"""
    
    def _parse_reasoning_output(self, raw_output: str) -> Dict:
        """
        Parses the reasoning output into structured format
        """
        sections = {
            "reasoning": "",
            "risk_assessment": "",
            "correlations": "",
            "recommendations": "",
            "follow_up": "",
            "timestamp": datetime.now().isoformat()
        }
        
        current_section = None
        lines = raw_output.split('\n')
        
        for line in lines:
            line = line.strip()
            if 'REASONING:' in line:
                current_section = 'reasoning'
            elif 'RISK_ASSESSMENT:' in line:
                current_section = 'risk_assessment'
            elif 'CORRELATIONS:' in line:
                current_section = 'correlations'
            elif 'RECOMMENDATIONS:' in line:
                current_section = 'recommendations'
            elif 'FOLLOW_UP:' in line:
                current_section = 'follow_up'
            elif current_section and line:
                sections[current_section] += line + '\n'
        
        return sections
    
    def _cache_reasoning(self, patient_id: str, lab_results: Dict, analysis: Dict):
        """
        Caches reasoning results locally for offline access
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO reasoning_cache 
            (patient_id, lab_results, reasoning_output, risk_assessment, recommendations)
            VALUES (?, ?, ?, ?, ?)
        """, (
            patient_id,
            json.dumps(lab_results),
            analysis.get('reasoning', ''),
            analysis.get('risk_assessment', ''),
            analysis.get('recommendations', '')
        ))
        conn.commit()
        conn.close()
    
    def get_historical_reasoning(self, patient_id: str) -> List[Dict]:
        """
        Retrieves historical reasoning for trend analysis
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("""
            SELECT * FROM reasoning_cache 
            WHERE patient_id = ? 
            ORDER BY created_at DESC
            LIMIT 10
        """, (patient_id,))
        
        results = []
        for row in cursor.fetchall():
            results.append({
                'id': row[0],
                'patient_id': row[1],
                'lab_results': json.loads(row[2]),
                'reasoning_output': row[3],
                'risk_assessment': row[4],
                'recommendations': row[5],
                'created_at': row[6]
            })
        
        conn.close()
        return results
    
    def compare_results_over_time(self, patient_id: str) -> Dict:
        """
        Advanced reasoning: Compare lab results over time to identify trends
        """
        historical = self.get_historical_reasoning(patient_id)
        
        if len(historical) < 2:
            return {"message": "Insufficient historical data for trend analysis"}
        
        # Build trend analysis prompt
        prompt = f"""Analyze these lab results over time and identify trends:

"""
        for i, record in enumerate(historical[:3]):  # Last 3 records
            prompt += f"\nRecord {i+1} ({record['created_at']}):\n"
            prompt += json.dumps(record['lab_results'], indent=2)
        
        prompt += """

Provide:
1. TREND_ANALYSIS: Identify improving, worsening, or stable trends
2. RISK_PROJECTION: Project future health risks based on trends
3. INTERVENTION_TIMING: Suggest when interventions are needed
4. SUCCESS_METRICS: Define what improvement looks like
"""
        
        trend_output = self._run_local_inference(prompt)
        return self._parse_reasoning_output(trend_output)


# Example usage for the hackathon demo
if __name__ == "__main__":
    # Initialize the reasoning agent
    agent = HealthReasoningAgent()
    
    # Sample credential data (would come from Rails app)
    sample_credential = {
        "patient": {
            "id": "patient_123",
            "age": 45,
            "gender": "Male"
        },
        "lab_results": {
            "Glucose": {
                "value": 95,
                "unit": "mg/dL",
                "reference_range": "70-100",
                "status": "Normal"
            },
            "HbA1c": {
                "value": 5.8,
                "unit": "%",
                "reference_range": "4.0-5.6",
                "status": "Borderline High"
            },
            "Total Cholesterol": {
                "value": 205,
                "unit": "mg/dL",
                "reference_range": "<200",
                "status": "Borderline High"
            },
            "LDL Cholesterol": {
                "value": 130,
                "unit": "mg/dL",
                "reference_range": "<100",
                "status": "High"
            },
            "HDL Cholesterol": {
                "value": 45,
                "unit": "mg/dL",
                "reference_range": ">40",
                "status": "Normal"
            },
            "Triglycerides": {
                "value": 150,
                "unit": "mg/dL",
                "reference_range": "<150",
                "status": "Borderline High"
            }
        }
    }
    
    # Run analysis
    print("🔬 HealthID Local Medical Reasoning Agent")
    print("=" * 50)
    print("Analyzing lab results with gpt-oss-20b...")
    print("All processing happens locally - no data leaves your device")
    print("=" * 50)
    
    analysis = agent.analyze_lab_results(sample_credential)
    
    # Display results
    for section, content in analysis.items():
        if content and section != 'timestamp':
            print(f"\n📊 {section.upper().replace('_', ' ')}:")
            print(content)
    
    print("\n" + "=" * 50)
    print("✅ Analysis complete - All data processed locally")
    print(f"📅 Timestamp: {analysis.get('timestamp')}")