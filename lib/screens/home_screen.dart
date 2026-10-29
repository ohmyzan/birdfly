import 'package:flutter/material.dart';
import '../services/inaturalist_service.dart';
import '../models/bird_species.dart';
import 'species_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final INaturalistService _iNaturalistService = INaturalistService();
  List<BirdSpecies> _featuredBirds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedBirds();
  }

  Future<void> _loadFeaturedBirds() async {
    // Mengambil data burung Indonesia asli dari iNaturalist
    final birds = await _iNaturalistService.fetchBirdCatalog(
      query: 'Indonesia',
      page: 1,
    );
    if (!mounted) return;
    setState(() {
      _featuredBirds = birds.take(6).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'BirdFly',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeaturedBirds,
        color: const Color(0xFF1B5E20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Utama AI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ BirdFly AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kenali Burung di Sekitarmu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ambil foto burung liar di alam atau unggah dari galeri untuk identifikasi instan.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Jelajahi Burung
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jelajahi Burung',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    )
                  : _featuredBirds.isEmpty
                  ? const Text('Gagal memuat rekomendasi spesies.')
                  : SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _featuredBirds.length,
                        itemBuilder: (context, index) {
                          final bird = _featuredBirds[index];
                          return _buildBirdCard(context, bird);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirdCard(BuildContext context, BirdSpecies bird) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeciesDetailScreen(species: bird),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: bird.imageUrl != null
                    ? Image.network(
                        bird.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.pets, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bird.commonName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    bird.scientificName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
