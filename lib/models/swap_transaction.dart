import 'currency.dart';

class SwapTransaction {
  final String id;
  final Currency fromCurrency;
  final Currency toCurrency;
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;
  final DateTime timestamp;
  final String status;

  SwapTransaction({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCurrency': fromCurrency.toJson(),
      'toCurrency': toCurrency.toJson(),
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'exchangeRate': exchangeRate,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory SwapTransaction.fromJson(Map<String, dynamic> json) {
    return SwapTransaction(
      id: json['id'],
      fromCurrency: Currency.fromJson(json['fromCurrency']),
      toCurrency: Currency.fromJson(json['toCurrency']),
      fromAmount: json['fromAmount']?.toDouble() ?? 0.0,
      toAmount: json['toAmount']?.toDouble() ?? 0.0,
      exchangeRate: json['exchangeRate']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
    );
  }
}