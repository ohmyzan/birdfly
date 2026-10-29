import 'package:flutter/material.dart';
import '../database/app_database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {
    'name': 'Pengguna BirdFly',
    'role': 'Pengamat Burung Pemula',
  };
  int _totalJournals = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await AppDatabase.instance.getProfile();
    final journals = await AppDatabase.instance.getAllJournals();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _totalJournals = journals.length;
    });
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _profile['name']);
    final roleController = TextEditingController(text: _profile['role']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil Lokal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Status / Peran'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AppDatabase.instance.updateProfile(
                nameController.text,
                roleController.text,
                null,
              );
              if (!mounted) return;
              Navigator.pop(context);
              _loadProfileData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1B5E20),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              _profile['name'] ?? 'Pengguna',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _profile['role'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Profil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1B5E20),
                side: const BorderSide(color: Color(0xFF1B5E20)),
              ),
            ),
            const SizedBox(height: 24),

            // Card Statistik
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Identifikasi Sukses',
                    '$_totalJournals',
                    Icons.center_focus_strong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Penyimpanan',
                    'Lokal',
                    Icons.sd_storage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Pengaturan Tambahan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.language, 'Bahasa', 'Indonesia'),
                  const Divider(height: 1),
                  _buildMenuItem(
                    Icons.info_outline,
                    'Tentang BirdFly',
                    'Versi 1.0.0 (MVP)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1B5E20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1B5E20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
