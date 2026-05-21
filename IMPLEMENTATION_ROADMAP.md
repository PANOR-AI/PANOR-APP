# PANOR Implementation Roadmap - 4-Week Sprint to Hackathon Submission

## Timeline: 4 Weeks to APK Submission

---

## WEEK 1: Foundation & Antigravity Integration

### Monday-Tuesday: Backend Architecture Setup

**Developer Focus**: Backend Developer

**Deliverables**:
- [ ] FastAPI project structure finalized
- [ ] Database migrations deployed (PostgreSQL)
- [ ] Firestore collections initialized
- [ ] Environment configuration (.env files)

**Tasks**:

```bash
# 1. Backend scaffold
mkdir -p backend/app/{api/v1,services,models,core,utils}
cd backend
python -m venv venv
pip install -r requirements.txt

# 2. Database setup
alembic upgrade head

# 3. Firebase initialization
gcloud firestore init
gcloud auth application-default login
```

**Files to Create**:
- [ ] `backend/app/core/config.py` - Environment variables
- [ ] `backend/app/database.py` - DB connections (PostgreSQL + Firestore)
- [ ] `backend/alembic/versions/001_initial_schema.py` - Migration

### Wednesday-Thursday: Antigravity Agent Integration

**Developer Focus**: AI Developer + Backend Developer

**Deliverables**:
- [ ] Antigravity orchestrator service fully integrated
- [ ] All 7 agent YAML configs finalized
- [ ] Gemini API integration ready
- [ ] Mock agent responses working

**Tasks**:

1. **Create Agent Prompts** (Already documented in `PANOR_IMPLEMENTATION_SPEC.md`)
   - [ ] Refine A1 intake prompt (multimodal)
   - [ ] Refine A2 clinical reasoning (Gemini integration)
   - [ ] Refine A3 drug safety (hard-block logic)
   - [ ] Finalize A4-A7 agent specs

2. **Implement Orchestrator Service**
```python
# backend/app/services/antigravity_orchestrator.py
# Already created - refine and test

from app.services.antigravity_orchestrator import AntigravityOrchestrator

orchestrator = AntigravityOrchestrator()
result = await orchestrator.execute_pipeline(
    patient_id="PAN-NADRA-12345678",
    intake_data={...}
)
```

3. **Gemini API Integration**
```python
# backend/app/services/gemini_service.py (NEW)

import google.generativeai as genai

class GeminiService:
    def __init__(self, api_key: str):
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-pro')
    
    async def call_clinical_agent(self, agent_id: str, prompt: str):
        response = await self.model.generate_content_async(prompt)
        return response.text
```

4. **Test Agent Pipeline**
```bash
python -m pytest tests/test_antigravity_pipeline.py -v
```

### Friday: API Endpoints Setup

**Deliverables**:
- [ ] Core API routes scaffolded
- [ ] Authentication middleware working
- [ ] Health check endpoints functional

**Files to Create**:
- [ ] `backend/app/api/v1/patients.py` - Patient endpoints
- [ ] `backend/app/api/v1/consultations.py` - AI consultation endpoint
- [ ] `backend/app/api/v1/auth.py` - Auth endpoints
- [ ] `backend/app/api/v1/health.py` - Health checks

**Example Endpoint**:
```python
# backend/app/api/v1/consultations.py

@router.post("/patients/{patient_id}/ai-consultation")
async def ai_consultation(
    patient_id: str,
    request: ConsultationRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Patient initiates AI consultation
    Triggers Antigravity pipeline
    """
    orchestrator = AntigravityOrchestrator()
    result = await orchestrator.execute_pipeline(
        patient_id=patient_id,
        intake_data=request.dict()
    )
    return result
```

---

## WEEK 2: Mobile App Foundation & API Integration

### Monday-Wednesday: Flutter App Setup

**Developer Focus**: Mobile Developer

**Deliverables**:
- [ ] Flutter project structure (clean architecture)
- [ ] Splash screen + onboarding complete
- [ ] Authentication screens ready
- [ ] State management (Riverpod) configured

**Tasks**:

```bash
# 1. Flutter project setup
flutter create panor_app
cd panor_app

# 2. Add dependencies
flutter pub add riverpod flutter_riverpod
flutter pub add freezed_annotation build_runner
flutter pub add go_router
flutter pub add hive hive_flutter
flutter pub add firebase_core cloud_firestore
flutter pub add dio
flutter pub add logger

# 3. Run app
flutter run
```

**Screens to Create**:
- [ ] `lib/features/shared/splash_screen.dart`
- [ ] `lib/features/shared/onboarding_screen.dart`
- [ ] `lib/features/auth/login_screen.dart`
- [ ] `lib/features/auth/role_selection_screen.dart`

**State Management Setup**:
```dart
// lib/providers/app_providers.dart

final apiClientProvider = Provider((ref) => ApiClient());

final authProvider = StateNotifierProvider((ref) =>
  AuthNotifier(ref.watch(apiClientProvider))
);

final userProvider = FutureProvider((ref) async {
  return await ref.watch(authProvider).getUser();
});
```

### Thursday-Friday: API Integration & Dashboards

**Deliverables**:
- [ ] Patient dashboard screen complete
- [ ] Doctor dashboard screen complete
- [ ] Lab dashboard screen complete
- [ ] Admin dashboard skeleton ready
- [ ] API client working

**Dashboard Screens**:

```dart
// lib/features/patient/patient_dashboard_screen.dart

class PatientDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientProvider);
    
    return patient.when(
      data: (data) => Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Patient Info Card
              PatientInfoCard(patient: data.patient),
              
              // Quick Actions
              QuickActionsRow(),
              
              // Current Medications
              CurrentMedicationsSection(),
              
              // Medical Timeline Preview
              MedicalTimelinePreview(),
            ],
          ),
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, st) => ErrorWidget(error: err),
    );
  }
}
```

**Dashboard Layouts** (from design image):
- Patient: Info card, medications, appointments, medical history
- Doctor: Patient list, emergency alerts, consultation schedule
- Lab: Orders queue, test specs, result entry
- Admin: Analytics, user management, emergency monitor

---

## WEEK 3: Feature Implementation & AI Integration

### Monday-Wednesday: AI Chat + Medical Timeline

**Developer Focus**: Mobile Developer + Backend Developer

**Deliverables**:
- [ ] AI consultation chat working end-to-end
- [ ] Medical timeline visualization complete
- [ ] Document upload (PDF + camera OCR) working
- [ ] Offline sync engine functional

**Patient AI Consultation Flow**:

```dart
// lib/features/patient/ai_consultation_screen.dart

void _sendMessage() async {
  final userInput = _messageController.text;
  
  // 1. Add to UI immediately (optimistic update)
  ref.read(chatMessagesProvider.notifier).state += [
    ChatMessage(text: userInput, isFromUser: true)
  ];
  
  try {
    // 2. Call backend AI pipeline
    final response = await ref.read(apiClientProvider).post(
      '/api/v1/patients/${patientId}/ai-consultation',
      data: {
        'input': userInput,
        'language': 'urdu',  // Auto-detect
        'modality': 'text'
      }
    );
    
    // 3. Add AI response to chat
    ref.read(chatMessagesProvider.notifier).state += [
      ChatMessage(
        text: response['ai_response'],
        isFromUser: false,
        recommendations: response['recommendations'],
        confidence: response['confidence_score']
      )
    ];
    
    // 4. Store in local cache for offline access
    await ref.read(localStorageProvider).saveChatMessage(
      response['pipeline_id'],
      response
    );
    
  } catch (e) {
    // Show error and let retry
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}'))
    );
  }
}
```

**Medical Timeline Widget**:

```dart
class MedicalTimelineWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(medicalTimelineProvider);
    
    return timeline.when(
      data: (events) => ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return TimelineEventCard(
            title: event.eventType,  // "Consultation", "Lab Result"
            date: event.date,
            icon: _getIconForType(event.eventType),
            description: event.description,
            onTap: () => showEventDetails(event),
          );
        },
      ),
      loading: () => LoadingWidget(),
      error: (err, st) => ErrorWidget(error: err),
    );
  }
}
```

**Document Upload with OCR**:

```dart
void _uploadMedicalRecord() async {
  final pickedFile = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'png'],
  );
  
  if (pickedFile == null) return;
  
  // 1. Upload to backend
  final file = File(pickedFile.files.single.path!);
  
  final response = await ApiClient().uploadFile(
    '/api/v1/patients/$patientId/medical-records',
    file,
    fileName: 'old_records'
  );
  
  // 2. Backend triggers OCR via Google Document AI
  // 3. Results extracted and added to medical timeline
  // 4. Patient notified of successful upload
}
```

### Thursday-Friday: Doctor & Lab Interfaces

**Deliverables**:
- [ ] Doctor patient list with search/filter
- [ ] Doctor patient detail view (full record)
- [ ] Lab orders queue display
- [ ] Lab result entry form

**Doctor View Patient Detail**:

```dart
class DoctorPatientDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientDetail = ref.watch(patientDetailProvider(patientId));
    
    return patientDetail.when(
      data: (patient) => Scaffold(
        appBar: AppBar(title: Text(patient.fullName)),
        body: TabBar(
          tabs: [
            Tab(label: 'Demographics'),
            Tab(label: 'Medical History'),
            Tab(label: 'Current Meds'),
            Tab(label: 'Lab Results'),
          ],
          children: [
            DemographicsTab(patient: patient),
            MedicalHistoryTab(patientId: patientId),
            CurrentMedsTab(patientId: patientId),
            LabResultsTab(patientId: patientId),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          label: 'Order Labs',
          onPressed: () => navigateToOrderLabs(patientId),
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, st) => ErrorWidget(error: err),
    );
  }
}
```

**Lab Orders Queue**:

```dart
class LabOrdersQueueScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labOrders = ref.watch(labOrdersProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Lab Orders')),
      body: labOrders.when(
        data: (orders) {
          final pending = orders.where((o) => o.status == 'pending').toList();
          final completed = orders.where((o) => o.status == 'completed').toList();
          
          return ListView(
            children: [
              SectionHeader('Pending (${pending.length})'),
              ...pending.map((order) => LabOrderCard(
                order: order,
                onCollect: () => markAsCollected(order.id),
              )),
              SizedBox(height: 16),
              SectionHeader('Completed'),
              ...completed.map((order) => LabOrderCard(order: order)),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorWidget(error: err),
      ),
    );
  }
}
```

---

## WEEK 4: QA, Optimization & APK Build

### Monday-Tuesday: Testing & Bug Fixing

**Deliverables**:
- [ ] All major screens tested
- [ ] Critical bugs fixed
- [ ] Performance optimized
- [ ] No crashes on stress test

**Test Plan**:

```bash
# Backend tests
pytest tests/test_antigravity_pipeline.py -v
pytest tests/test_api_endpoints.py -v

# Flutter tests
flutter test

# UI regression testing
flutter test integration_test/
```

**Stress Testing**:

```bash
# 100 concurrent API requests
ab -n 100 -c 10 http://localhost:8000/api/v1/health

# Memory profiling
flutter run --profile
```

### Wednesday: Optimization & Performance Tuning

**Deliverables**:
- [ ] APK size < 100 MB
- [ ] Cold start < 3 seconds
- [ ] Medical timeline query < 500ms
- [ ] AI pipeline < 10 seconds

**Optimizations**:

```dart
// 1. Image lazy-loading
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => SkeletonLoader(),
  cacheManager: CacheManager.instance,
)

// 2. ListView virtualization
ListView.builder(itemCount: 1000)

// 3. Reduce APK size
flutter build apk --release --obfuscate --split-per-abi
```

### Thursday-Friday: Final Build & Submission

**Deliverables**:
- [ ] Production APK built and tested
- [ ] README.md with setup instructions
- [ ] User manual (Urdu + English)
- [ ] Demo video (< 3 minutes)

**APK Build**:

```bash
# 1. Set app version
# android/app/build.gradle: versionCode = 1, versionName = "1.0.0"

# 2. Create keystore
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias panor

# 3. Build APK
flutter build apk --release --obfuscate --split-per-abi

# 4. APK location
# build/app/outputs/apk/release/app-release.apk (multiple ABIs)
```

**Submission Package**:

```
PANOR_HACKATHON_SUBMISSION/
├── panor-app-arm64-v8a.apk      # Main APK for 64-bit
├── panor-app-armeabi-v7a.apk    # 32-bit fallback
├── README.md                      # Setup & run instructions
├── USER_MANUAL_EN.pdf            # English manual
├── USER_MANUAL_UR.pdf            # Urdu manual
├── DEMO_VIDEO.mp4                # 2-3 minute demo
├── ARCHITECTURE.md               # Technical documentation
├── SOURCE_CODE/                  # GitHub link or zip
│   ├── backend/
│   ├── flutter_app/
│   ├── antigravity/
│   └── DATABASE_SCHEMA.md
└── DEPLOYMENT_GUIDE.md
```

---

## Critical Milestones & Checkpoints

### Week 1 End
- [ ] Backend API responding
- [ ] Database migrations successful
- [ ] Antigravity orchestrator executing mock pipeline
- [ ] Health check endpoints live

### Week 2 End
- [ ] Flutter app installs and runs
- [ ] Authentication working
- [ ] All 4 dashboards visible (patient, doctor, lab, admin)
- [ ] API integration tested

### Week 3 End
- [ ] Complete end-to-end AI consultation flow
- [ ] Medical timeline visualization working
- [ ] Document upload + OCR functional
- [ ] Offline sync engine tested

### Week 4 End
- [ ] APK built and installable
- [ ] All tests passing
- [ ] Zero critical bugs
- [ ] Ready for submission

---

## Developer Role Assignments

```
Frontend Developer
├── Screens: Patient, Doctor, Lab, Admin dashboards
├── Widgets: Cards, timeline, chat bubbles
├── State: Riverpod providers
└── Localization: Urdu + English

Backend Developer
├── FastAPI microservices
├── Database schema + migrations
├── API endpoints
└── Authentication & RBAC

AI/Agents Developer
├── Antigravity orchestrator
├── 7 agent prompts
├── Gemini integration
└── Verification gates

Database Developer
├── PostgreSQL schema design
├── Firestore setup
├── Append-only timeline implementation
└── Query optimization

Security Developer
├── Encryption (AES-256)
├── Audit logging
├── Multi-factor auth
└── Medical data protection

QA/Testing
├── Unit tests
├── Integration tests
├── UI regression tests
└── Stress testing

DevOps/Build
├── Docker configuration
├── APK build pipeline
├── Deployment guides
└── CI/CD setup
```

---

## Success Criteria (Judging Rubric)

✅ **Functionality** (40%)
- Complete AI-agentic pipeline working
- All 4 portals (patient, doctor, lab, admin) functional
- Medical timeline immutable and secure
- ✓ Target: 100/100

✅ **Innovation** (25%)
- Multi-agent orchestration with verification gates
- Offline-first mobile architecture
- NADRA-linked patient ID system
- ✓ Target: 100/100

✅ **Design & UX** (20%)
- Modern, intuitive interface
- Responsive on low-end devices
- Urdu/English support seamless
- ✓ Target: 95/100

✅ **Deployment** (15%)
- APK installs and runs without errors
- Works on API 24+ (Android 7+)
- <3 second cold start
- ✓ Target: 100/100

---

## Final Checklist Before Submission

- [ ] APK tested on 3 different devices (high-end, mid-range, low-end)
- [ ] All permissions requested properly (camera, storage, etc.)
- [ ] No external dependencies required (offline-first)
- [ ] Gemini API key rotated and secured
- [ ] Database backups functional
- [ ] Demo video uploaded (< 3 minutes)
- [ ] Documentation complete and clear
- [ ] GitHub/GitLab repo shared (private to judges)
- [ ] Setup instructions tested on fresh machine
- [ ] Contact info + team details provided

---

**Status**: Ready for 4-week sprint implementation  
**Expected Outcome**: Production-ready APK scoring 95%+ from judges  
**Start Date**: [Hackathon Date] - 4 weeks  
**Target Submission**: APK + Documentation package
