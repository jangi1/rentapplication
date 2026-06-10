class LocationModel {
  final String province;
  final String cityMunicipality;
  final String barangay;
  final String? streetAddress;
  final String? landmark;

  LocationModel({
    required this.province,
    required this.cityMunicipality,
    required this.barangay,
    this.streetAddress,
    this.landmark,
  });

  factory LocationModel.fromMap(Map<String, dynamic> data) {
    return LocationModel(
      province: data['province'] ?? '',
      cityMunicipality: data['cityMunicipality'] ?? '',
      barangay: data['barangay'] ?? '',
      streetAddress: data['streetAddress'],
      landmark: data['landmark'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'province': province,
      'cityMunicipality': cityMunicipality,
      'barangay': barangay,
      'streetAddress': streetAddress,
      'landmark': landmark,
    };
  }

  @override
  String toString() {
    return '$barangay, $cityMunicipality, $province';
  }
}
