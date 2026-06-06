import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class AddApartmentScreen extends StatefulWidget {
  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorAreaController = TextEditingController();
  final _propertyTypeController = TextEditingController(text: 'Apartment');
  final _contactController = TextEditingController();
  
  String _availability = 'Available';
  final List<String> _selectedAmenities = [];
  final List<String> _amenityOptions = [
    'Wi-Fi', 'Parking', 'Air Conditioning', 'Balcony', 
    'Kitchen', 'Security', 'Laundry Area'
  ];

  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images = selectedImages.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  void _saveApartment() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      setState(() => _isLoading = true);
      final user = Provider.of<UserProvider>(context, listen: false).user;
      
      ApartmentModel newApt = ApartmentModel(
        id: '',
        landlordId: user!.uid,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        floorArea: double.parse(_floorAreaController.text.trim()),
        propertyType: _propertyTypeController.text.trim(),
        amenities: _selectedAmenities,
        contactNumber: user.contactNumber, // Using landlord's registered contact
        imageUrls: [],
        status: _availability,
        createdAt: DateTime.now(),
      );

      await DatabaseService().addApartment(newApt, _images);
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing published successfully!')));
        Navigator.pop(context);
      }
    } else if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload at least one photo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Listing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormRow(Icons.sell_outlined, 'Title', _titleController, '2BR Apartment in Ecoland, Davao City'),
                  _buildFormRow(Icons.payments_outlined, 'Price (per month)', _priceController, '12000', keyboardType: TextInputType.number),
                  _buildFormRow(Icons.location_on_outlined, 'Location', _locationController, 'Ecoland, Davao City'),
                  
                  _buildSectionHeader(Icons.description_outlined, 'Description'),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, bottom: 20),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your apartment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(child: _buildFormRow(Icons.bed_outlined, 'Bedrooms', _bedroomsController, '2', keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildFormRow(Icons.bathtub_outlined, 'Bathrooms', _bathroomsController, '1', keyboardType: TextInputType.number)),
                    ],
                  ),

                  _buildFormRow(Icons.square_foot_outlined, 'Floor Area (sqm)', _floorAreaController, '68', keyboardType: TextInputType.number),
                  _buildFormRow(Icons.home_work_outlined, 'Property Type', _propertyTypeController, 'Apartment'),

                  _buildSectionHeader(Icons.calendar_today_outlined, 'Availability'),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _availability,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  _buildSectionHeader(Icons.star_outline, 'Amenities'),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, bottom: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _amenityOptions.map((amenity) {
                        final isSelected = _selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                          selectedColor: Colors.blue[50],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(color: isSelected ? Colors.blue : Colors.black87, fontSize: 12),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: isSelected ? Colors.blue : Colors.grey[300]!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  _buildSectionHeader(Icons.image_outlined, 'Images'),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_images.isEmpty)
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Icon(Icons.add_a_photo_outlined, color: Colors.blue),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._images.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  File file = entry.value;
                                  String name = file.path.split('/').last;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '• $name${idx == 0 ? " (Main)" : ""}',
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                TextButton(onPressed: _pickImages, child: const Text('Change Photos')),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveApartment,
                      child: const Text('Publish Listing', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D47A1), size: 24),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFormRow(IconData icon, String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF0D47A1), size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54))),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                      ),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
