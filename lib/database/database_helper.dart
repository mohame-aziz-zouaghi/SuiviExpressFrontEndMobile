import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/review_model.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const _dbName = 'app_database.db';
  static const _dbVersion = 1;

  // Table names
  static const tableReviews = 'reviews';

  // Review Columns
  static const columnId = 'id';
  static const columnRating = 'rating';
  static const columnComment = 'comment';
  static const columnProductId = 'productId';
  static const columnUserId = 'userId';
  static const columnCreatedAt = 'createdAt';
  static const columnSynced = 'is_synced';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create table for reviews
    await db.execute('''
      CREATE TABLE $tableReviews (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRating INTEGER NOT NULL,
        $columnComment TEXT NOT NULL,
        $columnProductId INTEGER NOT NULL,
        $columnUserId INTEGER NOT NULL,
        $columnCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        $columnSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic
  }

  // =====================
  // CRUD for Reviews
  // =====================

  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert(tableReviews, {
      columnRating: review.rating,
      columnComment: review.comment,
      columnProductId: review.productId,
      columnUserId: review.userId,
      columnCreatedAt:
          review.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      columnSynced: 0, // mark as unsynced initially
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Review>> getAllReviews() async {
    final db = await database;
    final result = await db.query(tableReviews, orderBy: '$columnId DESC');
    return result.map((json) => Review.fromJson(json)).toList();
  }

  Future<List<Review>> getUnsyncedReviews() async {
    final db = await database;
    final result = await db.query(
      tableReviews,
      where: '$columnSynced = ?',
      whereArgs: [0],
    );
    return result.map((json) => Review.fromJson(json)).toList();
  }

  Future<int> updateReview(Review review) async {
    final db = await database;
    return await db.update(
      tableReviews,
      review.toJson(),
      where: '$columnId = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(int id) async {
    final db = await database;
    return await db.delete(
      tableReviews,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> markReviewAsSynced(int id) async {
    final db = await database;
    await db.update(
      tableReviews,
      {columnSynced: 1},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearReviews() async {
    final db = await database;
    await db.delete(tableReviews);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
