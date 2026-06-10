import 'package:flutter/material.dart';
import '../../models/apartment_model.dart';
import '../../models/location_model.dart';
import '../../services/database_service.dart';

class EditApartmentScreen extends StatefulWidget {
  final ApartmentModel apartment;
  const EditApartmentScreen({super.key, required this.apartment});

  @override
  State<EditApartmentScreen> createState() => _EditApartmentScreenState();
}

class _EditApartmentScreenState extends State<EditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _propertyTypeController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _floorAreaController;
  
  // Location Controllers
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _barangayController;
  late TextEditingController _streetController;
  late TextEditingController _landmarkController;

  late String _status;
  late bool _isFurnished;
  late bool _hasParking;
  late bool _isPetFriendly;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.apartment.title);
    _descriptionController = TextEditingController(text: widget.apartment.description);
    _priceController = TextEditingController(text: widget.apartment.price.toString());
    _propertyTypeController = TextEditingController(text: widget.apartment.propertyType);
    _bedroomsController = TextEditingController(text: widget.apartment.bedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.apartment.bathrooms.toString());
    _floorAreaController = TextEditingController(text: widget.apartment.floorArea.toString());
    
    _provinceController = TextEditingController(text: widget.apartment.location.province);
    _cityController = TextEditingController(text: widget.apartment.location.cityMunicipality);
    _barangayController = TextEditingController(text: widget.apartment.location.barangay);
    _streetController = TextEditingController(text: widget.apartment.location.streetAddress ?? '');
    _landmarkController = TextEditingController(text: widget.apartment.location.landmark ?? '');

    _status = widget.apartment.status;
    _isFurnished = widget.apartment.isFurnished;
    _hasParking = widget.apartment.hasParking;
    _isPetFriendly = widget.apartment.isPetFriendly;
  }

  void _updateApartment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'propertyType': _propertyTypeController.text.trim(),
        'bedrooms': int.parse(_bedroomsController.text.trim()),
        'bathrooms': int.parse(_bathroomsController.text.trim()),
        'floorArea': double.parse(_floorAreaController.text.trim()),
        'status': _status,
        'isFurnished': _isFurnished,
        'hasParking': _hasParking,
        'isPetFriendly': _isPetFriendly,
        'location': LocationModel(
          province: _provinceController.text.trim(),
          cityMunicipality: _cityController.text.trim(),
          barangay: _barangayController.text.trim(),
          streetAddress: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
          landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        ).toMap(),
      };

      await DatabaseService().updateApartment(widget.apartment.id, data);
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing updated successfully!')));
        Navigator.pop(context);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Listing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  _buildTextField(_titleController, 'Title', '2BR Apartment'),
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

                  _buildSectionHeader(Icons.update, 'Status'),
                  _buildStatusDropdown(),

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

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _updateApartment,
                      child: const Text('Update Listing', style: TextStyle(color: Colors.white, fontSize: 18)),
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

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          items: ['Available', 'Reserved', 'Rented'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _status = newValue!;
            });
          },
        ),
      ),
    );
  }
}
