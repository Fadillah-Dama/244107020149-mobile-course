import 'package:flutter/material.dart';

class InputFormPage extends StatefulWidget {
  const InputFormPage({super.key});

  @override
  State<InputFormPage> createState() => _InputFormPageState();
}

class _InputFormPageState extends State<InputFormPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // TextField
  final TextEditingController messageController = TextEditingController();

  // TextFormField
  final TextEditingController nameController = TextEditingController();

  // Checkbox
  bool isChecked = false;

  // Radio
  String? selectedGender;

  // Switch
  bool isSwitched = false;

  // Slider
  double sliderValue = 0;

  // Date and Time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    messageController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // DATE PICKER
  Future<void> pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // TIME PICKER
  Future<void> pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  // SHOW USER INPUT
  void showResult() {
    if (formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('User Input'),
            content: SingleChildScrollView(
              child: Text(
                'Name: ${nameController.text}\n\n'
                'Message: ${messageController.text}\n\n'
                'Agreement: ${isChecked ? "Yes" : "No"}\n\n'
                'Gender: ${selectedGender ?? "Not selected"}\n\n'
                'Notification: ${isSwitched ? "ON" : "OFF"}\n\n'
                'Slider Value: ${sliderValue.round()}\n\n'
                'Date: ${selectedDate == null ? "Not selected" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"}\n\n'
                'Time: ${selectedTime == null ? "Not selected" : selectedTime!.format(context)}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input & Form Widgets')),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  '1. TextField',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Enter your message',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  '2. TextFormField',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  '3. Checkbox',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Card(
                  elevation: 4,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'I agree to the terms and conditions',
                          ),
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  '4. Radio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Male'),
                  value: 'Male',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Female'),
                  value: 'Female',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                Text(
                  selectedGender == null
                      ? 'No option selected'
                      : 'Selected: $selectedGender',
                ),

                const SizedBox(height: 30),

                const Text(
                  '5. Switch',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notification'),
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                ),

                Text('Notification: ${isSwitched ? "ON" : "OFF"}'),

                const SizedBox(height: 30),

                const Text(
                  '6. Slider',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text('Value: ${sliderValue.round()}'),

                Slider(
                  value: sliderValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: sliderValue.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  '7. DatePicker',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Choose Date'),
                ),

                const SizedBox(height: 10),

                Text(
                  selectedDate == null
                      ? 'No date selected'
                      : 'Selected Date: '
                            '${selectedDate!.day}/'
                            '${selectedDate!.month}/'
                            '${selectedDate!.year}',
                ),

                const SizedBox(height: 30),

                const Text(
                  '8. TimePicker',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: pickTime,
                  icon: const Icon(Icons.access_time),
                  label: const Text('Choose Time'),
                ),

                const SizedBox(height: 10),

                Text(
                  selectedTime == null
                      ? 'No time selected'
                      : 'Selected Time: '
                            '${selectedTime!.format(context)}',
                ),

                const SizedBox(height: 30),

                const Text(
                  '9. Form',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: showResult,
                    child: const Text('Submit'),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
