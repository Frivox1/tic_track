import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_notifier/local_notifier.dart';

enum PomodoroState { work, shortBreak, longBreak }

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

class PomodoroNotifier extends ChangeNotifier {
  PomodoroModel _model = PomodoroModel(
    timeLeft: 25 * 60,
    state: PomodoroState.work,
    completedWorkSessions: 0,
  );

  PomodoroModel get model => _model;

  Timer? _timer;
  bool isRunning = false;
  int selectedWorkDuration = 25;

  void startStopTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_model.timeLeft > 0) {
          _model = PomodoroModel(
            timeLeft: _model.timeLeft - 1,
            state: _model.state,
            completedWorkSessions: _model.completedWorkSessions,
          );
          notifyListeners();
        } else {
          timer.cancel();
          _switchState();
        }
      });
    }
    isRunning = !isRunning;
    notifyListeners();
  }

  void _switchState() {
    switch (_model.state) {
      case PomodoroState.work:
        final newCompletedSessions = _model.completedWorkSessions + 1;
        if (newCompletedSessions % 4 == 0) {
          _model = PomodoroModel(
            timeLeft: 15 * 60,
            state: PomodoroState.longBreak,
            completedWorkSessions: newCompletedSessions,
          );
          _showNotification('Long break', 'It\'s time to take a long break!');
        } else {
          _model = PomodoroModel(
            timeLeft: 5 * 60,
            state: PomodoroState.shortBreak,
            completedWorkSessions: newCompletedSessions,
          );
          _showNotification('Short break', 'It\'s time to take a short break!');
        }
        break;
      case PomodoroState.shortBreak:
      case PomodoroState.longBreak:
        _model = PomodoroModel(
          timeLeft: selectedWorkDuration * 60,
          state: PomodoroState.work,
          completedWorkSessions: _model.completedWorkSessions,
        );
        _showNotification('Work session', 'It\'s time to get back to work!');
        break;
    }
    isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _model = PomodoroModel(
      timeLeft: selectedWorkDuration * 60,
      state: PomodoroState.work,
      completedWorkSessions: 0,
    );
    isRunning = false;
    notifyListeners();
  }

  void updateDuration(int minutes) {
    selectedWorkDuration = minutes;
    resetTimer();
  }

  void _showNotification(String title, String body) {
    LocalNotification notification = LocalNotification(
      title: title,
      body: body,
    );
    notification.show();
  }
}

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PomodoroNotifier(),
      child: Consumer<PomodoroNotifier>(
        builder: (context, notifier, child) {
          final pomodoroModel = notifier.model;
          final minutes = (pomodoroModel.timeLeft ~/ 60).toString().padLeft(
            2,
            '0',
          );
          final seconds = (pomodoroModel.timeLeft % 60).toString().padLeft(
            2,
            '0',
          );

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
        },
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
