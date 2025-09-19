import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeItem {
  final String id;
  final String code;
  final BarcodeFormat format;
  final DateTime scannedAt;
  int quantity;
  bool isSelected;

  BarcodeItem({
    required this.id,
    required this.code,
    required this.format,
    required this.scannedAt,
    this.quantity = 1,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'format': format.name,
      'scannedAt': scannedAt.toIso8601String(),
      'quantity': quantity,
    };
  }

  factory BarcodeItem.fromJson(Map<String, dynamic> json) {
    return BarcodeItem(
      id: json['id'],
      code: json['code'],
      format: BarcodeFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => BarcodeFormat.unknown,
      ),
      scannedAt: DateTime.parse(json['scannedAt']),
      quantity: json['quantity'] ?? 1,
    );
  }

  BarcodeItem copyWith({
    String? id,
    String? code,
    BarcodeFormat? format,
    DateTime? scannedAt,
    int? quantity,
    bool? isSelected,
  }) {
    return BarcodeItem(
      id: id ?? this.id,
      code: code ?? this.code,
      format: format ?? this.format,
      scannedAt: scannedAt ?? this.scannedAt,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}