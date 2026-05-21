import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/dashboards/patient_dashboard.dart';

void main() {
  testWidgets('patient dashboard renders the PANOR demo home', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientDashboard(),
      ),
    );

    expect(find.text('Patient Dashboard'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
  });
}
