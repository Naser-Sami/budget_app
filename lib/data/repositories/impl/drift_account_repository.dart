import 'package:drift/drift.dart';

import '../../models/account_model.dart';
import '../../models/enums.dart';
import '../i_account_repository.dart';
import '../repository_exceptions.dart';
import '../../local/app_database.dart';
import '../../local/daos/account_dao.dart';

class DriftAccountRepository implements IAccountRepository {
  final AccountDao _dao;

  DriftAccountRepository(this._dao);

  AccountModel _toModel(AccountsTableData row) {
    return AccountModel(
      id: row.id,
      name: row.name,
      type: AccountType.values.byName(row.type),
      startingBalance: row.startingBalance,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  AccountsTableCompanion _toCompanion(AccountModel model) {
    return AccountsTableCompanion(
      id: Value(model.id),
      name: Value(model.name),
      type: Value(model.type.name),
      startingBalance: Value(model.startingBalance),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  @override
  Future<List<AccountModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<AccountModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> create(AccountModel account) async {
    if (account.name.trim().isEmpty) {
      throw ValidationException('Account name cannot be empty.');
    }

    await _dao.insertAccount(_toCompanion(account));
  }

  @override
  Future<void> update(AccountModel account) async {
    if (account.name.trim().isEmpty) {
      throw ValidationException('Account name cannot be empty.');
    }

    final rowsUpdated = await _dao.updateAccount(_toCompanion(account));
    if (rowsUpdated == 0) {
      throw EntityNotFoundException('Account with ID ${account.id} not found.');
    }
  }

  @override
  Future<void> delete(String id) async {
    final row = await _dao.getById(id);
    if (row == null) return;

    if (await _dao.isAccountInUse(id)) {
      throw EntityInUseException('Account is referenced by existing transactions.');
    }

    await _dao.deleteAccount(id);
  }

  @override
  Stream<List<AccountModel>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toModel).toList());
  }
}
