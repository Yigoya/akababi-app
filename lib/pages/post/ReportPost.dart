import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportPostPage extends StatefulWidget {
  final String postContent; // Content of the post being reported
  final int id;

  const ReportPostPage({
    Key? key,
    required this.postContent,
    required this.id,
  }) : super(key: key);

  @override
  _ReportPostPageState createState() => _ReportPostPageState();
}

class _ReportPostPageState extends State<ReportPostPage> {
  final TextEditingController _commentsController = TextEditingController();
  String? _selectedReason;

  // List of report reasons
  final List<String> _reportReasons = [
    'Spam',
    'Harassment',
    'Hate Speech',
    'Inappropriate Content',
    'Misinformation',
    'Other'
  ];

  // Function to handle form submission
  void _submitReport() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for reporting.')),
      );
      return;
    }

    // Simulate backend report submission
    print('Report Submitted');
    print('Reason: $_selectedReason');
    print('Additional Comments: ${_commentsController.text}');

    // After submission, navigate back or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display a preview of the post being reported
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post\'s Content:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.postContent,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Reason selection dropdown
            const Text(
              'Reason for Reporting:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a reason',
              ),
              value: _selectedReason,
              items: _reportReasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Additional comments input
            const Text(
              'Additional Comments (Optional):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentsController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add any additional details...',
              ),
            ),
            const SizedBox(height: 20),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final res =
                      await BlocProvider.of<PostCubit>(context).reportPost({
                    'report_id': widget.id,
                    'reason': '$_selectedReason: ${_commentsController.text}'
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: res
                            ? Text('Report submitted')
                            : Text("Report didn't submitted")),
                  );
                },
                child: const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
