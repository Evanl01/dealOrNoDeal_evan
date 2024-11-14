import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'DealOrNoDealCubit.dart';

void main() {
  runApp(const DealOrNoDealApp());
}

class DealOrNoDealApp extends StatelessWidget {
  const DealOrNoDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal or No Deal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => DealOrNoDealCubit(),
        child: const DealOrNoDealPage(),
      ),
    );
  }
}

class DealOrNoDealPage extends StatefulWidget {
  const DealOrNoDealPage({super.key});

  @override
  _DealOrNoDealPageState createState() => _DealOrNoDealPageState();
}

class _DealOrNoDealPageState extends State<DealOrNoDealPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal or No Deal'),
      ),
      body: BlocBuilder<DealOrNoDealCubit, DealOrNoDealState>(
        builder: (context, state) {
          return RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (event) {
              if (event is RawKeyDownEvent) {
                context.read<DealOrNoDealCubit>().handleKeyboardInput(event.data.keyLabel);
              }
            },
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  _getInstructionText(state),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                if (state.gameStage == GameStage.dealOrNoDeal)
                  Text(
                    'Dealer Offer: \$${state.dealerOffer.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24),
                  ),
                if (state.gameStage == GameStage.dealOrNoDeal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<DealOrNoDealCubit>().acceptDeal();
                        },
                        child: const Text('Deal (D)'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<DealOrNoDealCubit>().rejectDeal();
                        },
                        child: const Text('No Deal (N)'),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (state.lastEliminatedValue != null)
                  Text(
                    'Suitcase Value eliminated: \$${state.lastEliminatedValue}',
                    style: const TextStyle(fontSize: 24),
                  ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 2,
                  ),
                  itemCount: state.suitcases.length,
                  itemBuilder: (context, index) {
                    bool isSelected = state.selectedSuitcase == index;
                    bool isEliminated = state.eliminatedSuitcases.contains(state.suitcases[index]);

                    return GestureDetector(
                      onTap: isSelected || isEliminated
                          ? null
                          : () {
                        if (state.selectedSuitcase == null) {
                          context.read<DealOrNoDealCubit>().selectSuitcase(index);
                        } else {
                          context.read<DealOrNoDealCubit>().eliminateSuitcase(index);
                        }
                      },
                      child: Card(
                        color: isSelected
                            ? Colors.green
                            : isEliminated
                            ? Colors.red
                            : Colors.blue,
                        child: Center(
                          child: Text(
                            'Suitcase ${index}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (state.gameStage == GameStage.gameOver)
                  ElevatedButton(
                    onPressed: () {
                      context.read<DealOrNoDealCubit>().resetGame();
                    },
                    child: const Text('Reset Game'),
                  ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(state.displayBoxes.length, (index) {
                    bool isEliminated = state.eliminatedSuitcases.contains(state.displayBoxes[index]);
                    return Container(
                      width: 50,
                      height: 50,
                      color: isEliminated ? Colors.grey : Colors.blue,
                      child: Center(
                        child: Text(
                          '${state.displayBoxes[index]}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getInstructionText(DealOrNoDealState state) {
    switch (state.gameStage) {
      case GameStage.pickSuitcase:
        return 'Pick a suitcase to hold';
      case GameStage.eliminateSuitcase:
        return 'Pick a suitcase to eliminate';
      case GameStage.dealOrNoDeal:
        return 'Deal or No Deal? (Press D for Deal, N for No Deal)';
      case GameStage.gameOver:
        return 'Game Over! You won \$${state.suitcases[state.selectedSuitcase!]}';
      default:
        return '';
    }
  }
}