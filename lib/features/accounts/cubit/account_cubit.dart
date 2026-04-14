import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/account_model.dart';
import '../../../data/repositories/i_account_repository.dart';
import '../../../data/repositories/repository_exceptions.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final IAccountRepository _repository;
  late final StreamSubscription<List<AccountModel>> _subscription;

  AccountCubit(this._repository) : super(const AccountInitial()) {
    _subscription = _repository.watchAll().listen((accounts) {
      emit(AccountLoaded(accounts: accounts));
    });
  }

  Future<void> loadAll() async {
    emit(const AccountLoading());
    try {
      final result = await _repository.getAll();
      emit(AccountLoaded(accounts: result));
    } on Exception catch (e) {
      emit(AccountError(
        message: _mapError(e),
        lastKnownAccounts: const [],
      ));
    }
  }

  Future<void> addAccount(AccountModel account) async {
    try {
      if (account.name.trim().isEmpty) {
        throw ValidationException('Account name cannot be empty.');
      }
      await _repository.create(account);
    } on Exception catch (e) {
      emit(AccountError(
        message: _mapError(e),
        lastKnownAccounts: _currentAccounts,
      ));
    }
  }

  Future<void> updateAccount(AccountModel account) async {
    try {
      if (account.name.trim().isEmpty) {
        throw ValidationException('Account name cannot be empty.');
      }
      await _repository.update(account);
    } on Exception catch (e) {
      emit(AccountError(
        message: _mapError(e),
        lastKnownAccounts: _currentAccounts,
      ));
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _repository.delete(id);
    } on Exception catch (e) {
      emit(AccountError(
        message: _mapError(e),
        lastKnownAccounts: _currentAccounts,
      ));
    }
  }

  void dismissError() {
    if (state is AccountError) {
      final errorState = state as AccountError;
      emit(AccountLoaded(accounts: errorState.lastKnownAccounts));
    }
  }

  String _mapError(Exception e) {
    if (e is ValidationException) return e.message;
    if (e is EntityNotFoundException) return 'Account not found.';
    if (e is EntityInUseException) {
      return 'This account has transactions and cannot be deleted.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  List<AccountModel> get _currentAccounts {
    final s = state;
    if (s is AccountLoaded) return s.accounts;
    return const [];
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
