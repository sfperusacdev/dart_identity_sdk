import 'package:flutter/material.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;

  const EmptyPlaceholder({super.key, required this.message, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
              label: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
