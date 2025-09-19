import 'package:flutter/material.dart';

class DuplicateScanNotification {
  static void show(BuildContext context, String code, int quantity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.add_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${code.length > 15 ? '${code.substring(0, 15)}...' : code} 수량: $quantity',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '실행취소',
          textColor: Colors.white,
          onPressed: () {
            // 실행 취소 로직 추가 가능
          },
        ),
      ),
    );
  }
}