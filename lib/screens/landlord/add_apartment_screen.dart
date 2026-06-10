import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../models/location_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class AddApartmentScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  const AddApartmentScreen({super.key, this.onSuccess});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _propertyTypeController = TextEditingController(text: 'Apartment');
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorAreaController = TextEditingController();
  
  // Location Controllers
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();

  final String _availability = 'Available';
  bool _isFurnished = false;
  bool _hasParking = false;
  bool _isPetFriendly = false;

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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = Provider.of<UserProvider>(context, listen: false).user;
      
      ApartmentModel newApt = ApartmentModel(
        id: '',
        landlordId: user!.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        propertyType: _propertyTypeController.text.trim(),
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        floorArea: double.parse(_floorAreaController.text.trim()),
        amenities: _selectedAmenities,
        imageUrls: [],
        status: _availability,
        createdAt: DateTime.now(),
        location: LocationModel(
          province: _provinceController.text.trim(),
          cityMunicipality: _cityController.text.trim(),
          barangay: _barangayController.text.trim(),
          streetAddress: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
          landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        ),
        isFurnished: _isFurnished,
        hasParking: _hasParking,
        isPetFriendly: _isPetFriendly,
        contactNumber: user.contactNumber,
      );

      await DatabaseService().addApartment(newApt, _images);
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing published successfully!')));
        if (widget.onSuccess != null) {
          widget.onSuccess!();
          // Reset form
          _titleController.clear();
          _descriptionController.clear();
          _priceController.clear();
          _bedroomsController.clear();
          _bathroomsController.clear();
          _floorAreaController.clear();
          _provinceController.clear();
          _cityController.clear();
          _barangayController.clear();
          _streetController.clear();
          _landmarkController.clear();
          setState(() {
            _images = [];
            _selectedAmenities.clear();
          });
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.onSuccess != null ? null : IconButton(
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
                  _buildSectionHeader(Icons.info_outline, 'Basic Details'),
                  _buildTextField(_titleController, 'Title', '2BR Apartment in Ecoland'),
                  _buildTextField(_priceController, 'Monthly Rent', '12000', keyboardType: TextInputType.number),
                  _buildTextField(_descriptionController, 'Description', 'Describe your property...', maxLines: 3),
                  
                  _buildSectionHeader(Icons.location_on_outlined, 'Location'),
                  _buildTextField(_provinceController, 'Province', 'Davao del Sur'),
                  _buildTextField(_cityController, 'City/Municipality', 'Davao City'),
                  _buildTextField(_barangayController, 'Barangay', 'Ecoland'),
                  _buildTextField(_streetController, 'Street Address (Optional)', 'Street name, House #'),
                  
                  _buildSectionHeader(Icons.home_work_outlined, 'Property Specs'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_bedroomsController, 'Bedrooms', '2', keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_bathroomsController, 'Bathrooms', '1', keyboardType: TextInputType.number)),
                    ],
                  ),
                  _buildTextField(_floorAreaController, 'Floor Area (sqm)', '60', keyboardType: TextInputType.number),
                  _buildTextField(_propertyTypeController, 'Property Type', 'Apartment'),

                  _buildSectionHeader(Icons.featured_play_list_outlined, 'Features'),
                  SwitchListTile(
                    title: const Text('Furnished'),
                    value: _isFurnished,
                    onChanged: (val) => setState(() => _isFurnished = val),
                  ),
                  SwitchListTile(
                    title: const Text('Parking Available'),
                    value: _hasParking,
                    onChanged: (val) => setState(() => _hasParking = val),
                  ),
                  SwitchListTile(
                    title: const Text('Pet-Friendly'),
                    value: _isPetFriendly,
                    onChanged: (val) => setState(() => _isPetFriendly = val),
                  ),

                  _buildSectionHeader(Icons.star_outline, 'Amenities'),
                  Wrap(
                    spacing: 8,
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
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader(Icons.image_outlined, 'Photos'),
                  if (_images.isEmpty)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images.map((file) => Image.file(file, width: 80, height: 80, fit: BoxFit.cover)).toList(),
                    ),

                  const SizedBox(height: 30),
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
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}
