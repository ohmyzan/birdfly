import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/observation_journal.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('birdfly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Jurnal Pengamatan
    await db.execute('''
      CREATE TABLE observation_journal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        species_name TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        image_path TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        notes TEXT
      )
    ''');

    // Tabel Profil Lokal (Hanya 1 Baris Data)
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        avatar_path TEXT
      )
    ''');

    // Memasukkan data profil bawaan
    await db.insert('user_profile', {
      'id': 1,
      'name': 'Pengguna BirdFly',
      'role': 'Pengamat Burung Pemula',
      'avatar_path': null,
    });
  }

  // ==============================
  // FUNGSI JURNAL PENGAMATAN
  // ==============================

  // Menambahkan jurnal baru
  Future<int> insertJournal(ObservationJournal journal) async {
    final db = await instance.database;
    return await db.insert('observation_journal', journal.toMap());
  }

  // Mengambil semua riwayat jurnal
  Future<List<ObservationJournal>> getAllJournals() async {
    final db = await instance.database;

    final result = await db.query('observation_journal', orderBy: 'id DESC');

    return result.map((json) => ObservationJournal.fromMap(json)).toList();
  }

  // Menghapus jurnal berdasarkan ID
  Future<int> deleteJournal(int id) async {
    final db = await instance.database;

    return await db.delete(
      'observation_journal',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==============================
  // FUNGSI PROFIL PENGGUNA LOKAL
  // ==============================

  // Mengambil data profil lokal
  Future<Map<String, dynamic>> getProfile() async {
    final db = await instance.database;

    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    // Nilai cadangan jika data profil belum tersedia
    return {
      'id': 1,
      'name': 'Pengguna BirdFly',
      'role': 'Pengamat Burung Pemula',
      'avatar_path': null,
    };
  }

  // Memperbarui data profil lokal
  Future<int> updateProfile(
    String name,
    String role,
    String? avatarPath,
  ) async {
    final db = await instance.database;

    return await db.update(
      'user_profile',
      {'name': name, 'role': role, 'avatar_path': avatarPath},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
