import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import 'apartment_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Saved Apartments', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null 
        ? const Center(child: Text('Please log in to see your favorites'))
        : StreamBuilder<List<String>>(
            stream: db.getFavoriteApartmentIds(user.uid),
            builder: (context, favSnapshot) {
              if (favSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final favIds = favSnapshot.data ?? [];
              if (favIds.isEmpty) {
                return _buildEmptyState();
              }

              return StreamBuilder<List<ApartmentModel>>(
                stream: db.getApartments(),
                builder: (context, aptSnapshot) {
                  if (aptSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final apartments = aptSnapshot.data?.where((apt) => favIds.contains(apt.id)).toList() ?? [];
                  
                  if (apartments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: apartments.length,
                    itemBuilder: (context, index) {
                      final apt = apartments[index];
                      return _buildFavoriteCard(context, apt);
                    },
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text('No saved apartments yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, ApartmentModel apt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ApartmentDetailsScreen(apartment: apt)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: apt.imageUrls.isNotEmpty
                  ? Image.network(apt.imageUrls.first, height: 180, width: double.infinity, fit: BoxFit.cover)
                  : Container(height: 180, color: Colors.grey[300], child: const Icon(Icons.apartment, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(apt.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Icon(Icons.favorite, color: Colors.red, size: 22),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          apt.location.toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₱ ${apt.price} /month',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
