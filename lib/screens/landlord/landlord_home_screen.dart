import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/apartment_model.dart';
import '../../models/inquiry_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../chat_room_screen.dart';
import 'viewing_requests_screen.dart';

class LandlordHomeScreen extends StatelessWidget {
  final VoidCallback onViewAll;
  
  const LandlordHomeScreen({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          // Streams update automatically, but this provides a visual way to "force" a check
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context, user.fullName),
              _buildStatsSection(user.uid, db),
              _buildIncomingInquiriesSection(user.uid, db),
              _buildRecentConversationsSection(user.uid, db),
              _buildRecentListingsSection(context, user.uid, db),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0D47A1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: Colors.white),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewingRequestsScreen()));
                    },
                  ),
                  const Icon(Icons.notifications_none, color: Colors.white),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            'Hello, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Manage your property inquiries below.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String landlordId, DatabaseService db) {
    return StreamBuilder<List<ApartmentModel>>(
      stream: db.getLandlordApartments(landlordId),
      builder: (context, aptSnapshot) {
        final totalListings = aptSnapshot.hasData ? aptSnapshot.data!.length.toString() : '...';

        return StreamBuilder<List<InquiryModel>>(
          stream: db.getLandlordInquiries(landlordId),
          builder: (context, inqSnapshot) {
            final inquiries = inqSnapshot.data ?? [];
            final pending = inqSnapshot.hasData ? inquiries.where((i) => i.status == 'Pending').length.toString() : '...';

            return StreamBuilder<List<MessageModel>>(
              stream: db.getAllUserMessages(landlordId),
              builder: (context, msgSnapshot) {
                final messages = msgSnapshot.data ?? [];
                final unreadMessages = msgSnapshot.hasData ? messages.where((m) => !m.isRead && m.receiverId == landlordId).length.toString() : '...';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _statCard('Total Listings', totalListings, const Color(0xFF1E88E5))),
                          const SizedBox(width: 15),
                          Expanded(child: _statCard('Pending Inquiries', pending, Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _statCard('New Messages', unreadMessages, Colors.deepPurple)),
                          const SizedBox(width: 15),
                          Expanded(child: _statCard('Total Inquiries', inqSnapshot.hasData ? '${inquiries.length}' : '...', Colors.blueGrey)),
                        ],
                      ),
                    ],
                  ),
                );
              }
            );
          }
        );
      },
    );
  }

  Widget _statCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildIncomingInquiriesSection(String landlordId, DatabaseService db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text('Incoming Inquiries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<List<InquiryModel>>(
          stream: db.getLandlordInquiries(landlordId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Text('Error loading inquiries: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Text('No inquiries received yet.', style: TextStyle(color: Colors.grey)),
              );
            }
            
            final pendingInquiries = snapshot.data!.where((i) => i.status == 'Pending').toList();

            if (pendingInquiries.isEmpty) {
               return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Text('No new pending inquiries.', style: TextStyle(color: Colors.grey)),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: pendingInquiries.length > 3 ? 3 : pendingInquiries.length,
              itemBuilder: (context, index) {
                final inq = pendingInquiries[index];
                return _buildInquiryCard(context, inq, db);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInquiryCard(BuildContext context, InquiryModel inq, DatabaseService db) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  inq.propertyTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E88E5)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('MMM dd').format(inq.inquiryDate),
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(inq.tenantName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            inq.message,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => db.updateInquiryStatus(inq.id, 'Accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => db.updateInquiryStatus(inq.id, 'Declined'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Decline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              _circleChatButton(context, inq),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleChatButton(BuildContext context, InquiryModel inq) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              otherUserId: inq.tenantId,
              otherUserName: inq.tenantName,
              apartmentId: inq.apartmentId,
              landlordId: inq.landlordId,
              tenantId: inq.tenantId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chat_outlined, color: Color(0xFF1E88E5), size: 20),
      ),
    );
  }

  Widget _buildRecentConversationsSection(String landlordId, DatabaseService db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text('Recent Conversations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<List<MessageModel>>(
          stream: db.getAllUserMessages(landlordId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Text('Error loading messages: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Text('No messages yet.', style: TextStyle(color: Colors.grey)),
              );
            }

            final Map<String, MessageModel> conversations = {};
            for (var msg in snapshot.data!) {
              if (!conversations.containsKey(msg.conversationId)) {
                conversations[msg.conversationId] = msg;
              }
            }

            final recentConv = conversations.values.take(3).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recentConv.length,
              itemBuilder: (context, index) {
                final msg = recentConv[index];
                final otherUserId = msg.participants.firstWhere((id) => id != landlordId);

                return FutureBuilder<UserModel?>(
                  future: AuthService().getUserData(otherUserId),
                  builder: (context, userSnapshot) {
                    final otherUserName = userSnapshot.hasData ? userSnapshot.data!.fullName : 'Loading...';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.person, color: Color(0xFF1E88E5), size: 20),
                      ),
                      title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(msg.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                        DateFormat('MMM dd').format(msg.timestamp),
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      onTap: () {
                        if (msg.apartmentId != null && msg.landlordId != null && msg.tenantId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                otherUserId: otherUserId,
                                otherUserName: otherUserName,
                                apartmentId: msg.apartmentId!,
                                landlordId: msg.landlordId!,
                                tenantId: msg.tenantId!,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentListingsSection(BuildContext context, String landlordId, DatabaseService db) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: onViewAll, child: const Text('See All')),
            ],
          ),
        ),
        StreamBuilder<List<ApartmentModel>>(
          stream: db.getLandlordApartments(landlordId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
            final listings = snapshot.data!.take(3).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final apt = listings[index];
                return _buildRecentListingItem(apt);
              },
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRecentListingItem(ApartmentModel apt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: apt.imageUrls.isNotEmpty
                ? Image.network(apt.imageUrls.first, width: 50, height: 50, fit: BoxFit.cover)
                : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.apartment, size: 20)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('₱ ${apt.price}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          _statusBadge(apt.status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'Available' ? Colors.green : (status == 'Rented' ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
