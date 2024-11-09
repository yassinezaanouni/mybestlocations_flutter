import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location.dart';

class LocationService {
  static const String baseUrl =
      'https://672e4812229a881691ef992a.mockapi.io/api/locations';

  Future<List<Location>> fetchLocations() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Location.fromJson(data)).toList();
    }
    throw Exception('Failed to load locations');
  }

  Future<Location> addLocation(String pseudo, String numero, double latitude,
      double longitude, String category) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pseudo': pseudo,
        'numero': numero,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
      }),
    );

    if (response.statusCode == 201) {
      return Location.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to add location');
  }

  Future<Location> updateLocation(
      int id, String pseudo, String numero, String category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pseudo': pseudo,
        'numero': numero,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      return Location.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update location');
  }

  Future<void> deleteLocation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete location');
    }
  }
}
