import 'package:flutter/material.dart';

void showDeleteConfirmation({
  required BuildContext context,
  required VoidCallback onDelete,
  final String title = 'A you sure that you want to delete?',
  final String body = '',
  final String deleteLable = 'Delete',
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onDelete,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(deleteLable),
          ),
        ],
      );
    },
  );
}
