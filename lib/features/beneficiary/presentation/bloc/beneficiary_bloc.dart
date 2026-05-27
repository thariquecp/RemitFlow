import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/features/beneficiary/data/datasources/beneficiary_local_source.dart';
import 'package:fintech_app/features/beneficiary/domain/entities/beneficiary.dart';

// Events

sealed class BeneficiaryEvent extends Equatable {
  const BeneficiaryEvent();

  @override
  List<Object?> get props => [];
}

class BeneficiaryLoadRequested extends BeneficiaryEvent {
  const BeneficiaryLoadRequested();
}

class BeneficiaryAdded extends BeneficiaryEvent {
  final Beneficiary beneficiary;
  const BeneficiaryAdded(this.beneficiary);

  @override
  List<Object?> get props => [beneficiary];
}

class BeneficiaryDeleted extends BeneficiaryEvent {
  final String id;
  const BeneficiaryDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

// State

enum BeneficiaryStatus { initial, loading, loaded, error }

class BeneficiaryState extends Equatable {
  final BeneficiaryStatus status;
  final List<Beneficiary> beneficiaries;
  final String errorMessage;
  final bool isDuplicateWarning;

  const BeneficiaryState({
    this.status = BeneficiaryStatus.initial,
    this.beneficiaries = const [],
    this.errorMessage = '',
    this.isDuplicateWarning = false,
  });

  BeneficiaryState copyWith({
    BeneficiaryStatus? status,
    List<Beneficiary>? beneficiaries,
    String? errorMessage,
    bool? isDuplicateWarning,
  }) {
    return BeneficiaryState(
      status: status ?? this.status,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      errorMessage: errorMessage ?? this.errorMessage,
      isDuplicateWarning: isDuplicateWarning ?? this.isDuplicateWarning,
    );
  }

  @override
  List<Object?> get props => [
    status,
    beneficiaries,
    errorMessage,
    isDuplicateWarning,
  ];
}

// Bloc

class BeneficiaryBloc extends Bloc<BeneficiaryEvent, BeneficiaryState> {
  final BeneficiaryLocalSource _localSource;

  BeneficiaryBloc({required this._localSource})
    : super(const BeneficiaryState()) {
    on<BeneficiaryLoadRequested>(_onLoad);
    on<BeneficiaryAdded>(_onAdd);
    on<BeneficiaryDeleted>(_onDelete);
  }

  Future<void> _onLoad(
    BeneficiaryLoadRequested event,
    Emitter<BeneficiaryState> emit,
  ) async {
    emit(state.copyWith(status: BeneficiaryStatus.loading));

    try {
      final list = await _localSource.getAll();
      emit(
        state.copyWith(status: BeneficiaryStatus.loaded, beneficiaries: list),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BeneficiaryStatus.error,
          errorMessage: 'Failed to load beneficiaries',
        ),
      );
    }
  }

  Future<void> _onAdd(
    BeneficiaryAdded event,
    Emitter<BeneficiaryState> emit,
  ) async {
    // Check for duplicates
    final isDuplicate = await _localSource.isDuplicate(
      event.beneficiary.accountNumber,
      event.beneficiary.bankName,
    );

    if (isDuplicate) {
      emit(state.copyWith(isDuplicateWarning: true));
      // Reset warning after a brief period
      emit(state.copyWith(isDuplicateWarning: false));
      return;
    }

    try {
      await _localSource.add(event.beneficiary);
      final updated = await _localSource.getAll();
      emit(
        state.copyWith(
          beneficiaries: updated,
          status: BeneficiaryStatus.loaded,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add beneficiary'));
    }
  }

  Future<void> _onDelete(
    BeneficiaryDeleted event,
    Emitter<BeneficiaryState> emit,
  ) async {
    try {
      await _localSource.delete(event.id);
      final updated = await _localSource.getAll();
      emit(state.copyWith(beneficiaries: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete beneficiary'));
    }
  }
}
