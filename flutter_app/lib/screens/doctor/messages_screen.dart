import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Secure Inbox',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildMessageTile(
            context,
            'Rahul Sharma',
            'I took the prescribed Aspirin. The mild stomach discomfort has subsided completely.',
            '10:32 AM',
            true,
          ),
          const SizedBox(height: 16),
          _buildMessageTile(
            context,
            'Priya Patel',
            'Can you review my blood report? I uploaded the lab results this morning.',
            'Yesterday',
            false,
          ),
          const SizedBox(height: 16),
          _buildMessageTile(
            context,
            'System Notification',
            'Antigravity successfully persistence-migrated user clinical audit logs to secure tables.',
            '20 May',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    String sender,
    String snippet,
    String time,
    bool unread,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFF00C853).withValues(alpha: 0.01) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread ? const Color(0xFF00C853).withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: (unread ? const Color(0xFF00C853) : const Color(0xFF94A3B8)).withValues(alpha: 0.1),
            child: Icon(
              Icons.chat_bubble_outline,
              color: unread ? const Color(0xFF00C853) : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sender,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                        color: const Color(0xFF0A1628),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
