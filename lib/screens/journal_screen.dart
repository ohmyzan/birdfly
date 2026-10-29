import 'dart:io';
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/observation_journal.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => JournalScreenState();
}

class JournalScreenState extends State<JournalScreen> {
  // Fungsi publik agar dapat dipanggil dari MainNavigationScreen saat tab dipilih
  Future<void> refreshJournals() async {
    setState(() {});
  }

  Future<void> _deleteJournal(int id) async {
    await AppDatabase.instance.deleteJournal(id);
    refreshJournals();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan observasi berhasil dihapus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Observasi Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        // Action tombol refresh di kanan atas sudah dihapus
      ),
      body: RefreshIndicator(
        onRefresh: refreshJournals,
        color: const Color(0xFF1B5E20),
        child: FutureBuilder<List<ObservationJournal>>(
          future: AppDatabase.instance.getAllJournals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}'),
              );
            }

            final journals = snapshot.data ?? [];

            if (journals.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum Ada Jurnal Observasi',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Foto burung yang kamu simpan setelah proses identifikasi akan muncul di sini secara otomatis.',
                              style: TextStyle(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final item = journals[index];
                final isHero = index == 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isHero ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.file(
                            File(item.imagePath),
                            height: isHero ? 200 : 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              onSelected: (value) {
                                if (value == 'delete' && item.id != null) {
                                  _deleteJournal(item.id!);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus Jurnal',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.speciesName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.scientificName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                            if (item.notes != null &&
                                item.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '"${item.notes}"',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                            if (item.location != null &&
                                item.location!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Color(0xFF1B5E20),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.location!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
