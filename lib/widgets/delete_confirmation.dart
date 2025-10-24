import 'package:flutter/material.dart';

void showDeleteConfirmation({
  required BuildContext context,
  required VoidCallback onDelete,
  final String title = 'Are you sure that you want to delete?',
  final String body = '',
  final String deleteLabel = 'Delete',
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(deleteLabel),
          ),
        ],
      );
    },
  );
}
