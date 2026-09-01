import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';

class DevoteeManagementView extends StatefulWidget {
  const DevoteeManagementView({super.key});

  @override
  State<DevoteeManagementView> createState() => _DevoteeManagementViewState();
}

class _DevoteeManagementViewState extends State<DevoteeManagementView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        var users = snapshot.data?.docs.map((doc) => UserModel.fromFirestore(doc)).toList() ?? [];

        // Apply local search filter
        if (_searchQuery.isNotEmpty) {
          users = users.where((u) => 
            u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
            u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.phone.contains(_searchQuery)
          ).toList();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Devotee User Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('View registered devotees, their contact information, and sacred purchase history.', 
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search devotees...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                        suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        }) : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              if (users.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Text('No devotees found.', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.45,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, i) => _DevoteeCard(user: users[i]),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DevoteeCard extends StatelessWidget {
  final UserModel user;
  const _DevoteeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isNew = user.createdAt != null && 
                       DateTime.now().difference(user.createdAt!).inHours < 48;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF3E2723),
                    backgroundImage: (user.profileImage.isNotEmpty) ? NetworkImage(user.profileImage) : null,
                    child: (user.profileImage.isEmpty) ? Text(user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                  ),
                  if (isNew)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                        child: const Icon(Icons.star, size: 8, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(user.name.isNotEmpty ? user.name : 'Sacred Devotee', 
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                            child: const Text('NEW', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Text(user.email, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(user.phone, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFAD8B63)),
              const SizedBox(width: 8),
              Expanded(child: Text('${user.city ?? 'Unknown City'}, ${user.state ?? 'State'}', 
                style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Real Statistics via FutureBuilder
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user.uid).get(),
            builder: (context, snapshot) {
              int totalOrders = 0;
              double totalSpent = 0.0;

              if (snapshot.hasData) {
                totalOrders = snapshot.data!.docs.length;
                for (var doc in snapshot.data!.docs) {
                  totalSpent += (doc.data() as Map<String, dynamic>)['totalAmount'] ?? 0.0;
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem('Total Orders', totalOrders.toString()),
                  _statItem('Lifetime Offerings', '₹${totalSpent.toStringAsFixed(2)}'),
                ],
              );
            }
          ),
          
          const Spacer(),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _launchWhatsApp(user.phone),
                child: const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 14, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text('WhatsApp Seva', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ),
              Text('Joined ${user.createdAt != null ? DateFormat('yyyy-MM-dd').format(user.createdAt!) : 'Recent'}', 
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C))),
      ],
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = 'https://wa.me/$cleanPhone';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
