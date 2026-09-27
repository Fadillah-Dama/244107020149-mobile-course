import 'package:flutter/material.dart';

class AnimationWidgetsPage extends StatefulWidget {
  const AnimationWidgetsPage({super.key});

  @override
  State<AnimationWidgetsPage> createState() => _AnimationWidgetsPageState();
}

class _AnimationWidgetsPageState extends State<AnimationWidgetsPage>
    with TickerProviderStateMixin {
  bool containerChanged = false;
  bool isVisible = true;
  int number = 0;

  late final AnimationController fadeController;
  late final AnimationController scaleController;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1,
    );
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.3,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    fadeController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Widgets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              '1. AnimatedContainer',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: containerChanged ? 180 : 80,
              height: containerChanged ? 80 : 50,
              color: containerChanged ? Colors.orange : Colors.blue,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => containerChanged = !containerChanged);
              },
              child: const Text('Change Container'),
            ),
            const SizedBox(height: 30),

            const Text(
              '2. AnimatedOpacity',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const Icon(Icons.favorite, size: 60, color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => isVisible = !isVisible);
              },
              child: const Text('Show / Hide Heart'),
            ),
            const SizedBox(height: 30),

            const Text(
              '3. AnimatedSwitcher',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                '$number',
                key: ValueKey(number),
                style: const TextStyle(fontSize: 40),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => number++);
              },
              child: const Text('Add Number'),
            ),
            const SizedBox(height: 30),

            const Text(
              '4. Hero',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Tap the star to open another page:'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const _HeroExamplePage(),
                  ),
                );
              },
              child: const Hero(
                tag: 'starHero',
                child: Icon(Icons.star, size: 70, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              '5. FadeTransition',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: fadeController,
              child: const Icon(
                Icons.music_note,
                size: 60,
                color: Colors.purple,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (fadeController.status == AnimationStatus.forward ||
                    fadeController.value == 1) {
                  fadeController.reverse();
                } else {
                  fadeController.forward();
                }
              },
              child: const Text('Fade In / Out'),
            ),
            const SizedBox(height: 30),

            const Text(
              '6. ScaleTransition',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ScaleTransition(
              scale: scaleController,
              child: const Icon(Icons.circle, size: 60, color: Colors.green),
            ),
            ElevatedButton(
              onPressed: () {
                if (scaleController.status == AnimationStatus.forward ||
                    scaleController.value == 1) {
                  scaleController.reverse();
                } else {
                  scaleController.forward();
                }
              },
              child: const Text('Grow / Shrink Circle'),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _HeroExamplePage extends StatelessWidget {
  const _HeroExamplePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Example')),
      body: const Center(
        child: Hero(
          tag: 'starHero',
          child: Icon(Icons.star, size: 200, color: Colors.amber),
        ),
      ),
    );
  }
}
