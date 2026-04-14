import '../models/account_model.dart';
import 'repository_exceptions.dart';

abstract class IAccountRepository {
  /// Returns all accounts.
  Future<List<AccountModel>> getAll();

  /// Returns a single account by ID, or null if not found.
  Future<AccountModel?> getById(String id);

  /// Persists a new account.
  ///
  /// Throws [ValidationException] if `account.name` is empty.
  Future<void> create(AccountModel account);

  /// Updates an existing account.
  ///
  /// Throws [EntityNotFoundException] if ID not found.
  /// Throws [ValidationException] if `account.name` is empty.
  Future<void> update(AccountModel account);

  /// Deletes an account by ID. No-op if not found.
  ///
  /// Throws [EntityInUseException] if any transaction references this account.
  Future<void> delete(String id);

  /// Reactive stream — emits the full account list whenever any account changes.
  Stream<List<AccountModel>> watchAll();
}
