import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/transactions_table.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [AccountsTable, TransactionsTable])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  Future<List<AccountsTableData>> getAll() {
    return select(accountsTable).get();
  }

  Future<AccountsTableData?> getById(String id) {
    return (select(accountsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertAccount(AccountsTableCompanion account) {
    return into(accountsTable).insert(account);
  }

  Future<int> updateAccount(AccountsTableCompanion account) {
    return (update(accountsTable)..where((t) => t.id.equals(account.id.value)))
        .write(account);
  }

  Future<void> deleteAccount(String id) {
    return (delete(accountsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> isAccountInUse(String id) async {
    final query = select(transactionsTable)..where((t) => t.accountId.equals(id))..limit(1);
    final match = await query.getSingleOrNull();
    return match != null;
  }

  Stream<List<AccountsTableData>> watchAll() {
    return select(accountsTable).watch();
  }
}
