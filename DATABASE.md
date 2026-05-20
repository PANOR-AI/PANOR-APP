# 💾 PANOR Database — SQLite Schema & Ledger Manual

Welcome to the data layer documentation of **PANOR (Patient-Augmented Network for Operational Reasoning)**. This manual provides a complete, easy-to-read overview of the SQLite database (`panor.db`), database schemas, model mappings, and step-by-step instructions so that both technical developers and non-technical administrators can understand and manage the platform's data.

---

## 📂 Data Architecture Overview

PANOR uses a local **SQLite** database for high-performance, asynchronous development. It implements **SQLAlchemy (ORM)** in the FastAPI backend to interface with the database.

Upon starting the backend, the schema is initialized dynamically:
- Primary location: `backend/panor.db` (created automatically on startup).
- Database ORM Models directory: `backend/app/models/`
- Data Seed script: `backend/seed_db.py`

---

## 📊 Database Tables & Schemas

The database contains a central table `users` which holds all authenticating credentials, demographic profiles, and role-specific configurations for **Patients, Doctors, Lab Techs, and Admins**.

### Table: `users`
This is the primary clinical accounts ledger.

| Column Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY`, `AUTOINCREMENT` | Unique numeric identifier for the account. |
| `email` | `VARCHAR` | `UNIQUE`, `INDEX`, `NOT NULL` | The user's credential login email address. |
| `hashed_password` | `VARCHAR` | `NOT NULL` | Cryptographically hashed password salted with `bcrypt`. |
| `role` | `VARCHAR` | `NOT NULL` | Operational role: `patient`, `doctor`, `lab`, or `admin`. |
| `full_name` | `VARCHAR` | `NOT NULL` | Legal full name displayed across workspaces. |
| `is_active` | `BOOLEAN` | `DEFAULT True` | Account status flag. |
| `profile_data` | `JSON` | `NULLABLE` | Semi-structured data (vitals, chronic illnesses, specialties, queues). |

---

## 🧑‍⚕️ Pre-seeded Demonstration Accounts

When you run `python seed_db.py` in the backend folder, the database is populated with highly authentic clinical entities designed for instant hackathon demonstrations:

### 1. Doctor Profile
- **Name:** Dr. Amit Verma 🩺
- **Email:** `doctor@panor.com`
- **Password:** `password`
- **Profile Data Details:** Specialty: Cardiology, Active patients queue: Rahul Sharma, Priya Patel.

### 2. Patient Profile
- **Name:** Rahul Sharma 🧑
- **Email:** `patient@panor.com`
- **Password:** `password`
- **Profile Data Details:** Age: 34, Blood Group: O Positive, Active vitals history (BP: 120/80, HR: 72 bpm, SpO2: 99%), Chronic condition: Hypertension.

### 3. Lab Technician Profile
- **Name:** Lab Specialist 🔬
- **Email:** `lab@panor.com`
- **Password:** `password`
- **Profile Data Details:** Specialization: Clinical Pathology, Specimen logs queue.

### 4. Admin Profile
- **Name:** Head Administrator 👑
- **Email:** `admin@panor.com`
- **Password:** `password`
- **Profile Data Details:** Access Level: Tier 1 Regional Health Director, telemetry parameters.

---

## ⚡ Zero-to-Live Database Initialization

Follow these simple steps to seed or reset the database:

### 1. Reset / Clear Database (Optional)
If you want to clear old records and start completely fresh, simply delete the `panor.db` file from the `backend/` folder. A fresh, empty database will be created on the next server start.

### 2. Run Database Seeding
Open your terminal in the backend directory and execute:
```bash
cd d:\PANOR\PANOR-APP\backend
.\venv\Scripts\activate
python seed_db.py
```
Upon success, it will print:
`Database seeded with test users!`

---

## 🔍 How to Inspect the Database (For Everyone)

You do not need to be a software engineer to inspect and view the database! Follow these easy steps to view the structured data on your screen:

### Option A: Interactive Browser Tools (Recommended)
1. Download a free tool called **[DB Browser for SQLite](https://sqlitebrowser.org/)**.
2. Install and launch the program.
3. Click **"Open Database"** and select the file: `d:\PANOR\PANOR-APP\backend\panor.db`.
4. Click the **"Browse Data"** tab. You can now view all seeded users, passwords, and vitals in a beautiful spreadsheet format!

### Option B: Swagger API Portal
1. Make sure your backend server is running (`python -m uvicorn app.main:app`).
2. Open your browser and go to: **[http://localhost:8000/docs](http://localhost:8000/docs)**.
3. Scroll to the authentication endpoints, log in, and request patient schemas directly from your browser!
