import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/identification_result.dart';

class GeminiService {
  // Daftar model cadangan jika salah satu model sedang padat (High Demand)
  final List<String> _candidateModels = [
    'gemini-2.5-flash',
    'gemini-3.5-flash',
    'gemini-1.5-pro',
  ];

  Future<IdentificationResult> analyzeImage(File imageFile) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return IdentificationResult(
        isBird: false,
        isImageValid: false,
        rejectionReason: 'API Key Gemini tidak ditemukan di berkas .env.',
      );
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = '''
      Analisis gambar ini. Kamu adalah ahli ornitologi Indonesia.
      Kembalikan data dalam format JSON murni tanpa tambahan teks lain dengan struktur:
      {
        "is_bird": true/false,
        "is_image_valid": true/false,
        "common_name": "Nama Indonesia/Umum Burung",
        "scientific_name": "Nama Latin/Ilmiah",
        "description": "Ciri fisik dan karakteristik singkat burung ini",
        "rejection_reason": "Alasan jika gambar bukan burung atau foto buram"
      }
      ''';

      http.Response? lastResponse;

      for (final model in _candidateModels) {
        final url =
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

        // Coba hingga 2 kali per model jika server sibuk
        for (int attempt = 0; attempt < 2; attempt++) {
          if (attempt > 0) {
            await Future.delayed(
              const Duration(seconds: 2),
            ); // Jeda 2 detik sebelum retry
          }

          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                    {
                      "inline_data": {
                        "mime_type": "image/jpeg",
                        "data": base64Image,
                      },
                    },
                  ],
                },
              ],
              "generationConfig": {"response_mime_type": "application/json"},
            }),
          );

          lastResponse = response;

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final rawText =
                data['candidates'][0]['content']['parts'][0]['text'];
            final jsonMap = jsonDecode(rawText);

            return IdentificationResult.fromJson(jsonMap);
          }

          // Jika bukan error server sibuk (503/429), langsung pindah ke model berikutnya
          if (response.statusCode != 503 && response.statusCode != 429) {
            break;
          }
        }
      }

      final errBody = lastResponse != null ? jsonDecode(lastResponse.body) : {};
      final errMsg =
          errBody['error']?['message'] ??
          'Server Gemini sedang padat. Silakan coba sebentar lagi.';
      return IdentificationResult(
        isBird: false,
        isImageValid: false,
        rejectionReason: 'Gagal terhubung ke Gemini API: $errMsg',
      );
    } catch (e) {
      return IdentificationResult(
        isBird: false,
        isImageValid: false,
        rejectionReason: 'Terjadi kesalahan sistem: $e',
      );
    }
  }
}
