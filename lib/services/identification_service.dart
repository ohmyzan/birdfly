import 'dart:io';
import 'gemini_service.dart';
import 'inaturalist_service.dart';
import '../models/identification_result.dart';
import '../models/bird_species.dart';

class FullIdentificationData {
  final IdentificationResult geminiResult;
  final BirdSpecies? speciesDetails;

  FullIdentificationData({required this.geminiResult, this.speciesDetails});
}

class IdentificationService {
  final GeminiService _geminiService = GeminiService();
  final INaturalistService _iNaturalistService = INaturalistService();

  Future<FullIdentificationData> processIdentification(File imageFile) async {
    // 1. Analisis foto menggunakan Gemini API
    final geminiResult = await _geminiService.analyzeImage(imageFile);

    // 2. Jika bukan burung atau foto tidak valid, kembalikan hasil penolakan
    if (!geminiResult.isBird ||
        !geminiResult.isImageValid ||
        geminiResult.scientificName == null) {
      return FullIdentificationData(geminiResult: geminiResult);
    }

    // 3. Ambil data taksonomi pendukung dari iNaturalist API
    final speciesDetails = await _iNaturalistService.searchByScientificName(
      geminiResult.scientificName!,
    );

    return FullIdentificationData(
      geminiResult: geminiResult,
      speciesDetails: speciesDetails,
    );
  }
}
