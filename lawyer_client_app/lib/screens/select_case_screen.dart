import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_model.dart';
import '../providers/case_provider.dart';

class SelectCaseScreen extends StatefulWidget {
  @override
  _SelectCaseScreenState createState() => _SelectCaseScreenState();
}

class _SelectCaseScreenState extends State<SelectCaseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _caseType = 'Civil'; // Default case type

  final List<String> _caseTypes = [
    'Civil',
    'Criminal',
    'Family',
    'Corporate',
    'Labor'
  ];

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Case'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            DropdownButton<String>(
              value: _caseType,
              onChanged: (String? newValue) {
                setState(() {
                  _caseType = newValue!;
                });
              },
              items: _caseTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newCase = Case(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  caseType: _caseType,
                );

                // Call the provider method to submit the case
                caseProvider.submitCase(newCase).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(caseProvider.status)),
                  );

                  // Optionally, check if the submission was successful before navigating
                  if (caseProvider.status.contains('successfully')) {
                    Navigator.pop(context); // Go back to the dashboard
                  }
                });
              },
              child: const Text('Submit Case'),
            ),

            const SizedBox(height: 20),
            Text(caseProvider.status), // Display submission status
          ],
        ),
      ),
    );
  }
}
