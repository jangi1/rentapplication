import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _currentRangeValues = const RangeValues(2000, 20000);
  String _selectedPropertyType = 'All';
  String _selectedBedrooms = 'All';
  
  final List<String> _propertyTypes = ['All', 'Condo', 'Apartment', 'Studio', 'House'];
  final List<String> _bedroomTypes = ['Studio', '1 BR', '2 BR', '3+ BR'];
  final Map<String, bool> _amenities = {
    'Wi-Fi': false,
    'Parking': false,
    'Air Conditioning': false,
    'Furnished': false,
  };

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
        title: const Text('Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentRangeValues = const RangeValues(2000, 20000);
                _selectedPropertyType = 'All';
                _selectedBedrooms = 'All';
                _amenities.updateAll((key, value) => false);
              });
            },
            child: const Text('Reset', style: TextStyle(color: Color(0xFF1E88E5))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Price Range'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₱ ${_currentRangeValues.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('₱ ${_currentRangeValues.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 50000,
              divisions: 50,
              activeColor: const Color(0xFF1E88E5),
              inactiveColor: Colors.blue.withOpacity(0.1),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Property Type'),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: _propertyTypes.map((type) => _buildChoiceChip(type, _selectedPropertyType, (val) {
                setState(() => _selectedPropertyType = val);
              })).toList(),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Bedrooms'),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: _bedroomTypes.map((type) => _buildChoiceChip(type, _selectedBedrooms, (val) {
                setState(() => _selectedBedrooms = val);
              })).toList(),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Amenities'),
            const SizedBox(height: 10),
            ..._amenities.keys.map((key) => CheckboxListTile(
                  title: Text(key),
                  value: _amenities[key],
                  activeColor: const Color(0xFF1E88E5),
                  onChanged: (val) {
                    setState(() => _amenities[key] = val!);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(context, _currentRangeValues.end);
            },
            child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildChoiceChip(String label, String selectedValue, Function(String) onSelected) {
    bool isSelected = label == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) onSelected(label);
      },
      selectedColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[200]!),
      ),
    );
  }
}
