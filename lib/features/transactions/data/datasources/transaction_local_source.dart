import 'dart:convert';
import 'dart:math';
import 'package:hive_ce/hive.dart';
import 'package:fintech_app/features/transactions/domain/entities/transaction.dart';

class TransactionLocalSource {
  static const String _boxName = 'transactions';
  static const String _seededKey = 'seeded_v1';
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);

    // Seed mock data only once
    if (_box?.get(_seededKey) != true) {
      await _generateMockData();
      await _box?.put(_seededKey, true);
    }
  }

  Future<List<Transaction>> getTransactions({
    int page = 0,
    int pageSize = 20,
  }) async {
    final all = _getAllSorted();
    final start = page * pageSize;
    if (start >= all.length) return [];
    final end = (start + pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  Future<List<Transaction>> getFiltered({
    TransactionStatus? status,
    String? currency,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    int page = 0,
    int pageSize = 20,
  }) async {
    var all = _getAllSorted();

    if (status != null) {
      all = all.where((t) => t.status == status).toList();
    }
    if (currency != null && currency.isNotEmpty) {
      all = all
          .where(
            (t) => t.sendCurrency == currency || t.receiveCurrency == currency,
          )
          .toList();
    }
    if (minAmount != null) {
      all = all.where((t) => t.sendAmount >= minAmount).toList();
    }
    if (maxAmount != null) {
      all = all.where((t) => t.sendAmount <= maxAmount).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      all = all
          .where(
            (t) =>
                t.recipientName.toLowerCase().contains(query) ||
                t.id.toLowerCase().contains(query) ||
                t.sendCurrency.toLowerCase().contains(query) ||
                t.receiveCurrency.toLowerCase().contains(query),
          )
          .toList();
    }

    final start = page * pageSize;
    if (start >= all.length) return [];
    final end = (start + pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  /// Returns the total number of transactions.
  int get totalCount {
    return _box?.values.whereType<String>().length ?? 0;
  }

  Future<void> addTransaction(Transaction tx) async {
    await _box?.put(tx.id, jsonEncode(tx.toJson()));
  }

  List<Transaction> _getAllSorted() {
    final entries = (_box?.values.toList() ?? [])
        .whereType<String>()
        .map((e) {
          try {
            return Transaction.fromJson(
              Map<String, dynamic>.from(jsonDecode(e)),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<Transaction>()
        .toList();

    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<void> _generateMockData() async {
    final random = Random(8);
    final names = [
      'Tharique CP',
      'John Doe',
      'Doe John',
      'John Cena',
      'Johansson',
      'Fathima',
      'George',
      'Hanan',
    ];
    final currencies = [
      'USD',
      'EUR',
      'GBP',
      'INR',
      'AED',
      'CAD',
      'AUD',
      'JPY',
      'SGD',
    ];
    final statuses = TransactionStatus.values;
    final notes = [
      'Monthly rent', 'Family support', 'Tuition fee', 'Business payment',
      'Freelance payment', 'Gift', 'Medical expenses', 'Travel booking',
      null, null, null, // Some without notes
    ];

    final now = DateTime.now();

    for (int i = 0; i < 200; i++) {
      final daysAgo = random.nextInt(90);
      final hoursAgo = random.nextInt(24);
      final date = now.subtract(Duration(days: daysAgo, hours: hoursAgo));

      final statusIndex = switch (random.nextInt(10)) {
        0 => 0, // pending
        1 => 1, // processing
        2 || 3 || 4 || 5 || 6 || 7 => 2, // completed
        8 => 3, // failed
        9 => 4, // refunded
        _ => 2,
      };

      final sendCurr = currencies[random.nextInt(currencies.length)];
      var recvCurr = currencies[random.nextInt(currencies.length)];
      while (recvCurr == sendCurr) {
        recvCurr = currencies[random.nextInt(currencies.length)];
      }

      final sendAmount = (50 + random.nextDouble() * 4950)
          .roundToDouble(); // 50–5000
      final rate = 0.5 + random.nextDouble() * 2;
      final receiveAmount = (sendAmount * rate * 100).roundToDouble() / 100;
      final fee = (sendAmount * 0.01 * 100).roundToDouble() / 100;

      final name = names[random.nextInt(names.length)];
      final acct = List.generate(10, (_) => random.nextInt(10)).join();

      final tx = Transaction(
        id: 'TXN-${(1000000 + i).toString()}',
        recipientName: name,
        recipientAccount: acct,
        sendAmount: sendAmount,
        sendCurrency: sendCurr,
        receiveAmount: receiveAmount,
        receiveCurrency: recvCurr,
        exchangeRate: (rate * 10000).roundToDouble() / 10000,
        fee: fee,
        status: statuses[statusIndex],
        createdAt: date,
        referenceNote: notes[random.nextInt(notes.length)],
      );

      await _box?.put(tx.id, jsonEncode(tx.toJson()));
    }
  }
}
