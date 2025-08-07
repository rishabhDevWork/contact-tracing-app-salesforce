# Contact Tracing App (Salesforce)

A Salesforce-based application to help track and manage potential exposure events during public health situations.  
It allows recording individuals, logging their contact interactions, and tracing possible exposure chains.

---

## ✨ Features

- **Individual Records**: Maintain details of people involved in the contact tracing process.
- **Contact Events**: Record interactions between two or more individuals.
- **Exposure Chain Reports**: Identify and display possible chains of exposure.
- **Search & Filter**: Quickly find records based on name, location, or date.
- **Lightning Components**: User-friendly interface built with Salesforce Lightning.

---

## 🛠 Requirements

- Salesforce Developer Org (or Sandbox)
- Access to **Developer Console** or **VS Code with Salesforce Extensions**
- Salesforce CLI (optional, for deployment)

---

## 🚀 Installation

### 1. Get the Code
Clone this repository to your local system:

```bash
git clone https://github.com/rishabhDevWorks/contact-tracing-app-salesforce.git
cd contact-tracing-salesforce
```

---

### 2. Deploy to Salesforce

#### Option A: Using Salesforce Developer Console
1. Open your Developer Org.
2. Go to **Setup → Developer Console**.
3. Create new **Apex Classes**, **Triggers**, and **Objects** as per the repository files.
4. Copy & paste the code from the respective files.

#### Option B: Using Salesforce CLI
1. Authenticate your org:
   ```bash
   sfdx force:auth:web:login -a ContactTracingOrg
   ```
2. Deploy the source:
   ```bash
   sfdx force:source:deploy -p force-app/main/default
   ```

---

### 3. Create Custom Objects

This app uses custom objects such as:
- **Person__c** – Stores individual details.
- **Contact_Event__c** – Stores information about an interaction between individuals.

You can create these via:
1. **Setup → Object Manager → New Object**
2. Match field names/types as given in the `objects` folder in the repo.

---

### 4. Assign Permissions
- Create a **Permission Set** named `Contact Tracing User`.
- Grant CRUD access to `Person__c` and `Contact_Event__c` objects.
- Assign the permission set to your test users.

---

## 📖 Usage

1. **Add Individuals**
   - Navigate to the **Persons** tab.
   - Click **New** and enter details.

2. **Log a Contact Event**
   - Go to the **Contact Events** tab.
   - Select individuals involved, date, time, and location.

3. **Trace Exposure**
   - Run the **Exposure Chain Report** to identify possible linked contacts.
   - Filter by date ranges and location.

---

## 🧪 Testing

- Unit tests are included in the `/apex-tests` folder.
- Run them in **Setup → Apex Test Execution**.
- Ensure at least 75% coverage for deployment to production.

---

## 📦 Deployment to Production

1. Validate in Sandbox.
2. Deploy using **Change Sets** or **Salesforce CLI**.
3. Re-run all tests before making the app live.

---
