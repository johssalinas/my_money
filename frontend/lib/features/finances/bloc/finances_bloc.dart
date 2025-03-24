import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_money/features/finances/models/wallet_model.dart';
import 'package:my_money/features/finances/models/transaction_model.dart';
import 'package:my_money/features/finances/services/finances_service.dart';

// Events
abstract class FinancesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWalletsEvent extends FinancesEvent {}

class AddWalletEvent extends FinancesEvent {
  final Wallet wallet;

  AddWalletEvent({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class UpdateWalletEvent extends FinancesEvent {
  final String id;
  final Wallet wallet;

  UpdateWalletEvent({required this.id, required this.wallet});

  @override
  List<Object?> get props => [id, wallet];
}

class DeleteWalletEvent extends FinancesEvent {
  final String id;

  DeleteWalletEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class LoadTransactionsEvent extends FinancesEvent {
  final String? walletId;
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;

  LoadTransactionsEvent({
    this.walletId,
    this.startDate,
    this.endDate,
    this.type,
  });

  @override
  List<Object?> get props => [walletId, startDate, endDate, type];
}

class AddTransactionEvent extends FinancesEvent {
  final Map<String, dynamic> data;

  AddTransactionEvent({required this.data});

  @override
  List<Object?> get props => [data];
}

// States
abstract class FinancesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FinancesInitialState extends FinancesState {}

class FinancesLoadingState extends FinancesState {}

class WalletsLoadedState extends FinancesState {
  final List<Wallet> wallets;

  WalletsLoadedState({required this.wallets});

  @override
  List<Object?> get props => [wallets];
}

class TransactionsLoadedState extends FinancesState {
  final List<Transaction> transactions;

  TransactionsLoadedState({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class FinancesErrorState extends FinancesState {
  final String error;

  FinancesErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

// Bloc
class FinancesBloc extends Bloc<FinancesEvent, FinancesState> {
  final FinancesService _financesService;

  FinancesBloc({required FinancesService financesService})
    : _financesService = financesService,
      super(FinancesInitialState()) {
    on<LoadWalletsEvent>(_onLoadWallets);
    on<AddWalletEvent>(_onAddWallet);
    on<UpdateWalletEvent>(_onUpdateWallet);
    on<DeleteWalletEvent>(_onDeleteWallet);
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
  }

  Future<void> _onLoadWallets(
    LoadWalletsEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoadingState());
    try {
      final wallets = await _financesService.getWallets();
      emit(WalletsLoadedState(wallets: wallets));
    } catch (e) {
      emit(FinancesErrorState(error: e.toString()));
    }
  }

  Future<void> _onAddWallet(
    AddWalletEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoadingState());
    try {
      await _financesService.createWallet(event.wallet);
      final wallets = await _financesService.getWallets();
      emit(WalletsLoadedState(wallets: wallets));
    } catch (e) {
      emit(FinancesErrorState(error: e.toString()));
    }
  }

  Future<void> _onUpdateWallet(
    UpdateWalletEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoadingState());
    try {
      await _financesService.updateWallet(event.id, event.wallet);
      final wallets = await _financesService.getWallets();
      emit(WalletsLoadedState(wallets: wallets));
    } catch (e) {
      emit(FinancesErrorState(error: e.toString()));
    }
  }

  Future<void> _onDeleteWallet(
    DeleteWalletEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoadingState());
    try {
      await _financesService.deleteWallet(event.id);
      final wallets = await _financesService.getWallets();
      emit(WalletsLoadedState(wallets: wallets));
    } catch (e) {
      emit(FinancesErrorState(error: e.toString()));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoadingState());
    try {
      final transactions = await _financesService.getTransactions(
        walletId: event.walletId,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
      );
      emit(TransactionsLoadedState(transactions: transactions));
    } catch (e) {
      emit(FinancesErrorState(error: e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoadingState());
    try {
      await _financesService.createTransaction(event.data);
      // Recargar las transacciones con los mismos filtros
      final currentState = state;
      if (currentState is TransactionsLoadedState) {
        // Mantener los filtros actuales
        // Para hacerlo correctamente, necesitaríamos guardar los filtros actuales
        final transactions = await _financesService.getTransactions();
        emit(TransactionsLoadedState(transactions: transactions));
      }
    } catch (e) {
      emit(FinancesErrorState(error: e.toString()));
    }
  }
}
