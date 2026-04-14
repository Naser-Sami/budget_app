import 'package:equatable/equatable.dart';
import '../../../data/models/transaction_model.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

// Emitted immediately on Cubit creation before any data loads.
final class TransactionInitial extends TransactionState {
  const TransactionInitial();

  @override
  List<Object?> get props => [];
}

// Emitted while the initial load (or a reload) is in progress.
final class TransactionLoading extends TransactionState {
  const TransactionLoading();

  @override
  List<Object?> get props => [];
}

// Emitted when data is available. Carries the full unfiltered list plus active filters.
final class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions; // full list from watchAll()
  final List<TransactionModel> filtered; // result after applying activeFilters
  final TransactionFilters activeFilters; // date range, category, account filters

  const TransactionLoaded({
    required this.transactions,
    required this.filtered,
    required this.activeFilters,
  });

  @override
  List<Object?> get props => [transactions, filtered, activeFilters];
}

// Emitted on any repository or validation exception.
final class TransactionError extends TransactionState {
  final String message;
  final List<TransactionModel> lastKnownTransactions; // retained so UI can show list + error

  const TransactionError({
    required this.message,
    required this.lastKnownTransactions,
  });

  @override
  List<Object?> get props => [message, lastKnownTransactions];
}

final class TransactionFilters extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final String? categoryId;
  final String? accountId;

  const TransactionFilters({
    this.from,
    this.to,
    this.categoryId,
    this.accountId,
  });

  bool get isActive =>
      from != null || to != null || categoryId != null || accountId != null;

  @override
  List<Object?> get props => [from, to, categoryId, accountId];
}
