import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/patient_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientProv = Provider.of<PatientProvider>(context);
    final notifications = patientProv.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Alert Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: patientProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await patientProv.fetchNotifications();
              },
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No records available',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final notif = notifications[index] as Map;
                        final bool isRead = notif['is_read'] as bool? ?? false;

                        return InkWell(
                          onTap: () {
                            if (!isRead) {
                              patientProv.markNotificationRead(notif['id'].toString());
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.white : const Color(0xFF0066FF).withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFF0066FF).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notifications_active_outlined,
                                  color: isRead ? const Color(0xFF94A3B8) : const Color(0xFF0066FF),
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif['title']?.toString() ?? 'Notification Alert',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                          color: const Color(0xFF0A1628),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif['message']?.toString() ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notif['created_at']?.toString().substring(0, 16).replaceAll('T', ' ') ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF0066FF),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
