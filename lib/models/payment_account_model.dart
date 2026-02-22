enum PaymentMethodType { bank, upi, qrCode, phonePe, googlePay, paytm }

extension PaymentMethodTypeExt on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.bank:
        return 'Bank Transfer';
      case PaymentMethodType.upi:
        return 'UPI';
      case PaymentMethodType.qrCode:
        return 'QR Code';
      case PaymentMethodType.phonePe:
        return 'PhonePe';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.paytm:
        return 'Paytm';
    }
  }

  bool get usesUpi =>
      this == PaymentMethodType.upi ||
      this == PaymentMethodType.phonePe ||
      this == PaymentMethodType.googlePay ||
      this == PaymentMethodType.paytm;

  bool get usesBank => this == PaymentMethodType.bank;
  bool get usesQr => this == PaymentMethodType.qrCode;
}

class PaymentAccountModel {
  final String id;
  String name; // Display name e.g. "Account 1", "Main UPI"
  PaymentMethodType type;
  bool isActive;

  // Bank fields
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  String? accountHolderName;

  // UPI / PhonePe / Google Pay / Paytm
  String? upiId;

  // QR Code
  String? qrCodePath; // Local file path to QR image

  final DateTime createdAt;

  PaymentAccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.isActive = true,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.upiId,
    this.qrCodePath,
    required this.createdAt,
  });

  PaymentAccountModel copyWith({
    String? id,
    String? name,
    PaymentMethodType? type,
    bool? isActive,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    String? upiId,
    String? qrCodePath,
    DateTime? createdAt,
  }) {
    return PaymentAccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      upiId: upiId ?? this.upiId,
      qrCodePath: qrCodePath ?? this.qrCodePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
