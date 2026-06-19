import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../models/inquiry_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import '../../models/message_model.dart';
import '../chat_room_screen.dart';

import 'request_viewing_screen.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final ApartmentModel apartment;
  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  int _currentImage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context, user?.uid, db),
                _buildContentSection(context, user),
              ],
            ),
          ),
          _buildBottomButtons(context, user?.uid),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, String? userId, DatabaseService db) {
    final apartment = widget.apartment;
    return Stack(
      children: [
        SizedBox(
          height: 350,
          child: apartment.imageUrls.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentImage = idx),
                  itemCount: apartment.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'apt-image-${apartment.id}-$index',
                      child: Image.network(apartment.imageUrls[index], fit: BoxFit.cover, width: double.infinity),
                    );
                  },
                )
              : Container(color: Colors.grey[300], child: const Icon(Icons.apartment, size: 100)),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                Row(
                  children: [
                    _circleIconButton(Icons.share_outlined, () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing feature coming soon!')));
                    }),
                    const SizedBox(width: 10),
                    if (userId != null)
                      StreamBuilder<List<String>>(
                        stream: db.getFavoriteApartmentIds(userId),
                        builder: (context, snapshot) {
                          bool isFav = snapshot.hasData && snapshot.data!.contains(apartment.id);
                          return _circleIconButton(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            () => db.toggleFavorite(userId, apartment.id),
                            color: isFav ? Colors.red : Colors.black,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (widget.apartment.imageUrls.isNotEmpty)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${_currentImage + 1}/${widget.apartment.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {Color color = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.apartment.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(widget.apartment.location.toString(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                '₱ ${widget.apartment.price}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
              ),
              const Text(' /month', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _infoTile(Icons.king_bed_outlined, '${widget.apartment.bedrooms} Beds'),
               _infoTile(Icons.bathtub_outlined, '${widget.apartment.bathrooms} Bath'),
               _infoTile(Icons.square_foot_outlined, '${widget.apartment.floorArea.round()} sqm'),
               _infoTile(Icons.apartment_outlined, widget.apartment.propertyType),
            ],
          ),
          const SizedBox(height: 30),
          _buildInquiryAction(context, user?.uid),
          const SizedBox(height: 15),
          _buildViewingAction(context, user?.uid),
          const SizedBox(height: 30),
          const Text('About this place', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
           Text(
             widget.apartment.description,
            style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.check_circle_outline, 'Furnished', widget.apartment.isFurnished),
          _buildFeatureRow(Icons.local_parking_outlined, 'Parking Available', widget.apartment.hasParking),
          _buildFeatureRow(Icons.pets_outlined, 'Pet-Friendly', widget.apartment.isPetFriendly),
           if (widget.apartment.amenities.isNotEmpty) ...[
            const SizedBox(height: 30),
            const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
               children: widget.apartment.amenities.map((a) => _amenityChip(a)).toList(),
            ),
          ],
          const SizedBox(height: 100), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildInquiryAction(BuildContext context, String? userId) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Interested in this property?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => _showInquiryDialog(context, userId),
            child: const Text('Send Inquiry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildViewingAction(BuildContext context, String? userId) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined, color: Colors.green),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Want to see the place?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestViewingScreen(apartment: widget.apartment),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to schedule a viewing')));
              }
            },
            child: const Text('Schedule Viewing', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showInquiryDialog(BuildContext context, String? userId) {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to send an inquiry')));
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Inquiry'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'I am interested in this property. Is it still available?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messageText = controller.text.trim();
              if (messageText.isEmpty) return;

              final inquiry = InquiryModel(
                id: '',
                apartmentId: widget.apartment.id,
                propertyTitle: widget.apartment.title,
                landlordId: widget.apartment.landlordId,
                landlordName: widget.apartment.landlordName,
                tenantId: userId,
                tenantName: user?.fullName ?? 'Tenant',
                message: messageText,
                inquiryDate: DateTime.now(),
                status: 'Pending',
              );

              final db = DatabaseService();
              await db.sendInquiry(inquiry);

              // Automatically create a chat conversation (Requirement F - Option 1)
              final conversationId = "${widget.apartment.id}_${userId}_${widget.apartment.landlordId}";
              final List<String> participants = [userId, widget.apartment.landlordId];
              participants.sort();

              final initialMessage = MessageModel(
                id: '',
                conversationId: conversationId,
                senderId: userId,
                receiverId: widget.apartment.landlordId,
                senderRole: 'Tenant',
                text: "Inquiry about ${widget.apartment.title}: $messageText",
                timestamp: DateTime.now(),
                participants: participants,
                apartmentId: widget.apartment.id,
                landlordId: widget.apartment.landlordId,
                tenantId: userId,
              );

              await db.sendMessage(initialMessage);

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inquiry sent and message started!')));
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, bool value) {
    if (!value) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey[700]),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _amenityChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }

  Widget _buildBottomButtons(BuildContext context, String? userId) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFF1E88E5)),
                ),
                onPressed: () {
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(
                          otherUserId: widget.apartment.landlordId,
                          otherUserName: widget.apartment.landlordName,
                          apartmentId: widget.apartment.id,
                          landlordId: widget.apartment.landlordId,
                          tenantId: userId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to contact the landlord')));
                  }
                },
                child: Text('Message ${widget.apartment.landlordName}', style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 14, overflow: TextOverflow.ellipsis)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${widget.apartment.contactNumber}...')));
                },
                child: const Text('Call Now', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
