import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:suiviexpress_app/data/models/user.dart';
import '../data/models/review_model.dart';
import '../data/models/product_model.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const _dbName = 'app_database.db';
  static const _dbVersion = 1;

  // ---------------- TABLE NAMES ----------------
  static const tableReviews = 'reviews';
  static const tableProducts = 'products';
    static const tableUsers = 'users';


  // ---------------- REVIEW COLUMNS ----------------
  static const columnId = 'id';
  static const columnRating = 'rating';
  static const columnComment = 'comment';
  static const columnProductId = 'productId';
  static const columnUserId = 'userId';
  static const columnCreatedAt = 'createdAt';
  static const columnSynced = 'is_synced';

  // ---------------- PRODUCT COLUMNS ----------------
  static const pColumnId = 'id';
  static const pColumnName = 'name';
  static const pColumnDescription = 'description';
  static const pColumnBrand = 'brand';
  static const pColumnCategory = 'category';
  static const pColumnPrice = 'price';
  static const pColumnDiscount = 'discount';
  static const pColumnStockQuantity = 'stockQuantity';
  static const pColumnAvailable = 'available';
  static const pColumnImageUrl = 'imageUrl';
  static const pColumnThumbnailUrl = 'thumbnailUrl';
  static const pColumnAverageRating = 'averageRating';
  static const pColumnReviewCount = 'reviewCount';
  static const pColumnVisible = 'visible';

    // ---------------- USER COLUMNS ----------------
  static const uColumnId = 'id';
  static const uColumnUsername = 'username';
  static const uColumnFirstName = 'firstName';
  static const uColumnLastName = 'lastName';
  static const uColumnEmail = 'email';
  static const uColumnPhone = 'phone';
  static const uColumnAddress = 'address';
  static const uColumnProfileImageUrl = 'profileImageUrl';
  static const uColumnRole = 'role';
  static const uColumnEnabled = 'enabled';
  static const uColumnLocked = 'locked';
  static const uColumnPassword = 'password';
  static const uColumnSynced = 'is_synced';

  // ---------------- DATABASE INIT ----------------
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
    // Reviews table
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

    // Products table
    await db.execute('''
      CREATE TABLE $tableProducts (
        $pColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $pColumnName TEXT NOT NULL,
        $pColumnDescription TEXT NOT NULL,
        $pColumnBrand TEXT NOT NULL,
        $pColumnCategory TEXT NOT NULL,
        $pColumnPrice REAL NOT NULL,
        $pColumnDiscount REAL NOT NULL,
        $pColumnStockQuantity INTEGER NOT NULL,
        $pColumnAvailable INTEGER NOT NULL,
        $pColumnImageUrl TEXT NOT NULL,
        $pColumnThumbnailUrl TEXT NOT NULL,
        $pColumnAverageRating REAL NOT NULL,
        $pColumnReviewCount INTEGER NOT NULL,
        $pColumnVisible INTEGER NOT NULL,
        $columnSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE $tableUsers (
        $uColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $uColumnUsername TEXT NOT NULL,
        $uColumnFirstName TEXT NOT NULL,
        $uColumnLastName TEXT NOT NULL,
        $uColumnEmail TEXT NOT NULL,
        $uColumnPhone TEXT,
        $uColumnAddress TEXT,
        $uColumnProfileImageUrl TEXT,
        $uColumnRole TEXT NOT NULL,
        $uColumnEnabled INTEGER NOT NULL DEFAULT 1,
        $uColumnLocked INTEGER NOT NULL DEFAULT 0,
        $uColumnPassword TEXT,
        $uColumnSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here if needed
  }

  // ===================== REVIEWS CRUD =====================
  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert(
      tableReviews,
      {
        columnRating: review.rating,
        columnComment: review.comment,
        columnProductId: review.productId,
        columnUserId: review.userId,
        columnCreatedAt: review.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        columnSynced: review.synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

Future<List<Review>> getAllReviews() async {
  final db = await database;
  final result = await db.query(
    tableReviews,
    orderBy: '$columnId DESC',
  );

  return result.map((map) => Review(
        id: map[columnId] as int?,
        rating: map[columnRating] as int,
        comment: map[columnComment] as String,
        productId: map[columnProductId] as int,
        userId: map[columnUserId] as int,
        createdAt: DateTime.tryParse(map[columnCreatedAt] as String? ?? ''),
        synced: (map[columnSynced] as int) == 1,
      )).toList();
}

  Future<List<Review>> getUnsyncedReviews() async {
    final db = await database;
    final result =
        await db.query(tableReviews, where: '$columnSynced = ?', whereArgs: [0]);
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
    return await db.delete(tableReviews, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> markReviewAsSynced(int id) async {
    final db = await database;
    await db.update(tableReviews, {columnSynced: 1},
        where: '$columnId = ?', whereArgs: [id]);
  }

  // ===================== PRODUCTS CRUD =====================
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      tableProducts,
      {
        pColumnName: product.name,
        pColumnDescription: product.description,
        pColumnBrand: product.brand,
        pColumnCategory: product.category,
        pColumnPrice: product.price,
        pColumnDiscount: product.discount,
        pColumnStockQuantity: product.stockQuantity,
        pColumnAvailable: product.available ? 1 : 0,
        pColumnImageUrl: product.imageUrl,
        pColumnThumbnailUrl: product.thumbnailUrl,
        pColumnAverageRating: product.averageRating,
        pColumnReviewCount: product.reviewCount,
        pColumnVisible: product.visible ? 1 : 0,
        columnSynced: product.synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query(tableProducts, orderBy: '$pColumnId DESC');
    return result.map((map) => Product(
      id: map[pColumnId] as int?,
      name: map[pColumnName] as String,
      description: map[pColumnDescription] as String,
      brand: map[pColumnBrand] as String,
      category: map[pColumnCategory] as String,
      price: (map[pColumnPrice] as num).toDouble(),
      discount: (map[pColumnDiscount] as num).toDouble(),
      stockQuantity: map[pColumnStockQuantity] as int,
      available: (map[pColumnAvailable] as int) == 1,
      imageUrl: map[pColumnImageUrl] as String,
      thumbnailUrl: map[pColumnThumbnailUrl] as String,
      averageRating: (map[pColumnAverageRating] as num).toDouble(),
      reviewCount: map[pColumnReviewCount] as int,
      visible: (map[pColumnVisible] as int) == 1,
      synced: (map[columnSynced] as int) == 1,
    )).toList();
  }

  Future<List<Product>> getUnsyncedProducts() async {
    final db = await database;
    final result = await db.query(
      tableProducts,
      where: '$columnSynced = ?',
      whereArgs: [0],
    );
    return result.map((map) => Product(
      id: map[pColumnId] as int?,
      name: map[pColumnName] as String,
      description: map[pColumnDescription] as String,
      brand: map[pColumnBrand] as String,
      category: map[pColumnCategory] as String,
      price: (map[pColumnPrice] as num).toDouble(),
      discount: (map[pColumnDiscount] as num).toDouble(),
      stockQuantity: map[pColumnStockQuantity] as int,
      available: (map[pColumnAvailable] as int) == 1,
      imageUrl: map[pColumnImageUrl] as String,
      thumbnailUrl: map[pColumnThumbnailUrl] as String,
      averageRating: (map[pColumnAverageRating] as num).toDouble(),
      reviewCount: map[pColumnReviewCount] as int,
      visible: (map[pColumnVisible] as int) == 1,
      synced: false,
    )).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      tableProducts,
      {
        pColumnName: product.name,
        pColumnDescription: product.description,
        pColumnBrand: product.brand,
        pColumnCategory: product.category,
        pColumnPrice: product.price,
        pColumnDiscount: product.discount,
        pColumnStockQuantity: product.stockQuantity,
        pColumnAvailable: product.available ? 1 : 0,
        pColumnImageUrl: product.imageUrl,
        pColumnThumbnailUrl: product.thumbnailUrl,
        pColumnAverageRating: product.averageRating,
        pColumnReviewCount: product.reviewCount,
        pColumnVisible: product.visible ? 1 : 0,
        columnSynced: product.synced ? 1 : 0,
      },
      where: '$pColumnId = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(tableProducts, where: '$pColumnId = ?', whereArgs: [id]);
  }

  Future<void> markProductAsSynced(int id) async {
    final db = await database;
    await db.update(tableProducts, {columnSynced: 1},
        where: '$pColumnId = ?', whereArgs: [id]);
  }

  Future<void> clearProducts() async {
    final db = await database;
    await db.delete(tableProducts);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

   // ===================== USERS CRUD =====================
  Future<int> insertUser(User user, {bool synced = false}) async {
    final db = await database;
    return await db.insert(
      tableUsers,
      {
        uColumnUsername: user.username,
        uColumnFirstName: user.firstName,
        uColumnLastName: user.lastName,
        uColumnEmail: user.email,
        uColumnPhone: user.phone,
        uColumnAddress: user.address,
        uColumnProfileImageUrl: user.profileImageUrl,
        uColumnRole: user.role,
        uColumnEnabled: user.enabled ? 1 : 0,
        uColumnLocked: user.locked ? 1 : 0,
        uColumnPassword: user.password,
        uColumnSynced: synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

Future<List<User>> getUnsyncedUsers() async {
  final db = await database;
  final result = await db.query(
    tableUsers,
    where: '$uColumnSynced = ?',
    whereArgs: [0],
  );

  return result.map((map) => User(
        id: map[uColumnId] as int,
        username: map[uColumnUsername] as String,
        firstName: map[uColumnFirstName] as String,
        lastName: map[uColumnLastName] as String,
        email: map[uColumnEmail] as String,
        phone: map[uColumnPhone] as String?,
        address: map[uColumnAddress] as String?,
        profileImageUrl: map[uColumnProfileImageUrl] as String?,
        role: map[uColumnRole] as String,
        enabled: (map[uColumnEnabled] as int) == 1,
        locked: (map[uColumnLocked] as int) == 1,
        password: map[uColumnPassword] as String?,
      )).toList();
}


  Future<void> markUserAsSynced(int id) async {
    final db = await database;
    await db.update(tableUsers, {uColumnSynced: 1},
        where: '$uColumnId = ?', whereArgs: [id]);
  }
}
