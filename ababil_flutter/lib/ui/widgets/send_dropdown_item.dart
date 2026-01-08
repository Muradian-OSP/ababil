import 'package:flutter/material.dart';

class SendDropdownItem extends StatelessWidget {
  const SendDropdownItem({
    super.key,
    required this.items,
    required this.onSelected,
  });
  final List<String> items;
  final Function(String?) onSelected;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      position: PopupMenuPosition.under,
      icon: Icon(Icons.arrow_drop_down),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem(
            value: item,
            child: Row(
              children: [
                Icon(
                  item.toLowerCase() == 'send'
                      ? Icons.send_rounded
                      : Icons.send_and_archive_sharp,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(item),
              ],
            ),
          );
        }).toList();
      },
      onSelected: onSelected,
    );
  }
}
