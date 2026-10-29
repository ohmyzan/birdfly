import 'package:flutter/material.dart';
import '../models/bird_species.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final BirdSpecies species;
  final String? description;
  final String? length;
  final String? habitat;
  final String? diet;

  const SpeciesDetailScreen({
    super.key,
    required this.species,
    this.description,
    this.length,
    this.habitat,
    this.diet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          species.commonName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Utama dengan Gradient Overlay & Nama
            Stack(
              children: [
                if (species.imageUrl != null)
                  Image.network(
                    species.imageUrl!,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 260,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 260,
                    color: Colors.grey[200],
                    child: const Icon(Icons.pets, size: 60, color: Colors.grey),
                  ),
                Container(
                  height: 260,
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
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species.commonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        species.scientificName,
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
                  // 2. Grid Spesifikasi Ringkas (Status, Ukuran, Habitat, Makanan)
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
                        'Status Konservasi',
                        species.conservationStatus ?? 'LC (Risiko Rendah)',
                      ),
                      _buildSpecCard(
                        Icons.straighten,
                        'Panjang Tubuh',
                        length ?? '~20 - 30 cm (Dewasa)',
                      ),
                      _buildSpecCard(
                        Icons.forest,
                        'Habitat Utama',
                        habitat ?? 'Hutan & Lahan Basah',
                      ),
                      _buildSpecCard(
                        Icons.restaurant,
                        'Makanan Utama',
                        diet ?? 'Serangga & Ikan Kecil',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. Deskripsi & Ciri Fisik
                  const Text(
                    'Deskripsi & Ciri Fisik',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description ??
                        '${species.commonName} (${species.scientificName}) merupakan spesies burung yang tercatat dalam data biodiversitas Indonesia. Burung ini memiliki peranan penting dalam menjaga keseimbangan ekosistem dan keanekaragaman hayati wilayah jelajahnya.',
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // 4. Wilayah Persebaran
                  const Text(
                    'Wilayah Persebaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 140,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Wilayah Persebaran Indonesia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
