# HealthID: Your AI-Powered Global Health Wallet 🌍🏥

**OpenAI Open Model Hackathon Submission - Built with gpt-oss-20b**

## 🎯 What This Project Does

HealthID transforms your smartphone into a **private medical AI assistant** that works 100% offline. Imagine traveling from Kenya to Mumbai for work, falling ill, and having an AI that instantly analyzes your medical history to give doctors critical insights - all without your health data ever touching the cloud.

**The Innovation:** We use **gpt-oss-20b running locally** to analyze years of lab results, detect health patterns humans miss, and provide personalized travel health advisories. Your medical data stays on YOUR device, but gets the intelligence of advanced AI reasoning.

## 🔥 Key Features Powered by gpt-oss-20b

- **🧠 Pattern Recognition**: Analyzes multiple lab tests over time to spot early disease indicators
- **⚠️ Smart Alerts**: Detects concerning trends (e.g., gradual glucose increase suggesting pre-diabetes)
- **✈️ Travel Health Advisor**: Combines your health profile with destination climate/disease data
- **🔒 Privacy-First**: All AI processing happens locally - zero cloud dependency
- **🌐 Works Offline**: Perfect for areas with unreliable internet (serves 2B+ people globally)

---

## 📋 Table of Contents

- [🚀 Quick Setup for Judges](#-quick-setup-for-judges)
- [🧪 Testing the gpt-oss Integration](#-testing-the-gpt-oss-integration)
- [⚙️ Architecture Overview](#️-architecture-overview)
- [🎯 Hackathon Categories](#-hackathon-categories)
- [📊 Sample Data & Expected Results](#-sample-data--expected-results)
- [🔧 Troubleshooting](#-troubleshooting)
- [📚 Additional Documentation](#-additional-documentation)

---

## 🚀 Quick Setup for Judges

### Prerequisites
- **16GB+ RAM** (for gpt-oss-20b) - or use gpt-oss-7b for lower specs
- Ruby 3.0+, Rails 7, PostgreSQL
- [Ollama](https://ollama.com) for serving gpt-oss locally

### 1-Minute Setup
```bash
# Install gpt-oss model (this is the key!)
curl -fsSL https://ollama.com/install.sh | sh
ollama pull gpt-oss:20b

# Clone and setup Rails app
git clone [your-repo-url]
cd Health-ID
bundle install
rails db:create db:migrate db:seed

# Start services (separate terminals)
ollama serve                    # Terminal 1: Serves gpt-oss-20b locally
rails server                    # Terminal 2: Rails app on localhost:3000
```

**🎯 Ready to test!** Visit http://localhost:3000

---

## 🧪 Testing the gpt-oss Integration

### Core Demo Flow
1. **Sign up** as Patient: `test@example.com` / `password123`
2. **Add lab results** via Companies Dashboard (sign up as Company first)
3. **View results**: Patient Dashboard → "My Lab Results"
4. **🤖 Test AI**: Click "Run AI Analysis" button
   - Watch Terminal 1 for gpt-oss-20b processing
   - AI analyzes patterns across all your lab data
   - Generates risk assessment + recommendations

### Offline Test
1. **Disconnect WiFi** while on the lab results page
2. Click "Run AI Analysis" - it should still work!
3. This proves gpt-oss-20b runs completely local

### Sample Test Data That Triggers AI Insights
```
Test 1: Glucose = 110 mg/dL (Reference: 70-99) - SLIGHTLY HIGH
Test 2: Cholesterol = 220 mg/dL (Reference: <200) - HIGH  
Test 3: HbA1c = 5.8% (Reference: <5.7) - PRE-DIABETIC RANGE

Expected AI Output: "Pattern suggests metabolic syndrome risk..."
```

---

## ⚙️ Architecture Overview

```
┌─────────────────────────────────────────────┐
│                Your Device                   │
├─────────────────┬───────────────────────────┤
│   Rails App     │     gpt-oss-20b           │
│   (Port 3000)   │     (via Ollama)          │
│                 │     (Port 11434)          │
│   • Lab Storage │     • Medical Reasoning   │
│   • UI/UX       │     • Pattern Detection   │
│   • Auth        │     • Risk Assessment     │
└─────────────────┴───────────────────────────┘
           ▲                    ▲
           │                    │
      No Internet          No Internet
      Required!            Required!
```

**Key Innovation**: The Rails app sends medical data to gpt-oss-20b running locally via Ollama's API. No external API calls, no cloud services, no data leakage.

---

## 🎯 Hackathon Categories

**🌍 For Humanity**: Serves 2+ billion people in areas with unreliable internet by providing AI-powered medical insights completely offline - democratizing healthcare intelligence for underserved populations.

**🤖 Best Local Agent**: gpt-oss-20b runs 100% on-device via Ollama, analyzing years of medical data to detect health patterns and generate travel advisories without any cloud dependency.

---

## 📊 Sample Data & Expected Results

### Test Case 1: Pre-Diabetes Detection
```
Input Lab Results:
- Glucose: 110 mg/dL (normal: 70-99)
- HbA1c: 5.8% (normal: <5.7)
- Weight gained 10lbs in 6 months

Expected gpt-oss Output:
- Risk Level: MEDIUM
- Detected Condition: "Pre-diabetes risk"
- Recommendation: "Monitor carbohydrate intake, increase physical activity"
```

### Test Case 2: Travel Advisory
```
Patient Profile: Pre-diabetic with elevated cholesterol
Destination: Mumbai, India (hot climate, dengue risk)

Expected gpt-oss Output:
- Health Risk: "Heat stress may affect glucose levels"
- Precaution: "Increase hydration, monitor blood sugar more frequently"
- Emergency Prep: "Pack extra diabetic supplies"
```

---

## 🔧 Troubleshooting

### If Ollama Crashes (Common on 8GB RAM)
```bash
# Use smaller model
ollama pull gpt-oss:7b

# Update health_reasoning_service.rb line 22:
model: 'gpt-oss:7b'  # instead of gpt-oss:20b
```

### If AI Analysis Hangs
```bash
# Check Ollama is running
curl http://localhost:11434/api/tags

# Restart Ollama
pkill ollama
ollama serve
```

### Memory Issues
- **Minimum**: 8GB RAM (use gpt-oss:7b)
- **Recommended**: 16GB RAM (use gpt-oss:20b)
- **Optimal**: 32GB RAM (smooth performance)

---

## 📚 Additional Documentation

- **[README_HACKATHON.md](README_HACKATHON.md)**: Full hackathon submission details
- **[README_ORIGINAL.md](README_ORIGINAL.md)**: Original project technical documentation  
- **Code Structure**: 
  - `app/services/health_reasoning_service.rb` - Main gpt-oss integration
  - `health_reasoning_agent.py` - Python AI service
  - `app/models/ai_analysis.rb` - Stores AI reasoning results

---

## 🏆 Why This Matters

Healthcare inequality affects billions. By making advanced AI work offline, we can serve populations that Silicon Valley typically ignores. A farmer in rural Kenya can get the same AI-powered health insights as someone in San Francisco - no internet required.

**This isn't just an app - it's healthcare infrastructure for the next billion users.**

---

*Built with ❤️ for the OpenAI Open Model Hackathon. Powered by gpt-oss-20b.*