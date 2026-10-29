import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bird_species.dart';

class INaturalistService {
  static const String _baseUrl = 'https://api.inaturalist.org/v1';

  /// Mencari detail spesies berdasarkan nama ilmiah hasil prediksi Gemini
  Future<BirdSpecies?> searchByScientificName(String scientificName) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/taxa?q=${Uri.encodeComponent(scientificName)}&rank=species&per_page=1',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          return BirdSpecies.fromJson(results.first);
        }
      }
      return null;
    } catch (e) {
      print('Error memanggil iNaturalist API: $e');
      return null;
    }
  }

  /// Mengambil daftar spesies burung untuk Katalog (Taxon ID 3 = Aves/Burung)
  Future<List<BirdSpecies>> fetchBirdCatalog({
    String query = '',
    int page = 1,
  }) async {
    try {
      final String endpoint = query.isEmpty
          ? '$_baseUrl/taxa?taxon_id=3&rank=species&per_page=20&page=$page'
          : '$_baseUrl/taxa?taxon_id=3&q=${Uri.encodeComponent(query)}&rank=species&per_page=20&page=$page';

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        return results.map((json) => BirdSpecies.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error mengambil katalog iNaturalist: $e');
      return [];
    }
  }
}
