import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../models/inquiry_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  final ApartmentModel apartment;
  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context, user, db),
                _buildContentSection(context, user),
              ],
            ),
          ),
          _buildBottomButtons(context, user),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, user, db) {
    return Stack(
      children: [
        SizedBox(
          height: 350,
          child: apartment.imageUrls.isNotEmpty
              ? PageView.builder(
                  itemCount: apartment.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(apartment.imageUrls[index], fit: BoxFit.cover, width: double.infinity);
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
                    _circleIconButton(Icons.share_outlined, () {}),
                    const SizedBox(width: 10),
                    StreamBuilder<List<String>>(
                      stream: db.getFavoriteApartmentIds(user!.uid),
                      builder: (context, snapshot) {
                        bool isFav = snapshot.hasData && snapshot.data!.contains(apartment.id);
                        return _circleIconButton(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          () => db.toggleFavorite(user.uid, apartment.id),
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
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '1/${apartment.imageUrls.length}',
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
            apartment.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(apartment.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                '₱ ${apartment.price}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
              ),
              const Text(' /month', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(Icons.king_bed_outlined, '${apartment.bedrooms} Beds'),
              _infoTile(Icons.bathtub_outlined, '${apartment.bathrooms} Bath'),
              _infoTile(Icons.square_foot_outlined, '${apartment.floorArea.round()} sqm'),
              _infoTile(Icons.apartment_outlined, apartment.propertyType),
            ],
          ),
          const SizedBox(height: 30),
          const Text('About this place', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            apartment.description,
            style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
          ),
          if (apartment.amenities.isNotEmpty) ...[
            const SizedBox(height: 30),
            const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: apartment.amenities.map((a) => _amenityChip(a)).toList(),
            ),
          ],
          const SizedBox(height: 100), // Space for bottom buttons
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

  Widget _buildBottomButtons(BuildContext context, user) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
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
                onPressed: () => _showInquiryDialog(context, user.uid),
                child: const Text('Message', style: TextStyle(color: Color(0xFF1E88E5), fontSize: 16)),
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
                onPressed: () {},
                child: const Text('Call Landlord', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInquiryDialog(BuildContext context, String tenantId) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Inquiry'),
        content: TextField(
          controller: messageController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Enter your message...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                await DatabaseService().sendInquiry(InquiryModel(
                  id: '',
                  apartmentId: apartment.id,
                  tenantId: tenantId,
                  message: messageController.text.trim(),
                  inquiryDate: DateTime.now(),
                  status: 'Pending',
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inquiry sent!')));
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
