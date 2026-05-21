# PANOR Flutter Mobile App - Complete Architecture

## App Structure

```
lib/
├── main.dart                          # App entry point, theme initialization
├── config/                            # Configuration files
│   ├── app_config.dart               # App constants, API endpoints
│   ├── app_routes.dart               # Route definitions
│   └── app_theme.dart                # Global theme (dark/light, colors, typography)
│
├── core/                             # Core functionality (non-UI)
│   ├── constants/
│   │   ├── app_constants.dart        # App-wide constants
│   │   ├── asset_paths.dart          # Image/asset paths
│   │   └── text_strings.dart         # All UI text (Urdu/English localization)
│   │
│   ├── extensions/
│   │   ├── context_extension.dart    # BuildContext helpers
│   │   ├── string_extension.dart     # String utilities
│   │   └── date_extension.dart       # Date formatting utilities
│   │
│   ├── services/
│   │   ├── local_storage_service.dart    # Hive-based local cache
│   │   ├── http_service.dart             # HTTP client wrapper
│   │   ├── auth_service.dart             # Authentication
│   │   ├── offline_sync_service.dart     # Delta sync engine
│   │   └── notification_service.dart     # Local notifications
│   │
│   ├── utils/
│   │   ├── validators.dart           # Input validators
│   │   ├── formatters.dart           # Data formatters
│   │   └── logger.dart               # Centralized logging
│   │
│   └── error/
│       ├── exceptions.dart           # Custom exceptions
│       └── error_handler.dart        # Error handling utilities
│
├── features/
│   ├── auth/                         # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── login_request_model.dart
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           ├── register_screen.dart
│   │           └── role_selection_screen.dart
│   │
│   ├── patient/                    # Patient portal feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── patient_local_datasource.dart
│   │   │   │   └── patient_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── patient_model.dart
│   │   │   │   ├── medical_record_model.dart
│   │   │   │   └── medication_model.dart
│   │   │   └── repositories/
│   │   │       └── patient_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── patient_bloc.dart
│   │       │   ├── patient_event.dart
│   │       │   └── patient_state.dart
│   │       │
│   │       ├── screens/
│   │       │   ├── patient_dashboard_screen.dart      # Dashboard
│   │       │   ├── medical_history_screen.dart        # Timeline
│   │       │   ├── ai_consultation_screen.dart        # Chat
│   │       │   ├── medications_screen.dart            # Current meds
│   │       │   ├── upload_records_screen.dart         # Upload PDF/Camera
│   │       │   └── doctor_booking_screen.dart         # Book consultation
│   │       │
│   │       └── widgets/
│   │           ├── patient_info_card.dart
│   │           ├── medical_timeline_widget.dart
│   │           ├── medication_card.dart
│   │           ├── ai_chat_bubble.dart
│   │           └── record_upload_widget.dart
│   │
│   ├── doctor/                    # Doctor portal feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── doctor_dashboard_screen.dart       # Dashboard
│   │       │   ├── patient_list_screen.dart           # Onboarded patients
│   │       │   ├── patient_detail_screen.dart         # Patient full record
│   │       │   ├── consultation_schedule_screen.dart  # Appointments
│   │       │   ├── order_labs_screen.dart             # Create lab orders
│   │       │   └── prescription_screen.dart           # Create prescriptions
│   │       │
│   │       └── widgets/
│   │           ├── patient_card.dart
│   │           ├── critical_patient_alert.dart
│   │           ├── consultation_card.dart
│   │           └── ai_recommendation_card.dart
│   │
│   ├── lab/                       # Lab assistant portal
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── lab_dashboard_screen.dart          # Dashboard
│   │       │   ├── lab_orders_screen.dart             # Orders queue
│   │       │   ├── test_collection_screen.dart        # Collection workflow
│   │       │   └── result_entry_screen.dart           # Result input
│   │       │
│   │       └── widgets/
│   │           ├── lab_order_card.dart
│   │           └── test_spec_widget.dart
│   │
│   ├── admin/                     # Admin dashboard feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── admin_dashboard_screen.dart        # Dashboard
│   │       │   ├── analytics_screen.dart              # Analytics
│   │       │   ├── users_management_screen.dart       # User mgmt
│   │       │   ├── emergency_alerts_screen.dart       # Emergency monitor
│   │       │   └── system_settings_screen.dart        # Settings
│   │       │
│   │       └── widgets/
│   │           ├── stats_card.dart
│   │           ├── chart_widget.dart
│   │           └── emergency_alert_card.dart
│   │
│   └── shared/                    # Shared features across portals
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           │   ├── splash_screen.dart                 # App start
│           │   ├── onboarding_screen.dart             # First time user
│           │   ├── profile_screen.dart                # User profile
│           │   ├── notifications_screen.dart          # Notifications
│           │   └── settings_screen.dart               # App settings
│           │
│           └── widgets/
│               ├── app_navigation_bar.dart
│               ├── app_drawer.dart
│               ├── loading_widget.dart
│               ├── error_widget.dart
│               └── custom_appbar.dart
│
└── l10n/                         # Localization (Urdu, English, etc.)
    ├── app_en.arb
    ├── app_ur.arb
    └── app_generator.dart


```

---

## State Management (Riverpod)

### Riverpod Provider Structure

```dart
// lib/features/patient/presentation/providers/patient_providers.dart

// 1. Service providers
final httpServiceProvider = Provider((ref) => HttpService());
final authServiceProvider = Provider((ref) => AuthService());

// 2. Repository providers
final patientRepositoryProvider = Provider((ref) => 
  PatientRepositoryImpl(
    remoteDataSource: ref.watch(patientRemoteDatasourceProvider),
    localDataSource: ref.watch(patientLocalDatasourceProvider),
  ),
);

// 3. UseCase providers
final getPatientDashboardUcaseProvider = Provider((ref) =>
  GetPatientDashboardUsecase(
    repository: ref.watch(patientRepositoryProvider),
  ),
);

// 4. State providers (FutureProvider for async data)
final patientDashboardProvider = FutureProvider((ref) async {
  final usecase = ref.watch(getPatientDashboardUcaseProvider);
  return await usecase.call();
});

// 5. StateNotifier providers (for mutable state)
final patientNotifierProvider = StateNotifierProvider((ref) =>
  PatientNotifier(ref.watch(patientRepositoryProvider)),
);

// 6. Selected state providers
final selectedPatientProvider = StateProvider<Patient?>((ref) => null);
final aiChatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
```

---

## Offline-First Sync Engine

### Local Cache Strategy

```dart
// lib/core/services/local_storage_service.dart

class LocalStorageService {
  late Box<PatientData> patientBox;
  late Box<MedicalRecord> medicalRecordBox;
  late Box<SyncMetadata> syncMetadataBox;
  
  Future<void> initialize() async {
    patientBox = await Hive.openBox('patient_data');
    medicalRecordBox = await Hive.openBox('medical_records');
    syncMetadataBox = await Hive.openBox('sync_metadata');
  }
  
  // Cache patient data locally
  Future<void> cachePatientData(Patient patient) async {
    await patientBox.put(patient.id, patient);
    await _updateSyncTimestamp('patient_${patient.id}');
  }
  
  // Get from cache
  Patient? getPatientFromCache(String patientId) {
    return patientBox.get(patientId);
  }
  
  // Delta sync: only sync changed data
  Future<void> syncChanges() async {
    final lastSyncTime = await _getLastSyncTime();
    // Compare local changes with server
    // Only sync modified records
  }
}

// lib/core/services/offline_sync_service.dart

class OfflineSyncService {
  Future<void> syncMedicalRecords() async {
    if (await isConnected()) {
      // Sync to server
      await _uploadLocalChanges();
      await _downloadServerChanges();
    } else {
      // Work offline with local cache
      logger.info("Offline mode: Using local cache");
    }
  }
}
```

---

## AI Consultation Chat Flow

### Patient Intake Agent Integration

```dart
// lib/features/patient/presentation/screens/ai_consultation_screen.dart

class AiConsultationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AiConsultationScreen> createState() => _AiConsultationScreenState();
}

class _AiConsultationScreenState extends ConsumerState<AiConsultationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatMessagesProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('AI Health Assistant')),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  message: message,
                  isFromUser: message.isFromUser,
                );
              },
            ),
          ),
          
          // Input area
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _startVoiceInput,  // Urdu voice support
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendMessage() {
    final message = _messageController.text;
    
    // 1. Add user message to chat
    ref.read(aiChatMessagesProvider.notifier).state += [
      ChatMessage(text: message, isFromUser: true),
    ];
    
    // 2. Call backend AI pipeline
    _callAiPipeline(message);
    
    _messageController.clear();
  }
  
  void _callAiPipeline(String userInput) async {
    try {
      // Call backend /api/v1/patients/{patientId}/ai-consultation
      final response = await HttpService().post(
        '/api/v1/patients/${patientId}/ai-consultation',
        body: {
          'input': userInput,
          'language': _detectLanguage(userInput),  // Urdu/English
          'modality': 'text',
        },
      );
      
      // Add AI response to chat
      ref.read(aiChatMessagesProvider.notifier).state += [
        ChatMessage(
          text: response['ai_response'],
          isFromUser: false,
          recommendations: response['recommendations'],
        ),
      ];
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
```

---

## Medical Timeline View

```dart
// lib/features/patient/presentation/widgets/medical_timeline_widget.dart

class MedicalTimelineWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicalHistory = ref.watch(medicalHistoryProvider);
    
    return medicalHistory.when(
      data: (records) => TimelineView(
        children: records.map((record) => TimelineEvent(
          title: record.eventType,  // "Consultation", "Lab Result", etc.
          date: record.date,
          description: record.description,
          details: record.details,
          icon: _getIconForEventType(record.eventType),
        )).toList(),
      ),
      loading: () => LoadingWidget(),
      error: (err, stack) => ErrorWidget(error: err),
    );
  }
}
```

---

## Critical Performance Optimizations

### 1. Lazy Loading
```dart
// Load screens only when tapped (using AutoRouter)
routes: [
  AutoRoute(page: PatientDashboardScreen.page),
  AutoRoute(page: MedicalHistoryScreen.page),
  // Loaded on-demand
]
```

### 2. Image Caching
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => SkeletonLoader(),
  cacheManager: CustomCacheManager(),
)
```

### 3. List Virtualization
```dart
// Use paginated ListView for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(item: items[index]),
)
```

---

## Localization (Urdu + English)

```dart
// app_en.arb
{
  "appTitle": "PANOR Health",
  "dashboard": "Dashboard",
  "symptoms": "Describe your symptoms"
}

// app_ur.arb
{
  "appTitle": "پینور ہیلتھ",
  "dashboard": "ڈیش بورڈ",
  "symptoms": "اپنی علامات بیان کریں"
}

// Usage in widgets
Text(AppLocalizations.of(context)!.appTitle)
```

---

## Build & Deployment

### Android Build
```bash
# Release APK
flutter build apk --split-per-abi

# Optimized for low-end devices
flutter build apk --target-platform android-arm
```

### App Size Optimization
- Remove unused dependencies
- Enable Proguard/R8 minification
- Use WebP for images
- Lazy-load modules

**Target Size**: < 100 MB

---

## Testing Strategy

```dart
// test/features/patient/presentation/screens/patient_dashboard_test.dart

void main() {
  group('Patient Dashboard', () {
    testWidgets('displays patient info', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableApp());
      expect(find.text('Patient Dashboard'), findsOneWidget);
    });
  });
}
```

---

**Status**: Architecture ready for implementation  
**Next Steps**: Implement screens and bloc providers in parallel
