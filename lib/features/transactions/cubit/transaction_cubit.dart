import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/i_transaction_repository.dart';
import '../../../data/repositories/repository_exceptions.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final ITransactionRepository _repository;
  late final StreamSubscription<List<TransactionModel>> _subscription;

  TransactionCubit(this._repository) : super(const TransactionInitial()) {
    _subscription = _repository.watchAll().listen((transactions) {
      final filters = state is TransactionLoaded
          ? (state as TransactionLoaded).activeFilters
          : const TransactionFilters();
      emit(TransactionLoaded(
        transactions: transactions,
        filtered: _filterTransactions(transactions, filters),
        activeFilters: filters,
      ));
    });
  }

  Future<void> loadAll() async {
    emit(const TransactionLoading());
    try {
      final result = await _repository.getAll();
      emit(TransactionLoaded(
        transactions: result,
        filtered: result,
        activeFilters: const TransactionFilters(),
      ));
    } on Exception catch (e) {
      emit(TransactionError(
        message: _mapError(e),
        lastKnownTransactions: const [],
      ));
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      if (transaction.amount <= 0) {
        throw ValidationException('Transaction amount must be greater than zero.');
      }
      if (transaction.categoryId.isEmpty) {
        throw ValidationException('A category must be selected.');
      }
      if (transaction.accountId.isEmpty) {
        throw ValidationException('An account must be selected.');
      }

      await _repository.create(transaction);
    } on Exception catch (e) {
      emit(TransactionError(
        message: _mapError(e),
        lastKnownTransactions: _currentList,
      ));
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (transaction.amount <= 0) {
        throw ValidationException('Transaction amount must be greater than zero.');
      }
      if (transaction.categoryId.isEmpty) {
        throw ValidationException('A category must be selected.');
      }
      if (transaction.accountId.isEmpty) {
        throw ValidationException('An account must be selected.');
      }

      await _repository.update(transaction);
    } on Exception catch (e) {
      emit(TransactionError(
        message: _mapError(e),
        lastKnownTransactions: _currentList,
      ));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.delete(id);
    } on Exception catch (e) {
      emit(TransactionError(
        message: _mapError(e),
        lastKnownTransactions: _currentList,
      ));
    }
  }

  void applyFilters(TransactionFilters filters) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      emit(TransactionLoaded(
        transactions: currentState.transactions,
        filtered: _filterTransactions(currentState.transactions, filters),
        activeFilters: filters,
      ));
    }
  }

  void clearFilters() {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      emit(TransactionLoaded(
        transactions: currentState.transactions,
        filtered: currentState.transactions,
        activeFilters: const TransactionFilters(),
      ));
    }
  }

  void dismissError() {
    if (state is TransactionError) {
      final errorState = state as TransactionError;
      emit(TransactionLoaded(
        transactions: errorState.lastKnownTransactions,
        filtered: errorState.lastKnownTransactions,
        activeFilters: const TransactionFilters(),
      ));
    }
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    TransactionFilters filters,
  ) {
    return transactions.where((t) {
      if (filters.from != null && t.date.isBefore(filters.from!)) return false;
      if (filters.to != null && t.date.isAfter(filters.to!)) return false;
      if (filters.categoryId != null && t.categoryId != filters.categoryId) {
        return false;
      }
      if (filters.accountId != null && t.accountId != filters.accountId) {
        return false;
      }
      return true;
    }).toList();
  }

  String _mapError(Exception e) {
    if (e is ValidationException) return e.message;
    if (e is EntityNotFoundException) return 'Transaction not found.';
    if (e is EntityInUseException) {
      return 'This transaction is linked to other records and cannot be deleted.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  List<TransactionModel> get _currentList {
    final s = state;
    if (s is TransactionLoaded) return s.transactions;
    return const [];
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
