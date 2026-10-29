import 'dart:io';
import 'package:flutter/material.dart';
import '../services/identification_service.dart';
import '../models/observation_journal.dart';
import '../database/app_database.dart';

class IdentificationResultScreen extends StatefulWidget {
  final FullIdentificationData identificationData;
  final File imageFile;

  const IdentificationResultScreen({
    super.key,
    required this.identificationData,
    required this.imageFile,
  });

  @override
  State<IdentificationResultScreen> createState() =>
      _IdentificationResultScreenState();
}

class _IdentificationResultScreenState
    extends State<IdentificationResultScreen> {
  bool _isSaving = false;

  Future<void> _saveToJournal() async {
    setState(() => _isSaving = true);

    final gemini = widget.identificationData.geminiResult;
    final species = widget.identificationData.speciesDetails;

    final newJournal = ObservationJournal(
      speciesName:
          species?.commonName ?? gemini.commonName ?? 'Burung Tidak Dikenal',
      scientificName: species?.scientificName ?? gemini.scientificName ?? '-',
      imagePath: widget.imageFile.path,
      date: DateTime.now().toString().split('.')[0],
      location: 'Lokasi Pengamatan', // Opsional
      notes: gemini.description,
    );

    await AppDatabase.instance.insertJournal(newJournal);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil pengamatan berhasil disimpan ke Jurnal!'),
        backgroundColor: Color(0xFF1B5E20),
      ),
    );

    Navigator.pop(context); // Kembali ke halaman utama
  }

  @override
  Widget build(BuildContext context) {
    final gemini = widget.identificationData.geminiResult;
    final species = widget.identificationData.speciesDetails;

    // Tampilan jika objek BUKAN burung atau gambar tidak layak
    if (!gemini.isBird || !gemini.isImageValid) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil Identifikasi')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Identifikasi Tidak Dapat Dilanjutkan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                gemini.rejectionReason ??
                    'Gambar tidak terdeteksi sebagai burung atau kualitas foto kurang jelas.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Pindai Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilan BERHASIL Teridentifikasi
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Identifikasi Burung',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Foto Utama + Badge Prediksi
                Stack(
                  children: [
                    Image.file(
                      widget.imageFile,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Kandidat Utama AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            species?.commonName ??
                                gemini.commonName ??
                                'Tidak Diketahui',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            species?.scientificName ??
                                gemini.scientificName ??
                                '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grid Spesifikasi Ringkas
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _buildSpecCard(
                            Icons.security,
                            'Status',
                            species?.conservationStatus ?? 'LC (Risiko Rendah)',
                          ),
                          _buildSpecCard(
                            Icons.straighten,
                            'Ukuran',
                            '~25 cm (Dewasa)',
                          ),
                          _buildSpecCard(
                            Icons.forest,
                            'Habitat',
                            'Lahan Basah & Hutan',
                          ),
                          _buildSpecCard(
                            Icons.restaurant,
                            'Makanan',
                            'Serangga & Ikan',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Section Deskripsi & Ciri Fisik
                      const Text(
                        'Deskripsi & Ciri Fisik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gemini.description ??
                            'Belum ada deskripsi lengkap untuk spesies ini.',
                        style: TextStyle(color: Colors.grey[800], height: 1.4),
                      ),

                      const SizedBox(height: 20),

                      // Placeholder Wilayah Persebaran (Statik untuk MVP)
                      const Text(
                        'Wilayah Persebaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://tile.openstreetmap.org/3/4/3.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white.withOpacity(0.8),
                            child: const Text(
                              'Peta Wilayah Indonesia',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Action Bar (Pindai Ulang & Simpan)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF1B5E20)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pindai Ulang',
                        style: TextStyle(color: Color(0xFF1B5E20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveToJournal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Observasi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B5E20), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
