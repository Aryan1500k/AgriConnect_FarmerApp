import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Farmer {
  final int? id;
  final String name;
  final String mobile;
  final String pincode;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String cropName;
  final String harvestingDate;
  final double acreage;
  final double distanceKm;

  Farmer({
    this.id,
    required this.name,
    required this.mobile,
    required this.pincode,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.cropName,
    required this.harvestingDate,
    required this.acreage,
    required this.distanceKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'pincode': pincode,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'cropName': cropName,
      'harvestingDate': harvestingDate,
      'acreage': acreage,
      'distanceKm': distanceKm,
    };
  }

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      name: map['name'],
      mobile: map['mobile'],
      pincode: map['pincode'],
      state: map['state'],
      district: map['district'],
      taluka: map['taluka'],
      village: map['village'],
      cropName: map['cropName'],
      harvestingDate: map['harvestingDate'],
      acreage: map['acreage'],
      distanceKm: map['distanceKm'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('farmers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE farmers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      mobile TEXT,
      pincode TEXT,
      state TEXT,
      district TEXT,
      taluka TEXT,
      village TEXT,
      cropName TEXT,
      harvestingDate TEXT,
      acreage REAL,
      distanceKm REAL
    )
    '''); // Implements storage requirement
  }

  Future<int> createFarmer(Farmer farmer) async {
    final db = await instance.database;
    return await db.insert('farmers', farmer.toMap());
  }

  Future<List<Farmer>> readAllFarmers() async {
    final db = await instance.database;
    final result = await db.query('farmers');
    return result.map((json) => Farmer.fromMap(json)).toList();
  }
}