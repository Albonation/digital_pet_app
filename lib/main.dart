/*
Author: Alan Pruett
*/



import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  double energyLevel = 50.0;

  final TextEditingController nameController = TextEditingController();

  late final Timer winTimer;
  int happinessSeconds = 0;
  bool hasWon = false;
  bool hasLost = false;
  Timer? hungerTimer;

  @override
  void initState() {
    super.initState();
    startHungerTimer();
    winTimer = Timer.periodic(const Duration(seconds: 1), onTimerTick);
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer.cancel();
    nameController.dispose();
    super.dispose();
  }

  void onTimerTick(Timer timer) {
    if (hasWon || hasLost) {return;}
    updateWinLossState(timer);
  }

  void updateWinLossState(Timer timer) {
    if (happinessLevel > 80) {
      happinessSeconds++;

      if (happinessSeconds >= 180 && !hasWon) {
        setState(() {
          hasWon = true;
        });
        timer.cancel();
      }
    }
    else {
      happinessSeconds = 0;
    }

    if (hungerLevel >= 100 && happinessLevel <= 10 && !hasLost) {
      setState(() {
        hasLost = true;
      });
      timer.cancel();
    }
  }

  void startHungerTimer() {
    hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
          (timer) {
        setState(() {
          _updateHunger();
        });
      },
    );
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      energyLevel -= 10.0;
      _updateHunger();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      energyLevel += 5.0;
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
    } else {
      happinessLevel += 10;
    }
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
      }
    });
  }

  Color _getMoodColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }


  (String, String) _getMoodTextAndEmoji() {
    if (happinessLevel > 70) {
      return ("Happy", "😊");
    } else if (happinessLevel >= 30) {
      return ("Neutral", "😐");
    } else {
      return ("Unhappy", "😢");
    }
  }

  //widget to display energy level as a progress bar
  Widget _buildEnergyBar() {
    return Column(
      children: [
        Text('Energy Level: ${energyLevel.toInt()}%', style: TextStyle(fontSize: 20.0)),
        SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: energyLevel / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }

  Widget _buildWinLossMessage() {
    if (hasWon) {
      return Text('Congratulations! You won!',
          style: TextStyle(fontSize: 24.0, color: Colors.green));
    } else if (hasLost) {
      return Text('Game Over',
          style: TextStyle(fontSize: 24.0, color: Colors.red));
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildPetImage() {
    return ColorFiltered(
        colorFilter: ColorFilter.mode(
          _getMoodColor(),
          BlendMode.modulate,
        ),
        child: Image.asset('assets/pet_image.png', width: 150, height: 150)
    );
  }

  Widget _buildMoodIndicator() {
    final (moodText, moodEmoji) = _getMoodTextAndEmoji();
    final moodColor = _getMoodColor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(moodEmoji, style: TextStyle(fontSize: 24.0)),
        SizedBox(width: 8.0),
        Text(moodText, style: TextStyle(fontSize: 20.0, color: moodColor)),
      ],
    );
  }

  Widget _buildNameInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Enter Pet Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        ElevatedButton(
          onPressed: () {
            setState(() {
              petName = nameController.text;
            });
          },
          child: Text('Set Name'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildWinLossMessage(),
            _buildNameInput(),
            Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPetImage(),
                const SizedBox(width: 16.0),
                _buildMoodIndicator(),
              ],
            ),
            _buildEnergyBar(),
          ],
        ),
      ),
    );
  }
}