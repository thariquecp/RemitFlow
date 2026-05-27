import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/core/constants/app_constants.dart';
import 'package:fintech_app/features/transactions/data/datasources/transaction_local_source.dart';
import 'package:fintech_app/features/transactions/domain/entities/transaction.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

class TransactionLoadMore extends TransactionEvent {
  const TransactionLoadMore();
}

class TransactionAdded extends TransactionEvent {
  final Transaction transaction;
  const TransactionAdded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionFilterChanged extends TransactionEvent {
  final TransactionFilter filter;
  const TransactionFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class TransactionFilter extends Equatable {
  final TransactionStatus? status;
  final String? currency;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;

  const TransactionFilter({
    this.status,
    this.currency,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
  });

  bool get hasActiveFilters =>
      status != null ||
      (currency != null && currency!.isNotEmpty) ||
      minAmount != null ||
      maxAmount != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  @override
  List<Object?> get props => [
    status,
    currency,
    minAmount,
    maxAmount,
    searchQuery,
  ];
}

enum TransactionLoadStatus { initial, loading, loaded, loadingMore, error }

class TransactionState extends Equatable {
  final TransactionLoadStatus status;
  final List<Transaction> transactions;
  final TransactionFilter filter;
  final int currentPage;
  final bool hasReachedEnd;
  final String errorMessage;

  const TransactionState({
    this.status = TransactionLoadStatus.initial,
    this.transactions = const [],
    this.filter = const TransactionFilter(),
    this.currentPage = 0,
    this.hasReachedEnd = false,
    this.errorMessage = '',
  });

  TransactionState copyWith({
    TransactionLoadStatus? status,
    List<Transaction>? transactions,
    TransactionFilter? filter,
    int? currentPage,
    bool? hasReachedEnd,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    filter,
    currentPage,
    hasReachedEnd,
  ];
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionLocalSource _localSource;

  TransactionBloc({required this._localSource})
    : super(const TransactionState()) {
    on<TransactionLoadRequested>(_onLoad);
    on<TransactionLoadMore>(_onLoadMore);
    on<TransactionFilterChanged>(_onFilterChanged);
    on<TransactionAdded>(_onTransactionAdded);
  }

  Future<void> _onLoad(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionLoadStatus.loading));
    try {
      final txs = await _localSource.getFiltered(
        status: state.filter.status,
        currency: state.filter.currency,
        minAmount: state.filter.minAmount,
        maxAmount: state.filter.maxAmount,
        searchQuery: state.filter.searchQuery,
        page: 0,
        pageSize: transactionsPageSize,
      );
      emit(
        state.copyWith(
          status: TransactionLoadStatus.loaded,
          transactions: txs,
          currentPage: 0,
          hasReachedEnd: txs.length < transactionsPageSize,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionLoadStatus.error,
          errorMessage: 'Failed to load',
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    TransactionLoadMore event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.hasReachedEnd ||
        state.status == TransactionLoadStatus.loadingMore) {
      return;
    }
    emit(state.copyWith(status: TransactionLoadStatus.loadingMore));
    try {
      final nextPage = state.currentPage + 1;
      final more = await _localSource.getFiltered(
        status: state.filter.status,
        currency: state.filter.currency,
        minAmount: state.filter.minAmount,
        maxAmount: state.filter.maxAmount,
        searchQuery: state.filter.searchQuery,
        page: nextPage,
        pageSize: transactionsPageSize,
      );
      emit(
        state.copyWith(
          status: TransactionLoadStatus.loaded,
          transactions: [...state.transactions, ...more],
          currentPage: nextPage,
          hasReachedEnd: more.length < transactionsPageSize,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: TransactionLoadStatus.loaded));
    }
  }

  Future<void> _onFilterChanged(
    TransactionFilterChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        filter: event.filter,
        status: TransactionLoadStatus.loading,
      ),
    );
    try {
      final txs = await _localSource.getFiltered(
        status: event.filter.status,
        currency: event.filter.currency,
        minAmount: event.filter.minAmount,
        maxAmount: event.filter.maxAmount,
        searchQuery: event.filter.searchQuery,
        page: 0,
        pageSize: transactionsPageSize,
      );
      emit(
        state.copyWith(
          status: TransactionLoadStatus.loaded,
          transactions: txs,
          currentPage: 0,
          hasReachedEnd: txs.length < transactionsPageSize,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransactionLoadStatus.error,
          errorMessage: 'Filter failed',
        ),
      );
    }
  }

  Future<void> _onTransactionAdded(
    TransactionAdded event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _localSource.addTransaction(event.transaction);

      if (!state.filter.hasActiveFilters ||
          event.transaction.status == state.filter.status) {
        emit(
          state.copyWith(
            transactions: [event.transaction, ...state.transactions],
          ),
        );
      }
    } catch (_) {
      // Silently fail or log in production
    }
  }
}
