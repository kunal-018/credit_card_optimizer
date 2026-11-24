import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/card_model.dart';
import '../models/payment_record.dart';

class DatabaseHelper {
 
static final DatabaseHelper instance = DatabaseHelper._init();

DatabaseHelper._init();

static Database? _database;
Future<Database> get database async {
  if (_database != null) return _database!;

  _database = await _initDB('cards.db');

  return _database!;
}
Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();

  final path = join(dbPath, filePath);

  return await openDatabase(
    path,
    version: 3,
    onCreate: _createDB,
      onUpgrade: _upgradeDB,
  );
}
Future _createDB(Database db, int version) async {
  await db.execute('''
CREATE TABLE cards(
id INTEGER PRIMARY KEY AUTOINCREMENT,
cardName TEXT NOT NULL,
billingDay INTEGER NOT NULL,
dueDay INTEGER NOT NULL,
bankName TEXT NOT NULL,
network TEXT NOT NULL,
cardColor TEXT NOT NULL,
last4Digits TEXT NOT NULL
)
''');
await db.execute('''CREATE TABLE payments(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cardId INTEGER NOT NULL,
  dueDate TEXT NOT NULL,
  isPaid INTEGER NOT NULL DEFAULT 0,
  paidDate TEXT,
  UNIQUE(cardId, dueDate)
)''');
await db.execute('''
CREATE TABLE notification_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cardId INTEGER NOT NULL,
  dueDate TEXT NOT NULL,
  reminderDay INTEGER NOT NULL,
  sentAt TEXT NOT NULL,
  UNIQUE(cardId, dueDate, reminderDay)
)
''');
}
Future<void> _upgradeDB(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 3) {
    await db.execute('''
      CREATE TABLE notification_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cardId INTEGER NOT NULL,
        dueDate TEXT NOT NULL,
        reminderDay INTEGER NOT NULL,
        sentAt TEXT NOT NULL,
        UNIQUE(cardId, dueDate, reminderDay)
      )
    ''');
  }
}
Future<int> insertCard(CardModel card) async {
  final db = await instance.database;

  return await db.insert(
    'cards',
    card.toMap(),
    
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
Future<int> updateCard(CardModel card) async {
  final db = await database;

  return await db.update(
    'cards',
    card.toMap(),
    where: 'id = ?',
    whereArgs: [card.id],
  );
}
Future<int> deleteCard(int id) async {
  final db = await database;

  return await db.delete(
    'cards',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<List<CardModel>> getAllCards() async {
  final db = await instance.database;

  final result = await db.query(
    'cards',
    orderBy: 'cardName ASC',
  );

  return result.map((map) => CardModel.fromMap(map)).toList();
}
Future<int> insertPayment(PaymentRecord payment) async {
  final db = await database;

  return await db.insert(
    'payments',
    payment.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
    
  );
}
Future<List<PaymentRecord>> getAllPayments() async {
  final db = await database;

  final maps = await db.query('payments');

  return maps
      .map((e) => PaymentRecord.fromMap(e))
      .toList();
}
Future<PaymentRecord?> getPayment(
  int cardId,
  DateTime dueDate,
) async {
  final db = await database;

  final result = await db.query(
    'payments',
    where: 'cardId = ? AND dueDate = ?',
    whereArgs: [
      cardId,
      dueDate.toIso8601String(),
    ],
  );

  if (result.isEmpty) return null;

  return PaymentRecord.fromMap(result.first);
}
Future<void> updatePaymentStatus({
  required int cardId,
  required DateTime dueDate,
  required bool isPaid,
}) async {
  final db = await database;

  final existing = await db.query(
    'payments',
    where: 'cardId = ? AND dueDate = ?',
    whereArgs: [
      cardId,
      dueDate.toIso8601String(),
    ],
  );

  final values = {
    'cardId': cardId,
    'dueDate': dueDate.toIso8601String(),
    'isPaid': isPaid ? 1 : 0,
    'paidDate': isPaid
        ? DateTime.now().toIso8601String()
        : null,
  };

  if (existing.isEmpty) {
    await db.insert(
      'payments',
      values,
    );
  } else {
    await db.update(
      'payments',
      values,
      where: 'cardId = ? AND dueDate = ?',
      whereArgs: [
        cardId,
        dueDate.toIso8601String(),
      ],
    );
  }
}
Future<List<PaymentRecord>> getPendingPayments() async {
  final db = await database;

  final result = await db.query(
    'payments',
    where: 'isPaid = ?',
    whereArgs: [0],
  );

  return result
      .map((e) => PaymentRecord.fromMap(e))
      .toList();
}
Future<List<Map<String, dynamic>>> getPendingPaymentDetails() async {
  final db = await database;

  return await db.rawQuery('''
    SELECT
      p.cardId,
      p.dueDate,
      p.isPaid,
      c.cardName,
      c.bankName,
      c.last4Digits
    FROM payments p
    INNER JOIN cards c
      ON p.cardId = c.id
    WHERE p.isPaid = 0
    ORDER BY p.dueDate ASC
  ''');
}
Future<bool> reminderAlreadySent({
  required int cardId,
  required DateTime dueDate,
  required int reminderDay,
}) async {
  final db = await database;

  final result = await db.query(
    'notification_history',
    where: 'cardId=? AND dueDate=? AND reminderDay=?',
    whereArgs: [
      cardId,
      dueDate.toIso8601String(),
      reminderDay,
    ],
  );

  return result.isNotEmpty;
}
Future<void> saveReminder({
  required int cardId,
  required DateTime dueDate,
  required int reminderDay,
}) async {
  final db = await database;

  await db.insert(
    'notification_history',
    {
      'cardId': cardId,
      'dueDate': dueDate.toIso8601String(),
      'reminderDay': reminderDay,
      'sentAt': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

}