import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/transaction_model.dart';
import '../i_transaction_repository.dart';
import '../repository_exceptions.dart';
import '../../local/app_database.dart';
import '../../local/daos/transaction_dao.dart';

class DriftTransactionRepository implements ITransactionRepository {
  final TransactionDao _dao;

  DriftTransactionRepository(this._dao);

  TransactionModel _toModel(TransactionsTableData row) {
    return TransactionModel(
      id: row.id,
      amount: row.amount,
      type: TransactionType.values.byName(row.type),
      date: row.date,
      categoryId: row.categoryId,
      accountId: row.accountId,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TransactionsTableCompanion _toCompanion(TransactionModel model) {
    return TransactionsTableCompanion(
      id: Value(model.id),
      amount: Value(model.amount),
      type: Value(model.type.name),
      date: Value(model.date),
      categoryId: Value(model.categoryId),
      accountId: Value(model.accountId),
      description: Value(model.description),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  @override
  Future<List<TransactionModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<TransactionModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<TransactionModel>> getByDateRange(DateTime from, DateTime to) async {
    final rows = await _dao.getByDateRange(from, to);
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<TransactionModel>> getByCategory(String categoryId) async {
    final rows = await _dao.getByCategory(categoryId);
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<TransactionModel>> getByAccount(String accountId) async {
    final rows = await _dao.getByAccount(accountId);
    return rows.map(_toModel).toList();
  }

  @override
  Future<void> create(TransactionModel transaction) async {
    if (transaction.amount <= 0) {
      throw ValidationException('Transaction amount must be strictly positive.');
    }

    try {
      await _dao.insertTransaction(_toCompanion(transaction));
    } on Exception catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('unique') || message.contains('constraint failed')) {
        throw DuplicateEntityException('Transaction with ID ${transaction.id} already exists.');
      }
      rethrow;
    }
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    if (transaction.amount <= 0) {
      throw ValidationException('Transaction amount must be strictly positive.');
    }

    final rowsUpdated = await _dao.updateTransaction(_toCompanion(transaction));
    if (rowsUpdated == 0) {
      throw EntityNotFoundException('Transaction with ID ${transaction.id} not found.');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _dao.deleteTransaction(id);
  }

  @override
  Stream<List<TransactionModel>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toModel).toList());
  }
}
