class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? count;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.count,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      count: json['count'],
    );
  }
}

class BarcodeDto {
  final int? barcodeId;
  final String barcodeValue;
  final String barcodeType;
  final String? phoneModel;
  final String? status;
  final String? createdDate;
  final String? updatedDate;

  BarcodeDto({
    this.barcodeId,
    required this.barcodeValue,
    required this.barcodeType,
    this.phoneModel,
    this.status,
    this.createdDate,
    this.updatedDate,
  });

  factory BarcodeDto.fromJson(Map<String, dynamic> json) {
    return BarcodeDto(
      barcodeId: json['barcodeId'],
      barcodeValue: json['barcodeValue'],
      barcodeType: json['barcodeType'],
      phoneModel: json['phoneModel'],
      status: json['status'],
      createdDate: json['createdDate'],
      updatedDate: json['updatedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcodeValue': barcodeValue,
      'barcodeType': barcodeType,
      'phoneModel': phoneModel,
    };
  }
}