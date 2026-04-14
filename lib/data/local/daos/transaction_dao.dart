import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<List<TransactionsTableData>> getAll() {
    return (select(transactionsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<TransactionsTableData?> getById(String id) {
    return (select(transactionsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<TransactionsTableData>> getByDateRange(DateTime from, DateTime to) {
    return (select(transactionsTable)
          ..where((t) => t.date.isBetweenValues(from, to))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<List<TransactionsTableData>> getByCategory(String categoryId) {
    return (select(transactionsTable)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<List<TransactionsTableData>> getByAccount(String accountId) {
    return (select(transactionsTable)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<void> insertTransaction(TransactionsTableCompanion transaction) {
    return into(transactionsTable).insert(transaction);
  }

  Future<int> updateTransaction(TransactionsTableCompanion transaction) {
    return (update(transactionsTable)
          ..where((t) => t.id.equals(transaction.id.value)))
        .write(transaction);
  }

  Future<void> deleteTransaction(String id) {
    return (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TransactionsTableData>> watchAll() {
    return (select(transactionsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
