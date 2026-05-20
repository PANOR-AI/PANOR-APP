# PANOR — Patient-Augmented Network for Operational Reasoning
### *Agentic Clinical Intelligence Platform Powered by Google Antigravity*
---
**Submission Platform:** Google AI Seekho Hackathon 2026  
**Platform Focus:** Multilingual, Multimodal, Agentic Clinical Intelligence System  
**Core Technologies:** Google Antigravity, Vertex AI, Gemini, FastAPI, Flutter

---

## 🌟 Executive Summary (For Everyone)

**What is PANOR?**
Imagine entering a hospital where the system already knows your entire medical history across every clinic you've ever visited, understands your symptoms in any language you speak (Urdu, Punjabi, English), immediately warns the doctor if you are having a hidden emergency (like an impending cardiac event), alerts the pharmacist if your new prescription might clash with your old pills, and drafts the doctor’s post-consultation paperwork in under 3 seconds. 

That is **PANOR** (Patient-Augmented Network for Operational Reasoning).

In high-volume clinics where doctors only have 3 to 4 minutes per patient, it is impossible for a human to manually cross-reference historical reports, check for drug interactions, and write exhaustive clinical summaries. PANOR solves this by deploying **Seven Specialized AI Agents** coordinated by **Google Antigravity** to act as a 24/7 clinical co-pilot.

---

## 🛠️ The Core Problems We Solve

| Failure Mode | The Real-World Impact | How PANOR Fixes It |
| :--- | :--- | :--- |
| **Cross-Prescriber Blindness** | Doctors cannot see prescriptions from other clinics. Duplicate or conflicting drugs are prescribed, risking patient health. | **Drug Safety Agent (Agent 03)** automatically compares new prescriptions against all prior meds and hard-blocks conflicts. |
| **Context Collapse at Labs** | Labs receive test requests without clinical reasoning, delaying critical tests. | **Lab Coordination Agent (Agent 04)** attaches clinical intent and STAT/Urgent/Routine priority labels to every order. |
| **Consultation Time Squeeze** | Doctors process 60-100 patients daily. There is no time to type clinical SOAP notes. | **Verification Agent (Agent 07)** auto-generates structured clinical SOAP notes in under 3 seconds. |
| **Delayed Epidemiology Detection** | Disease clusters (like dengue or typhoid) are only noticed after hospitals are already overwhelmed. | **Epidemiology Agent (Agent 05)** aggregates anonymized symptoms to forecast outbreaks 48-72 hours in advance. |

---

## 🤖 The Seven AI Agents (Google Antigravity Orchestrated)

PANOR does not use a single "chatbot". Instead, it orchestrates **7 dedicated digital specialists**:

1. **Intake Intelligence Agent (Agent 01):** Translates patient inputs (voice recordings, prescription photos, PDF reports, or typed text in Roman Urdu/English) into a clean, standardized clinical summary.
2. **Clinical Reasoning Agent (Agent 02):** Analyzes symptoms against patient history, generates ranked diagnoses, and runs a silent emergency screening to trigger RED alerts for cardiac or respiratory crises.
3. **Drug Safety Guardian (Agent 03):** Runs a security check on every proposed medication against active prescriptions and chronic conditions. It blocks dangerous mixes and suggests safe alternatives.
4. **Laboratory Coordination Agent (Agent 04):** Translates diagnosis reasoning into clear lab orders with clinical reasoning and urgency labels (STAT, Urgent, Routine).
5. **Epidemiology Intelligence Agent (Agent 05):** Runs regional outbreak forecasting using anonymized spatial-temporal clustering.
6. **Follow-Up Monitoring Agent (Agent 06):** Schedules automated 48-hour recovery check-ins, tracks medication compliance, and alerts doctors if a patient deteriorates.
7. **Verification & Safety Agent (Agent 07):** Evaluates overall confidence thresholds, handles contradiction analysis, and generates the final clinical **SOAP Draft** (Subjective, Objective, Assessment, Plan) for the physician.

---

## 💻 Tech Stack (The Engine Rooms)

### Frontend (User Interface)
- **Framework:** Flutter (Cross-platform Web/Mobile)
- **Typography:** Google Fonts (Inter)
- **State Management & Network:** HTTP Services with JWT Bearer Token caching via Shared Preferences.

### Backend (Core Processing)
- **Framework:** FastAPI (Python 3.11+) - high-performance asynchronous runtime.
- **Database:** SQLite (local development with `aiosqlite`) & PostgreSQL (production-ready).
- **Security:** Raw `bcrypt` password encryption & JWT (JSON Web Tokens) Session Management.
- **Orchestration Layer:** Google Antigravity trace schemas + Vertex AI (Gemini Pro models).

---

## 📂 Modular System Documentation

To make the platform highly accessible for both medical administrators and software engineers, we have compiled dedicated, deep-dive documentation inside each module directory:

*   💾 **[FastAPI Backend & Database Manual](file:///d:/PANOR/PANOR-APP/backend/README.md)** — Explains SQLAlchemy, SQLite models, JWT token handling, local seeding, Swagger endpoints, and Docker deployment.
*   🎨 **[Flutter Web & Mobile Frontend Manual](file:///d:/PANOR/PANOR-APP/flutter_app/README.md)** — Explains typography properties, component architecture, the custom Clinical Precision theme, and local compiling.
*   🧠 **[Google Antigravity & YAML Configuration Manual](file:///d:/PANOR/PANOR-APP/antigravity/README.md)** — Details the 7-Agent Core workflow, fallback reasoning templates, and mock trace triggers.

---

## 🚀 Easy Step-by-Step Setup Guide (For Everyone)

Follow these simple, numbered steps to get both the **Backend API** and the **Frontend Web Portal** running on your local computer.

### Prerequisites
Make sure your computer has the following tools installed:
*   [Python](https://www.python.org/downloads/) (version 3.10 or higher)
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (to compile/run frontend screens)

---

### Step 1: Start the Backend API Server

1.  Open your terminal/command prompt and navigate to the backend folder:
    ```bash
    cd d:\PANOR\PANOR-APP\backend
    ```
2.  Create an isolated sandbox environment (this ensures clean installation):
    *   **Windows (Command Prompt / PowerShell):**
        ```cmd
        python -m venv venv
        ```
    *   **Mac / Linux:**
        ```bash
        python3 -m venv venv
        ```
3.  Activate the environment:
    *   **Windows (Command Prompt):**
        ```cmd
        .\venv\Scripts\activate.bat
        ```
    *   **Windows (PowerShell):**
        ```powershell
        .\venv\Scripts\activate.ps1
        ```
    *   **Mac / Linux:**
        ```bash
        source venv/bin/activate
        ```
    *(You should see `(venv)` appear on the left side of your prompt!)*
4.  Install the backend framework software packages:
    ```bash
    pip install -r requirements.txt
    ```
5.  Seed the database with pre-made clinical profiles (Rahul Sharma, Dr. Amit Verma):
    ```bash
    python seed_db.py
    ```
    *Success Message: `Database seeded with test users!`*
6.  Launch the live backend server:
    ```bash
    python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
    ```
    *Your API engine is now running at `http://localhost:8000`! View interactive schemas at `http://localhost:8000/docs`.*

---

### Step 2: Start the Frontend Web Portal

Open a **new, separate terminal window** and run these commands to start the user interface:

1.  Navigate to the frontend folder:
    ```bash
    cd d:\PANOR\PANOR-APP\flutter_app
    ```
2.  Fetch frontend library packages:
    ```bash
    flutter pub get
    ```
3.  Compile the release bundle:
    ```bash
    flutter build web --release
    ```
4.  Spin up a lightweight server to display the portal:
    ```bash
    python -m http.server 8081 --directory build/web
    ```
5.  Open your browser and navigate directly to the dashboard:
    **[http://localhost:8081](http://localhost:8081)**

---

## 🧑‍⚕️ How to Log In & Test (Interactive Demo Profiles)

Try logging in with these pre-seeded profiles to explore different operational perspectives:

| Role to Select | Pre-seeded Email | Password | What You Will Experience |
| :--- | :--- | :--- | :--- |
| **Doctor** | `doctor@panor.com` | `password` | **Clinical Copilot Dashboard**: Review differential diagnosis lists, safety warning triggers, edit pre-filled clinical SOAP notes, and sign entries digitally. |
| **Patient** | `patient@panor.com` | `password` | **Patient Portal**: Monitor dynamic vitals trends, access immunization ledger records, and submit voice/text symptoms using the Roman Urdu/English translation assistant. |
| **Lab Technician** | `lab@panor.com` | `password` | **STAT Pathology Queue**: Access incoming specimen accession lists, scan test barcodes, input troponin levels, and release verified records. |
| **Administrator** | `admin@panor.com` | `password` | **System Control Room**: View regional spatial epidemiology maps, track system latencies, and scan audit streams. |

---

## 🛡️ Clinical Safety Policies (Our Human-In-The-Loop Promise)

To ensure the highest standards of patient safety, PANOR implements three major guardrails:
*   **Emergency Banners**: Critical vital alerts (e.g., HR > 130 bpm) or high-risk patient terms trigger immediate red triage notifications, halting automated queues.
*   **Safety Lockouts**: Drug safety warning conflicts must be manually reviewed and clinically overridden by a certified physician before confirmation.
*   **Immutable Draft Ledgers**: Generated SOAP notes remain as drafts and must receive a direct physician digital signature before commit.

