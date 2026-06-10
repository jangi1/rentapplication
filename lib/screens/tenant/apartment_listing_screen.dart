import 'package:flutter/material.dart';
import '../../models/apartment_model.dart';
import '../../models/filter_model.dart';
import '../../services/database_service.dart';
import 'apartment_details_screen.dart';
import 'filter_screen.dart';

class ApartmentListingScreen extends StatefulWidget {
  const ApartmentListingScreen({super.key});

  @override
  State<ApartmentListingScreen> createState() => _ApartmentListingScreenState();
}

class _ApartmentListingScreenState extends State<ApartmentListingScreen> {
  final DatabaseService _db = DatabaseService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  FilterModel _activeFilters = FilterModel();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.home_rounded},
    {'name': 'Condominium', 'icon': Icons.apartment_rounded},
    {'name': 'Apartment', 'icon': Icons.business_rounded},
    {'name': 'Boarding House', 'icon': Icons.room_preferences_rounded},
    {'name': 'House', 'icon': Icons.house_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategories(),
            _buildSectionTitle(),
            Expanded(child: _buildListings()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1E88E5), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Davao City, PH',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
               boxShadow: const [
                 BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 4))
               ],
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search apartments, locations...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => FilterScreen(initialFilters: _activeFilters))
              );
              if (result != null && result is FilterModel) {
                setState(() {
                  _activeFilters = result;
                  // If category was selected but filters now have a different property type, sync them
                  if (_activeFilters.propertyType != 'All') {
                    _selectedCategory = _activeFilters.propertyType!;
                  }
                });
              }
            },
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: _activeFilters.isEmpty ? Colors.grey.shade50 : const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Icon(Icons.tune_rounded, color: _activeFilters.isEmpty ? Colors.black : Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = cat['name'];
              _activeFilters.propertyType = cat['name'];
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade100),
                       boxShadow: isSelected
                           ? [const BoxShadow(color: Color.fromRGBO(30, 136, 229, 0.3), blurRadius: 10, offset: Offset(0, 5))]
                           : [const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 5, offset: Offset(0, 2))],
                    ),
                    child: Icon(cat['icon'], color: isSelected ? Colors.white : Colors.grey.shade700, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _activeFilters.isEmpty ? 'Popular Listings' : 'Filtered Results',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          if (!_activeFilters.isEmpty)
            TextButton(
              onPressed: () => setState(() {
                _activeFilters = FilterModel();
                _selectedCategory = 'All';
              }),
              child: const Text('Clear Filters', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            )
          else
            TextButton(
              onPressed: () {},
              child: const Text('See All', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildListings() {
    return StreamBuilder<List<ApartmentModel>>(
      stream: _db.getApartments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final apartments = snapshot.hasData 
          ? snapshot.data!.where((apt) {
              // 1. Search Query
              final matchesSearch = apt.location.toString().toLowerCase().contains(_searchQuery) || 
                                   apt.title.toLowerCase().contains(_searchQuery);
              if (!matchesSearch) {
                return false;
              }

              // 2. Property Type (Category)
              final matchesType = _activeFilters.propertyType == 'All' || 
                                 _activeFilters.propertyType == null ||
                                 apt.propertyType.toLowerCase() == _activeFilters.propertyType!.toLowerCase();
              if (!matchesType) {
                return false;
              }

              // 3. Price Range
              if (apt.price < (_activeFilters.minPrice ?? 0) || 
                  apt.price > (_activeFilters.maxPrice ?? 1000000)) {
                return false;
              }

              // 4. Bedrooms
              if (_activeFilters.bedrooms != null) {
                if (_activeFilters.bedrooms == 3) {
                  if (apt.bedrooms < 3) {
                    return false;
                  }
                } else {
                  if (apt.bedrooms != _activeFilters.bedrooms) {
                    return false;
                  }
                }
              }

              // 5. Location Filters (Province, City, Barangay)
              if (_activeFilters.province != null && 
                  !apt.location.province.toLowerCase().contains(_activeFilters.province!.toLowerCase())) {
                return false;
              }
              if (_activeFilters.city != null && 
                  !apt.location.cityMunicipality.toLowerCase().contains(_activeFilters.city!.toLowerCase())) {
                return false;
              }
              if (_activeFilters.barangay != null && 
                  !apt.location.barangay.toLowerCase().contains(_activeFilters.barangay!.toLowerCase())) {
                return false;
              }

              // 6. Features
              if (_activeFilters.isFurnished == true && !apt.isFurnished) {
                return false;
              }
              if (_activeFilters.hasParking == true && !apt.hasParking) {
                return false;
              }
              if (_activeFilters.isPetFriendly == true && !apt.isPetFriendly) {
                return false;
              }
              
              // 7. Availability
              if (_activeFilters.onlyAvailable && apt.status != 'Available') {
                return false;
              }

              return true;
            }).toList()
          : [];

        if (apartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment_rounded, size: 60, color: Colors.grey.shade200),
                const SizedBox(height: 15),
                Text('No apartments match your criteria.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: apartments.length,
          itemBuilder: (context, index) {
            return _buildApartmentCard(apartments[index]);
          },
        );
      },
    );
  }

  Widget _buildApartmentCard(ApartmentModel apt) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ApartmentDetailsScreen(apartment: apt))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 15, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  apt.imageUrls.isNotEmpty
                      ? Hero(tag: 'apt-image-${apt.id}-0', child: Image.network(apt.imageUrls.first, height: 200, width: double.infinity, fit: BoxFit.cover))
                      : Container(height: 200, width: double.infinity, color: Colors.grey.shade100, child: Icon(Icons.image, size: 50, color: Colors.grey.shade300)),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apt.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          apt.location.toString(), 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '₱ ${apt.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                            TextSpan(text: ' /month', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(apt.propertyType, style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
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
