// lib/services/offline_queue_service.dart
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineQueueService {
  static Database? _db;

  static Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'offline_orders.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_orders (
            id TEXT PRIMARY KEY,
            items TEXT NOT NULL,
            discount REAL NOT NULL,
            payment_method TEXT NOT NULL,
            amount_received REAL NOT NULL,
            created_at TEXT NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ── Save order to local queue ──
  static Future<void> enqueue({
    required List<Map<String, dynamic>> items,
    required double discount,
    required String paymentMethod,
    required double amountReceived,
  }) async {
    await _db!.insert('offline_orders', {
      'id': 'offline_${DateTime.now().millisecondsSinceEpoch}',
      'items': jsonEncode(items),
      'discount': discount,
      'payment_method': paymentMethod,
      'amount_received': amountReceived,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  // ── Get all pending (unsynced) orders ──
  static Future<List<Map<String, dynamic>>> getPendingOrders() async {
    return await _db!.query(
      'offline_orders',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  // ── Mark order as synced ──
  static Future<void> markSynced(String id) async {
    await _db!.update(
      'offline_orders',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}