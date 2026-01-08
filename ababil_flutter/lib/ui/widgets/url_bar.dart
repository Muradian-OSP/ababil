// import 'package:flutter/material.dart';

// class UrlBar extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback onSend;
//   final bool isLoading;

//   const UrlBar({
//     super.key,
//     required this.controller,
//     required this.onSend,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         border: Border(
//           bottom: BorderSide(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? const Color(0xFF3D3D3D)
//                 : Colors.grey.shade300,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               style: const TextStyle(fontSize: 14),
//               decoration: const InputDecoration(
//                 hintText: 'Enter request URL',
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 8),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 80,
//             child: ElevatedButton(
//               onPressed: isLoading ? null : onSend,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               child: isLoading
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('Send', style: TextStyle(fontSize: 13)),
//                         SizedBox(width: 4),
//                         Icon(Icons.send, size: 16),
//                       ],
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
