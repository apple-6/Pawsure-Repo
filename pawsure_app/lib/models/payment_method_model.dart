// pawsure_app/lib/models/payment_method_model.dart

class PaymentMethodModel {
  final int id;
  final String cardType;
  final String lastFourDigits;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;
  final String? nickname;

  PaymentMethodModel({
    required this.id,
    required this.cardType,
    required this.lastFourDigits,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    this.nickname,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int,
      cardType: json['cardType'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      cardholderName: json['cardholderName'] as String,
      expiryMonth: json['expiryMonth'] as String,
      expiryYear: json['expiryYear'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      nickname: json['nickname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardType': cardType,
      'lastFourDigits': lastFourDigits,
      'cardholderName': cardholderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'nickname': nickname,
    };
  }

  String get displayName => nickname ?? '$cardType •••• $lastFourDigits';
  String get expiry => '$expiryMonth/$expiryYear';
  
  String get cardIcon {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '💳';
      case 'amex':
        return '💳';
      default:
        return '💳';
    }
  }
}

