import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroState { work, shortBreak, longBreak }

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroModel>(
  (ref) => PomodoroNotifier(),
);

class PomodoroModel {
  final int timeLeft;
  final PomodoroState state;
  final int completedWorkSessions;

  PomodoroModel({
    required this.timeLeft,
    required this.state,
    required this.completedWorkSessions,
  });
}

class PomodoroNotifier extends StateNotifier<PomodoroModel> {
  PomodoroNotifier()
    : super(
        PomodoroModel(
          timeLeft: 25 * 60,
          state: PomodoroState.work,
          completedWorkSessions: 0,
        ),
      );

  Timer? _timer;
  bool isRunning = false;
  int selectedWorkDuration = 25; // Work duration in minutes

  void startStopTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.timeLeft > 0) {
          state = PomodoroModel(
            timeLeft: state.timeLeft - 1,
            state: state.state,
            completedWorkSessions: state.completedWorkSessions,
          );
        } else {
          timer.cancel();
          _switchState();
        }
      });
    }
    isRunning = !isRunning;
  }

  void _switchState() {
    switch (state.state) {
      case PomodoroState.work:
        final newCompletedSessions = state.completedWorkSessions + 1;
        if (newCompletedSessions % 4 == 0) {
          state = PomodoroModel(
            timeLeft: selectedWorkDuration * 60,
            state: PomodoroState.longBreak,
            completedWorkSessions: newCompletedSessions,
          );
        } else {
          state = PomodoroModel(
            timeLeft: selectedWorkDuration * 60 ~/ 5,
            state: PomodoroState.shortBreak,
            completedWorkSessions: newCompletedSessions,
          );
        }
        break;
      case PomodoroState.shortBreak:
      case PomodoroState.longBreak:
        state = PomodoroModel(
          timeLeft: selectedWorkDuration * 60,
          state: PomodoroState.work,
          completedWorkSessions: state.completedWorkSessions,
        );
        break;
    }
    isRunning = false;
  }

  void resetTimer() {
    _timer?.cancel();
    state = PomodoroModel(
      timeLeft: selectedWorkDuration * 60,
      state: PomodoroState.work,
      completedWorkSessions: 0,
    );
    isRunning = false;
  }

  void updateDuration(int minutes) {
    selectedWorkDuration = minutes;
    resetTimer();
  }
}

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroModel = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    final minutes = (pomodoroModel.timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (pomodoroModel.timeLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getStateText(pomodoroModel.state),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '$minutes:$seconds',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Completed work sessions: ${pomodoroModel.completedWorkSessions}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: Slider(
                value: notifier.selectedWorkDuration.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: '${notifier.selectedWorkDuration} min',
                onChanged: (newValue) {
                  notifier.updateDuration(newValue.toInt());
                },
                activeColor: Colors.red,
                inactiveColor: Colors.red.shade100,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: notifier.startStopTimer,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              child: Text(notifier.isRunning ? 'Pause' : 'Start'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: notifier.resetTimer,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStateText(PomodoroState state) {
    switch (state) {
      case PomodoroState.work:
        return 'Work';
      case PomodoroState.shortBreak:
        return 'Short Break';
      case PomodoroState.longBreak:
        return 'Long Break';
    }
  }
}
