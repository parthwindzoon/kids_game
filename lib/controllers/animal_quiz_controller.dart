// lib/controllers/animal_quiz_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';

class AnimalQuizController extends GetxController {
  // Game state
  final RxInt score = 0.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool showSuccessPopup = false.obs;
  final RxBool showWrongPopup = false.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;
  final RxString selectedAnswer = ''.obs;
  final RxBool isAnswered = false.obs;

  // Quiz questions
  final List<QuizQuestion> questions = [];
  final int totalQuestions = 10;

  // Available animals (same as Learn Animals)
  final List<AnimalData> animals = [
    AnimalData(name: 'Duck', audioFile: 'Duck.mp3'),
    AnimalData(name: 'Bear', audioFile: 'Bear.mp3'),
    AnimalData(name: 'Chiken', audioFile: 'Chiken.mp3'),
    AnimalData(name: 'Cow', audioFile: 'Cow.mp3'),
    AnimalData(name: 'Elephant', audioFile: 'Elephant.mp3'),
    AnimalData(name: 'Giraffe', audioFile: 'Giraffe.mp3'),
    AnimalData(name: 'Goat', audioFile: 'Goat.mp3'),
    AnimalData(name: 'Hippopotamus', audioFile: 'Hippopotamus.mp3'),
    AnimalData(name: 'Horse', audioFile: 'Horse.mp3'),
    AnimalData(name: 'Kangaroo', audioFile: 'Kangaroo.mp3'),
    AnimalData(name: 'Leopard', audioFile: 'Leopard.mp3'),
    AnimalData(name: 'Lion', audioFile: 'Lion.mp3'),
    AnimalData(name: 'Monkey', audioFile: 'Monkey.mp3'),
    AnimalData(name: 'Pig', audioFile: 'Pig.mp3'),
    AnimalData(name: 'Rabbit', audioFile: 'Rabbit.mp3'),
    AnimalData(name: 'Rhino', audioFile: 'Rhino.mp3'),
    AnimalData(name: 'Sheep', audioFile: 'Sheep.mp3'),
    AnimalData(name: 'Tiger', audioFile: 'Tiger.mp3'),
    AnimalData(name: 'Zebra', audioFile: 'Zebra.mp3'),
  ];

  final Random random = Random();

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
    _generateQuestions();
  }

  Future<void> _preloadAudio() async {
    try {
      final audioFiles = animals.map((animal) => 'animals/${animal.audioFile}').toList();
      audioFiles.addAll(['success.mp3', 'wrong.mp3', 'celebration.mp3']);
      await FlameAudio.audioCache.loadAll(audioFiles);
      print('✅ All animal quiz audio files preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  void _generateQuestions() {
    questions.clear();
    final shuffledAnimals = List<AnimalData>.from(animals)..shuffle();

    for (int i = 0; i < totalQuestions && i < shuffledAnimals.length; i++) {
      final correctAnimal = shuffledAnimals[i];
      final wrongAnimals = List<AnimalData>.from(animals)
        ..removeWhere((a) => a.name == correctAnimal.name)
        ..shuffle();

      final options = [
        correctAnimal.name,
        wrongAnimals[0].name,
        wrongAnimals[1].name,
        wrongAnimals[2].name,
      ]..shuffle();

      questions.add(QuizQuestion(
        correctAnimal: correctAnimal,
        options: options,
      ));
    }
  }

  QuizQuestion get currentQuestion => questions[currentQuestionIndex.value];

  void selectAnswer(String answer) {
    if (isAnswered.value) return;

    selectedAnswer.value = answer;
    isAnswered.value = true;

    if (answer == currentQuestion.correctAnimal.name) {
      // Correct answer
      score.value += 10;
      _playSuccessSound();
      _showSuccessPopup();

      Future.delayed(const Duration(milliseconds: 1500), () {
        closeSuccessPopup();
        _nextQuestion();
      });
    } else {
      // Wrong answer
      if (score.value > 0) {
        score.value -= 5;
      }
      _playWrongSound();
      _showWrongPopup();

      Future.delayed(const Duration(milliseconds: 1500), () {
        closeWrongPopup();
        _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswer.value = '';
      isAnswered.value = false;
    } else {
      // Quiz completed
      Future.delayed(const Duration(milliseconds: 300), () {
        _showCompletionPopup();
        _playCelebrationSound();
      });
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      await FlameAudio.play('success.mp3');
    } catch (e) {
      print('⚠️ Error playing success sound: $e');
    }
  }

  Future<void> _playWrongSound() async {
    try {
      await FlameAudio.play('wrong.mp3');
    } catch (e) {
      print('⚠️ Error playing wrong sound: $e');
    }
  }

  Future<void> _playCelebrationSound() async {
    try {
      await FlameAudio.play('celebration.mp3');
    } catch (e) {
      print('⚠️ Error playing celebration sound: $e');
    }
  }

  void _showSuccessPopup() {
    showSuccessPopup.value = true;
    _animatePopupIn();
  }

  void _showWrongPopup() {
    showWrongPopup.value = true;
    _animatePopupIn();
  }

  void _showCompletionPopup() {
    showCompletionPopup.value = true;
    _animatePopupIn();
  }

  void _animatePopupIn() {
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    final duration = 400;
    final steps = 25;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        final easeProgress = 1 - (1 - progress) * (1 - progress);
        popupScale.value = 0.3 + (0.7 * easeProgress);
        popupOpacity.value = progress;
      });
    }
  }

  void closeSuccessPopup() {
    showSuccessPopup.value = false;
  }

  void closeWrongPopup() {
    showWrongPopup.value = false;
  }

  void closeCompletionPopup() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.0 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          showCompletionPopup.value = false;
        }
      });
    }
  }

  void resetGame() {
    score.value = 0;
    currentQuestionIndex.value = 0;
    selectedAnswer.value = '';
    isAnswered.value = false;
    closeCompletionPopup();
    _generateQuestions();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class QuizQuestion {
  final AnimalData correctAnimal;
  final List<String> options;

  QuizQuestion({
    required this.correctAnimal,
    required this.options,
  });
}

class AnimalData {
  final String name;
  final String audioFile;

  AnimalData({
    required this.name,
    required this.audioFile,
  });

  String get imagePath => 'assets/images/learn_animals/${name.toLowerCase()}.png';
}