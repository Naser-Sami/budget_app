import 'package:equatable/equatable.dart';
import '../../../data/models/account_model.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountInitial extends AccountState {
  const AccountInitial();

  @override
  List<Object?> get props => [];
}

final class AccountLoading extends AccountState {
  const AccountLoading();

  @override
  List<Object?> get props => [];
}

final class AccountLoaded extends AccountState {
  final List<AccountModel> accounts;

  const AccountLoaded({required this.accounts});

  @override
  List<Object?> get props => [accounts];
}

final class AccountError extends AccountState {
  final String message;
  final List<AccountModel> lastKnownAccounts;

  const AccountError({
    required this.message,
    required this.lastKnownAccounts,
  });

  @override
  List<Object?> get props => [message, lastKnownAccounts];
}
