import 'package:flutter/material.dart';
import 'package:vitasense/features/showcase/presentation/screens/vitasense_mockup_screens.dart';

class AiMealsScreen extends StatelessWidget {
  const AiMealsScreen({super.key, this.ingredients});

  final List<String>? ingredients;

  @override
  Widget build(BuildContext context) {
    return const MockupAiMealsScreen();
  }
}
