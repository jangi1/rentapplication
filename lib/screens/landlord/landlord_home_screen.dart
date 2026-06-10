import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../models/inquiry_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class LandlordHomeScreen extends StatelessWidget {
  final VoidCallback onViewAll;
  
  const LandlordHomeScreen({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(user?.fullName ?? 'Landlord'),
            _buildStatsSection(user?.uid ?? '', db),
            _buildRecentInquiriesSection(user?.uid ?? '', db),
            _buildRecentListingsSection(context, user?.uid ?? '', db),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
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
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.white),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    ),
                  )
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
            "Here's your property overview.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String landlordId, DatabaseService db) {
    return StreamBuilder<List<ApartmentModel>>(
      stream: db.getLandlordApartments(landlordId),
      builder: (context, snapshot) {
        int total = snapshot.hasData ? snapshot.data!.length : 0;
        int active = snapshot.hasData ? snapshot.data!.where((a) => a.status == 'Available').length : 0;
        int rented = snapshot.hasData ? snapshot.data!.where((a) => a.status == 'Rented').length : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.6,
            children: [
              _statCard('Total Listings', '$total', const Color(0xFF1E88E5)),
              _statCard('Active', '$active', const Color(0xFF43A047)),
              _statCard('Rented', '$rented', const Color(0xFFFB8C00)),
              _statCard('Pending Inquiries', '3', const Color(0xFFE91E63)),
            ],
          ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRecentInquiriesSection(String landlordId, DatabaseService db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text('Recent Inquiries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<List<InquiryModel>>(
          stream: db.getLandlordInquiries(landlordId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Text('No recent inquiries', style: TextStyle(color: Colors.grey)),
              );
            }
            final inquiries = snapshot.data!.take(2).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final inq = inquiries[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: Color(0xFFBBDEFB), child: Icon(Icons.person, color: Color(0xFF1E88E5))),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Inquiry from Tenant', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(inq.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
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
                ? Image.network(apt.imageUrls.first, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.apartment)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('₱ ${apt.price}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
