import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final users = adminProv.users;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: adminProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await adminProv.fetchUsers();
              },
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        'No records available',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final user = users[index] as Map;
                        final bool active = user['is_active'] as bool? ?? true;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: Color(0xFF7C3AED), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['full_name']?.toString() ?? 'System User',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0A1628),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${user['role']} — ${user['email']}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (active)
                                TextButton(
                                  onPressed: () async {
                                    final success = await adminProv.deactivateUser(user['id'].toString());
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success ? 'User soft-deactivated successfully' : 'Failed to deactivate user',
                                          ),
                                          backgroundColor: success ? Colors.green : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Deactivate',
                                    style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Inactive',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
