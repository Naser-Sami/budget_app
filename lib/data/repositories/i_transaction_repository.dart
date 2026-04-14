import '../models/transaction_model.dart';
import 'repository_exceptions.dart';

abstract class ITransactionRepository {
  /// Returns all transactions, newest first.
  Future<List<TransactionModel>> getAll();

  /// Returns a single transaction by ID, or null if not found.
  Future<TransactionModel?> getById(String id);

  /// Returns transactions with a date on or between [from] and [to], inclusive.
  /// Both ends are inclusive. If [from] is after [to], returns an empty list.
  /// Dates are compared in UTC. Pass [DateTime.toUtc()] if your dates are local.
  Future<List<TransactionModel>> getByDateRange(DateTime from, DateTime to);

  /// Returns all transactions belonging to [categoryId].
  Future<List<TransactionModel>> getByCategory(String categoryId);

  /// Returns all transactions belonging to [accountId].
  Future<List<TransactionModel>> getByAccount(String accountId);

  /// Persists a new transaction. [transaction.id] must be a unique UUID.
  /// 
  /// Throws [DuplicateEntityException] if the ID already exists.
  /// Throws [ValidationException] if `transaction.amount <= 0`.
  Future<void> create(TransactionModel transaction);

  /// Updates an existing transaction.
  /// 
  /// Throws [EntityNotFoundException] if the ID does not exist.
  /// Throws [ValidationException] if `transaction.amount <= 0`.
  Future<void> update(TransactionModel transaction);

  /// Deletes a transaction by ID. No-op if not found.
  Future<void> delete(String id);

  /// Reactive stream — emits the full transaction list, newest first,
  /// whenever any transaction is created, updated, or deleted.
  Stream<List<TransactionModel>> watchAll();
}
