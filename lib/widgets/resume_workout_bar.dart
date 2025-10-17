
// Widget resumeWorkoutPopup(
//   BuildContext context,
//   ThemeData themeData,
//   Workout currentWorkout,
//   VoidCallback onStateChange,
// ) {
//   return Container(
//     width: double.infinity,
//     decoration: BoxDecoration(
//       color: themeData.colorScheme.secondaryContainer,
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(12),
//         topRight: Radius.circular(12),
//       ),
//       boxShadow: const [
//         BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
//       ],
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Workout in Progress',
//             style: TextStyle(
//               color: themeData.colorScheme.onSecondaryContainer,
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//             ),
//           ),
//           if (currentWorkout.routineId != null)
//             FutureBuilder<Routine?>(
//               future: DatabaseService.instance.getRoutine(
//                 currentWorkout.routineId!,
//               ),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData && snapshot.data != null) {
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(
//                       snapshot.data!.name,
//                       style: TextStyle(
//                         color: themeData.colorScheme.onSecondaryContainer
//                             .withOpacity(0.7),
//                         fontSize: 14,
//                       ),
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               TextButton(
//                 onPressed: () async {
//                   if (currentWorkout.routineId != null) {
//                     try {
//                       final routine = await DatabaseService.instance.getRoutine(
//                         currentWorkout.routineId!,
//                       );
//                       if (routine != null && context.mounted) {
//                         Navigator.of(context)
//                             .push(
//                               MaterialPageRoute<void>(
//                                 builder: (context) => LoggingPage(
//                                   // routine: routine,
//                                   // existingWorkout: currentWorkout,
//                                   routine: routine,
//                                   inProgressWorkout: currentWorkout,
//                                 ),
//                               ),
//                             )
//                             .then((_) {
//                               onStateChange();
//                             });
//                       }
//                     } catch (e) {
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Error loading workout: $e'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     }
//                   }
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: themeData.colorScheme.onSecondaryContainer,
//                   backgroundColor: themeData.colorScheme.primary.withOpacity(
//                     0.2,
//                   ),
//                   textStyle: const TextStyle(fontWeight: FontWeight.bold),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text("Resume"),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   showDeleteConfirmation(
//                     currentWorkout,
//                     context,
//                   ); // Pass the callback
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: themeData.colorScheme.error,
//                   backgroundColor: themeData.colorScheme.error.withOpacity(0.1),
//                   textStyle: const TextStyle(fontWeight: FontWeight.bold),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text("Discard"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// void showDeleteConfirmation(Workout workout, BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Delete Routine'),
//       content: Text(
//         'Are you sure you want to delete "${workout.title}"? This action cannot be undone.',
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(context);
//
//             try {
//               await DatabaseService.instance.deleteWorkout(workout.id!);
//
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${workout.title} deleted')),
//                 );
//               }
//             } catch (e) {
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Error deleting routine: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             }
//           },
//           style: TextButton.styleFrom(foregroundColor: Colors.red),
//           child: const Text('Delete'),
//         ),
//       ],
//     ),
//   );
// }
