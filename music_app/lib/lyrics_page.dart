import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  late final Future<String> _lyrics = rootBundle.loadString(
    'assets/lyrics/total_eclipse_of_the_heart.txt',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lyrics')),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _lyrics,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load the lyrics.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Eclipse of the Heart',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bonnie Tyler',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 28),
                  SelectableText(
                    snapshot.data!,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
