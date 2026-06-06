class FavoriteModel {
  final String id;
  final String tenantId;
  final String apartmentId;

  FavoriteModel({
    required this.id,
    required this.tenantId,
    required this.apartmentId,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> data, String id) {
    return FavoriteModel(
      id: id,
      tenantId: data['tenantId'] ?? '',
      apartmentId: data['apartmentId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'apartmentId': apartmentId,
    };
  }
}
