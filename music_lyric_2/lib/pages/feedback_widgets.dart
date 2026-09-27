import 'package:flutter/material.dart';

class FeedbackWidgetsPage extends StatefulWidget {
  const FeedbackWidgetsPage({super.key});

  @override
  State<FeedbackWidgetsPage> createState() => _FeedbackWidgetsPageState();
}

class _FeedbackWidgetsPageState extends State<FeedbackWidgetsPage> {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  double progress = 0.3;

  void showAlert() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Dialog'),
        content: const Text('This is an example of an alert dialog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showSnackBar() {
    messengerKey.currentState!.showSnackBar(
      const SnackBar(content: Text('This is a SnackBar!')),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is a modal bottom sheet.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void showSimpleDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose an option'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Option 1'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Option 2'),
          ),
        ],
      ),
    );
  }

  void showBanner() {
    final messenger = messengerKey.currentState!;
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: const Text('This is a MaterialBanner.'),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text('DISMISS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: messengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Feedback Widgets')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                '1. AlertDialog',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showAlert,
                child: const Text('Show Alert Dialog'),
              ),
              const SizedBox(height: 30),

              const Text(
                '2. SnackBar',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showSnackBar,
                child: const Text('Show SnackBar'),
              ),
              const SizedBox(height: 30),

              const Text(
                '3. Tooltip',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Long press or hover over the icon:'),
              const SizedBox(height: 10),
              Tooltip(
                message: 'This is a tooltip',
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                '4. CircularProgressIndicator',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(),
              const SizedBox(height: 30),

              const Text(
                '5. LinearProgressIndicator',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    progress = progress >= 1
                        ? 0
                        : (progress + 0.1).clamp(0.0, 1.0);
                  });
                },
                child: const Text('Add Progress'),
              ),
              const SizedBox(height: 30),

              const Text(
                '6. showModalBottomSheet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showBottomSheet,
                child: const Text('Show Bottom Sheet'),
              ),
              const SizedBox(height: 30),

              const Text(
                '7. showDialog (SimpleDialog)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showSimpleDialog,
                child: const Text('Show Dialog'),
              ),
              const SizedBox(height: 30),

              const Text(
                '8. MaterialBanner',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showBanner,
                child: const Text('Show Banner'),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
