import 'dart:convert';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/domain_selection_service.dart';
import 'package:app_test/features/authentication/login/data/saved_account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers the accounts that logged in successfully, one list per company
/// domain. Everything (including passwords) is kept in the platform's secure
/// storage (Android Keystore / iOS Keychain), never in SharedPreferences.
abstract class SavedAccountsService {
  static const _storage = FlutterSecureStorage();
  static const _maxAccounts = 8;

  /// Id of the account that just logged in and still needs its name / photo
  /// from the user settings. Lives in SharedPreferences, so logging out
  /// (which wipes it) can never leave a stale marker behind.
  static const _profileSyncKey = 'saved_account_profile_sync_id';

  /// The list belongs to the domain the app is connected to right now.
  static String get _key =>
      'saved_accounts_v1_${DomainSelectionService.currentCleanDomain}';

  static Future<List<SavedAccount>> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return [];
      return SavedAccount.decodeList(raw);
    } catch (e) {
      debugPrint('⚠️ SavedAccountsService.load failed: $e');
      return [];
    }
  }

  /// Adds the account, or replaces the existing one with the same [SavedAccount.id]
  /// (so a changed password is updated). The most recent login comes first.
  static Future<List<SavedAccount>> save(SavedAccount account) async {
    final accounts = await load();
    // Keep the known name / photo until the fresh ones arrive.
    final previous = accounts.where((a) => a.id == account.id).toList();
    if (previous.isNotEmpty && account.name.isEmpty) {
      account = account.copyWith(
          name: previous.first.name, avatar: previous.first.avatar);
    }
    accounts.removeWhere((a) => a.id == account.id);
    accounts.insert(0, account);
    await CacheHelper.setString(key: _profileSyncKey, value: account.id);
    if (accounts.length > _maxAccounts) {
      accounts.removeRange(_maxAccounts, accounts.length);
    }
    return _write(accounts);
  }

  /// Forget that an account is waiting for its profile (social logins, ...).
  static Future<void> clearPendingProfileSync() async {
    await CacheHelper.deleteData(key: _profileSyncKey);
  }

  /// Call once the user settings (`US1`) have been loaded after a login. Copies
  /// the user's name and photo onto the account that just logged in.
  static Future<void> syncProfileFromSettings() async {
    try {
      final id = CacheHelper.getString(_profileSyncKey);
      if (id.isEmpty) return;
      final raw = CacheHelper.getString('US1');
      if (raw.isEmpty || raw == 'null') return; // not loaded yet, retry later
      final us1 = jsonDecode(raw);
      if (us1 is! Map) return;
      final name = (us1['name'] ?? '').toString().trim();
      if (name.isEmpty) return;

      final accounts = await load();
      final index = accounts.indexWhere((a) => a.id == id);
      if (index == -1) {
        await clearPendingProfileSync();
        return;
      }
      if (!_belongsTo(accounts[index], us1)) {
        // The settings are for somebody else, never attach their name.
        await clearPendingProfileSync();
        return;
      }
      accounts[index] = accounts[index]
          .copyWith(name: name, avatar: (us1['photo'] ?? '').toString());
      await _write(accounts);
      await clearPendingProfileSync();
    } catch (e) {
      debugPrint('⚠️ SavedAccountsService.syncProfileFromSettings failed: $e');
    }
  }

  /// Sanity check: when the settings carry an email / phone, it must match the
  /// account. Missing values can't contradict it.
  static bool _belongsTo(SavedAccount account, Map us1) {
    String digits(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
    if (account.isPhone) {
      final phone = digits((us1['phone'] ?? '').toString());
      final mine = digits(account.identifier).replaceFirst(RegExp(r'^0+'), '');
      if (phone.isEmpty || mine.isEmpty) return true;
      return phone.endsWith(mine) || mine.endsWith(phone);
    }
    final email = (us1['email'] ?? '').toString().trim().toLowerCase();
    if (email.isEmpty) return true;
    return email == account.identifier.trim().toLowerCase();
  }

  static Future<List<SavedAccount>> remove(String id) async {
    final accounts = await load();
    accounts.removeWhere((a) => a.id == id);
    return _write(accounts);
  }

  /// Returns what is really stored: on failure that is the previous list,
  /// so the UI never shows a save/remove that did not persist.
  static Future<List<SavedAccount>> _write(List<SavedAccount> accounts) async {
    try {
      if (accounts.isEmpty) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(
            key: _key, value: SavedAccount.encodeList(accounts));
      }
      return accounts;
    } catch (e) {
      debugPrint('⚠️ SavedAccountsService write failed: $e');
      return load();
    }
  }
}
