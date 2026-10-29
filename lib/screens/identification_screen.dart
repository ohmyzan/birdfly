import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/identification_service.dart';
import 'identification_result_screen.dart';

class IdentificationScreen extends StatefulWidget {
  const IdentificationScreen({super.key});

  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final IdentificationService _identificationService = IdentificationService();

  // Kamera atau galeri hanya dibuka saat tombol ditekan.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (!mounted || pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Memproses identifikasi burung.
  Future<void> _analyzeBird() async {
    if (_selectedImage == null || _isLoading) return;

    final File imageFile = _selectedImage!;

    setState(() {
      _isLoading = true;
    });

    try {
      final resultData = await _identificationService.processIdentification(
        imageFile,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentificationResultScreen(
            identificationData: resultData,
            imageFile: imageFile,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Identifikasi gagal: $e'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Coba lagi', onPressed: _analyzeBird),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Identifikasi Burung',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1B5E20)),
                  SizedBox(height: 16),
                  Text(
                    'Menganalisis gambar dengan Gemini AI...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mencocokkan taksonomi di iNaturalist...',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Pilih atau ambil foto burung',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol kamera dan galeri.
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Kamera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galeri'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1B5E20),
                            side: const BorderSide(color: Color(0xFF1B5E20)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_selectedImage != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeBird,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Proses Identifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
