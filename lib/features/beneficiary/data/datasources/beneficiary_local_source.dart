import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:fintech_app/features/beneficiary/domain/entities/beneficiary.dart';
import 'package:fintech_app/core/security/secure_storage_service.dart';

class BeneficiaryLocalSource {
  static const String _boxName = 'beneficiaries';
  //AES encryption key
  static const String _encryptionKeyId = 'x';
  Box? _box;

  Future<void> init(SecureStorageService secureStorage) async {
    final existingKeyString = await secureStorage.read(_encryptionKeyId);
    List<int> encryptionKey;

    if (existingKeyString == null) {
      encryptionKey = Hive.generateSecureKey();
      await secureStorage.write(
        _encryptionKeyId,
        base64UrlEncode(encryptionKey),
      );
    } else {
      encryptionKey = base64Url.decode(existingKeyString);
    }

    _box = await Hive.openBox(
      _boxName,
      //encryption
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<List<Beneficiary>> getAll() async {
    final entries = _box?.values.toList() ?? [];
    return entries
        .map(
          (e) => Beneficiary.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String)),
          ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> add(Beneficiary beneficiary) async {
    await _box?.put(beneficiary.id, jsonEncode(beneficiary.toJson()));
  }

  Future<void> update(Beneficiary beneficiary) async {
    await _box?.put(beneficiary.id, jsonEncode(beneficiary.toJson()));
  }

  Future<void> delete(String id) async {
    await _box?.delete(id);
  }

  /// Checks if already exists.
  Future<bool> isDuplicate(String accountNumber, String bankName) async {
    final all = await getAll();
    return all.any(
      (b) =>
          b.accountNumber == accountNumber &&
          b.bankName.toLowerCase() == bankName.toLowerCase(),
    );
  }
}
