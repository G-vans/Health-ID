# Decentralized Healthcare Identity Management Platform
# HealthID

This hackathon project **leveraged** the **TnID v2 GraphQL API** to create a **Decentralized Healthcare Identity Management Platform**. This platform **enabled** secure, privacy-respecting connections and data sharing between healthcare providers and patients using verifiable credentials.

## Key Components and Data Flow:

1. **Verifiable Data Registry**:
   - **Used** the TnID v2 API to manage identifiers, access requests, and verified data, supporting both **B2B** (company-to-company) and **B2C** (company-to-patient) interactions.
   - Secure storage and retrieval of identity credentials **enabled** providers and individuals to trust the system.

2. **Issuer (Healthcare Organization)**:
   - **Issued** verified credentials to patients via TnID, acting as a trusted provider of healthcare identity data.
   - **Used** TnID’s secure connection requests to establish verifiable connections with other healthcare organizations, insurance companies, or individual patients.

3. **Holder (Patient)**:
   - **Managed** personal credentials and **controlled** access to their medical data.
   - **Approved** or **denied** requests from healthcare providers or organizations to ensure privacy and consent over their data.

4. **Verifier (e.g., Hospitals, Insurance Providers)**:
   - **Validated** patient information using the TnID API to access relevant healthcare credentials securely.
   - **Ensured** accurate, trusted data flow for patient records, billing, and other healthcare transactions.

```
                        +---------------------------------------------------+
                        |   Verifiable Data Registry                        |
                        |   (e.g., TnID v2 API for Secure Connections)      |
                        +-------------------------+-------------------------+
                                              |
               +-------------------------------+-------------------------------+
               |                                                               |
       +-------v--------+                                            +---------v---------+
       |    Issuer      |                                            |      Verifier     |
       | (Healthcare    |                                            |  (e.g., Hospitals,|
       |  Organization  |                                            |  Insurance Co.)    |
       |  e.g., TnID Issues |                                        |  Validates Patient |
       |  Credential to   |                                         |  Data Using TnID    |
       |  Holder - Patient)                                        |    v2 API)           |
       +--------+--------+                                          +----------+----------+
                |                                                            ^
                |                                                            |
                v                                                            |
       +--------+--------+                                                   |
       |      Holder      |--------------------------------------------------+
       |   (Patient)      |
       |  Managed and     |
       | Shared Credential|
       +------------------+
```
## Implementation Steps:

1. **User Registration and Interface**:
   - **Developed** a registration system for patients and healthcare organizations.
   - **Allowed** companies and individuals to search and connect using TnID’s GraphQL API capabilities.

2. **Data Access and Privacy Controls**:
   - **Used** the TnID v2 API to enable secure B2B and B2C connections and data access requests.
   - Patients **could** view connection requests and selectively grant access to their health records.

3. **Data Exchange and Validation**:
   - **Transferred** medical data securely using the **TnID’s verifiable credential structure** for cross-organizational sharing.
   - Providers **verified** patient identities using TnID data for regulatory and privacy compliance.

## Conclusion

This decentralized identity management solution **leveraged** the **TnID v2 API** to create secure, verifiable, and privacy-respecting healthcare connections. By empowering patients with data control, this platform **addressed** privacy concerns in healthcare while enabling trusted, streamlined data sharing between organizations.

---
*Hackathon project developed using TnID v2 API*
