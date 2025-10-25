import 'package:flutter/material.dart';

Future<bool?> showDeleteConfirmation({
  required BuildContext context,
  required VoidCallback onDelete,
  final String title = 'Are you sure that you want to delete?',
  final String body = '',
  final String deleteLabel = 'Delete',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
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
