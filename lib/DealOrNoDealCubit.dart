import 'package:bloc/bloc.dart';
import 'dart:math';

enum GameStage { pickSuitcase, eliminateSuitcase, dealOrNoDeal, gameOver }

class DealOrNoDealState {
  final List<int> suitcases;
  final List<int> eliminatedSuitcases;
  final List<int> displayBoxes;
  final int? selectedSuitcase;
  final double dealerOffer;
  final GameStage gameStage;
  final int? lastEliminatedValue;

  DealOrNoDealState({
    required this.suitcases,
    required this.eliminatedSuitcases,
    required this.displayBoxes,
    this.selectedSuitcase,
    required this.dealerOffer,
    required this.gameStage,
    this.lastEliminatedValue,
  });
}
class DealOrNoDealCubit extends Cubit<DealOrNoDealState> {
  DealOrNoDealCubit()
      : super(DealOrNoDealState(
    suitcases: _generateRandomSuitcases(),
    eliminatedSuitcases: [],
    displayBoxes: _generateDisplayBoxes(),
    dealerOffer: 0,
    gameStage: GameStage.pickSuitcase,
    lastEliminatedValue: null,
  ));

  static List<int> _generateRandomSuitcases() {
    List<int> values = [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000];
    values.shuffle();
    return values;
  }

  static List<int> _generateDisplayBoxes() {
    List<int> values = [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000];
    values.sort();
    return values;
  }

  void selectSuitcase(int index) {
    emit(DealOrNoDealState(
      suitcases: state.suitcases,
      selectedSuitcase: index,
      eliminatedSuitcases: state.eliminatedSuitcases,
      displayBoxes: state.displayBoxes,
      dealerOffer: state.dealerOffer,
      gameStage: GameStage.eliminateSuitcase,
    ));
  }

  void eliminateSuitcase(int index) {
    if (state.gameStage != GameStage.eliminateSuitcase) return;

    int eliminatedValue = state.suitcases[index];
    List<int> newEliminated = List.from(state.eliminatedSuitcases)..add(eliminatedValue);
    double newOffer = _calculateDealerOffer(newEliminated);
    bool isGameOver = newEliminated.length == 9;

    emit(DealOrNoDealState(
      suitcases: state.suitcases,
      selectedSuitcase: state.selectedSuitcase,
      eliminatedSuitcases: newEliminated,
      displayBoxes: state.displayBoxes,
      dealerOffer: newOffer,
      gameStage: isGameOver ? GameStage.gameOver : GameStage.dealOrNoDeal,
      lastEliminatedValue: eliminatedValue,
    ));
  }

  double _calculateDealerOffer(List<int> eliminated) {
    List<int> remainingValues = state.suitcases.where((value) => !eliminated.contains(value)).toList();
    double average = remainingValues.reduce((a, b) => a + b) / remainingValues.length;
    return average * 0.9;
  }

  void handleKeyboardInput(String input) {
    if (int.tryParse(input) != null) {
      int index = int.parse(input); // Adjust for 0-based index
      if (state.gameStage == GameStage.eliminateSuitcase) {
        if (!state.eliminatedSuitcases.contains(state.suitcases[index]) && state.selectedSuitcase != index) {
          eliminateSuitcase(index);
        }
      } else if (state.gameStage == GameStage.pickSuitcase) {
        if (index >= 0 && index < state.suitcases.length) {
          selectSuitcase(index);
        }
      }
    } else if (state.gameStage == GameStage.dealOrNoDeal) {
      if (input.toUpperCase() == 'D') {
        acceptDeal();
      } else if (input.toUpperCase() == 'N') {
        rejectDeal();
      }
    }
  }

  void acceptDeal() {
    emit(DealOrNoDealState(
      suitcases: state.suitcases,
      selectedSuitcase: state.selectedSuitcase,
      eliminatedSuitcases: state.eliminatedSuitcases,
      displayBoxes: state.displayBoxes,
      dealerOffer: state.dealerOffer,
      gameStage: GameStage.gameOver,
    ));
  }

  void rejectDeal() {
    emit(DealOrNoDealState(
      suitcases: state.suitcases,
      selectedSuitcase: state.selectedSuitcase,
      eliminatedSuitcases: state.eliminatedSuitcases,
      displayBoxes: state.displayBoxes,
      dealerOffer: state.dealerOffer,
      gameStage: GameStage.eliminateSuitcase,
    ));
  }

  void resetGame() {
    emit(DealOrNoDealState(
      suitcases: _generateRandomSuitcases(),
      eliminatedSuitcases: [],
      displayBoxes: _generateDisplayBoxes(),
      dealerOffer: 0,
      gameStage: GameStage.pickSuitcase,
    ));
  }
}