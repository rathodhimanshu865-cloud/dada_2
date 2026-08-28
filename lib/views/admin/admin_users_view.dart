import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../utils/app_typography.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color primaryTeal = const Color(0xFF0F4C5C);
  String _searchQuery = '';

  Stream<List<UserModel>> _usersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.deepPurple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Management',
          style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'View all registered users, their roles, and account status.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by name, email or phone...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        ),
        const SizedBox(height: 24),

        StreamBuilder<List<UserModel>>(
          stream: _usersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var users = snapshot.data ?? [];

            if (_searchQuery.isNotEmpty) {
              users = users.where((u) {
                return u.name.toLowerCase().contains(_searchQuery) ||
                    u.email.toLowerCase().contains(_searchQuery) ||
                    u.phone.toLowerCase().contains(_searchQuery);
              }).toList();
            }

            if (users.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No users found.'),
              ));
            }

            // Stats row
            final totalUsers = users.length;
            final adminCount = users.where((u) => u.role.toLowerCase() == 'admin').length;
            final activeCount = users.where((u) => u.isActive).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats chips
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _statChip('Total Users', totalUsers.toString(), Colors.blueGrey),
                    _statChip('Admins', adminCount.toString(), Colors.deepPurple),
                    _statChip('Active', activeCount.toString(), Colors.green),
                  ],
                ),
                const SizedBox(height: 20),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _buildUserCard(users[i]),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryTeal.withOpacity(0.1),
            backgroundImage: user.profileImage.isNotEmpty ? NetworkImage(user.profileImage) : null,
            child: user.profileImage.isEmpty
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 18),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                if (user.phone.isNotEmpty)
                  Text(user.phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _roleColor(user.role).withOpacity(0.3)),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                color: _roleColor(user.role),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status & date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (user.createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Joined ${DateFormat('dd MMM yyyy').format(user.createdAt!)}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
