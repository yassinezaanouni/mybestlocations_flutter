class Location {
  final int id;
  final String pseudo;
  final double longitude;
  final double latitude;
  final String numero;
  final String category;

  Location({
    required this.id,
    required this.pseudo,
    required this.longitude,
    required this.latitude,
    required this.numero,
    this.category = '',
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: int.parse(json['id']),
      pseudo: json['pseudo'] ?? '',
      longitude: double.parse(json['longitude'].toString()),
      latitude: double.parse(json['latitude'].toString()),
      numero: json['numero'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
