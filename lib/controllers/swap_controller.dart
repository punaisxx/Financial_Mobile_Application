import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../models/currency.dart';
import '../models/swap_transaction.dart';
import '../models/api_response.dart';

class SwapController extends GetxController {
  // Observable variables
  RxList<Currency> availableCurrencies = <Currency>[].obs;
  Rx<Currency?> fromCurrency = Rx<Currency?>(null);
  Rx<Currency?> toCurrency = Rx<Currency?>(null);
  RxString fromAmount = ''.obs;
  RxString toAmount = ''.obs;
  RxDouble exchangeRate = 0.0.obs;
  RxBool isLoading = false.obs;
  RxBool canSwap = false.obs;

  Timer? _priceUpdateTimer;
  final Random _random = Random();

  String _cleanInput(String input) {
    // ถ้าไม่มีอะไรเลยก็ส่งกลับ
    if (input.isEmpty) return '';

    // รองรับ "." อย่างเดียว (ตอนผู้ใช้เริ่มพิมพ์)
    if (input == '.') return '0.';

    // เอา 0 นำหน้าออก ถ้าไม่ใช่ 0.xxx
    input = input.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // จำกัดทศนิยม 8 หลัก
    final parts = input.split('.');
    if (parts.length == 2) {
      final intPart = parts[0].isEmpty ? '0' : parts[0];
      final decPart = parts[1].substring(0, min(8, parts[1].length));
      input = '$intPart.$decPart';
    }

    // ตัด trailing zeros หลังจุดทศนิยม
    if (input.contains('.')) {
      input = input.replaceFirst(RegExp(r'(?<=\d)0+$'), '');
      input = input.replaceFirst(RegExp(r'\.$'), ''); // ไม่ให้ค้าง "."
    }

    return input;
  }


  @override
  void onInit() {
    super.onInit();
    _initializeCurrencies();
    _startPriceUpdates();
    
    // Listen to amount changes
    ever(fromAmount, (_) => _calculateToAmount());
    ever(toAmount, (_) => _calculateFromAmount());
    ever(fromCurrency, (_) => _updateExchangeRate());
    ever(toCurrency, (_) => _updateExchangeRate());
  }

  @override
  void onClose() {
    _priceUpdateTimer?.cancel();
    super.onClose();
  }

  void _initializeCurrencies() {
    availableCurrencies.value = [
      Currency(
        symbol: 'USDT',
        name: 'Tether',
        iconPath: 'assets/images/currencies/usdt.png',
        balance: 1000.0,
        price: 1.0,
      ),
      Currency(
        symbol: 'ETH',
        name: 'Ethereum',
        iconPath: 'assets/images/currencies/eth.png',
        balance: 2.5,
        price: 2500.0,
      ),
      Currency(
        symbol: 'BTC',
        name: 'Bitcoin',
        iconPath: 'assets/images/currencies/btc.png',
        balance: 0.1,
        price: 45000.0,
      ),
      Currency(
        symbol: 'BNB',
        name: 'Binance Coin',
        iconPath: 'assets/images/currencies/bnb.png',
        balance: 10.0,
        price: 300.0,
      ),
    ];

    // Set default currencies
    fromCurrency.value = availableCurrencies.first;
    toCurrency.value = availableCurrencies[1];
    _updateExchangeRate();
  }

  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updatePrices();
    });
  }

  void _updatePrices() {
    for (int i = 0; i < availableCurrencies.length; i++) {
      final currency = availableCurrencies[i];
      if (currency.symbol != 'USDT') {
        // Simulate price fluctuation ±5%
        final fluctuation = (_random.nextDouble() - 0.5) * 0.1;
        final newPrice = currency.price * (1 + fluctuation);
        
        availableCurrencies[i] = Currency(
          symbol: currency.symbol,
          name: currency.name,
          iconPath: currency.iconPath,
          balance: currency.balance,
          price: newPrice,
        );
      }
    }
    _updateExchangeRate();
  }

  void _updateExchangeRate() {
    if (fromCurrency.value != null && toCurrency.value != null) {
      exchangeRate.value = fromCurrency.value!.price / toCurrency.value!.price;
      _calculateToAmount();
    }
  }

  void _calculateToAmount() {
    if (fromAmount.value.isNotEmpty && exchangeRate.value > 0) {
      final amount = double.tryParse(fromAmount.value) ?? 0;
      final result = (amount * exchangeRate.value).toStringAsFixed(8);
      toAmount.value = _cleanInput(result);
    }
    _validateSwap();
  }

  void _calculateFromAmount() {
    if (toAmount.value.isNotEmpty && exchangeRate.value > 0) {
      final amount = double.tryParse(toAmount.value) ?? 0;
      fromAmount.value = (amount / exchangeRate.value).toStringAsFixed(8);
    }
    _validateSwap();
  }

  void _validateSwap() {
    if (fromCurrency.value == null || fromAmount.value.isEmpty) {
      canSwap.value = false;
      return;
    }

    final amount = double.tryParse(fromAmount.value) ?? 0;
    canSwap.value = amount > 0 && amount <= fromCurrency.value!.balance;
  }

  void setFromCurrency(Currency currency) {
    fromCurrency.value = currency;
  }

  void setToCurrency(Currency currency) {
    toCurrency.value = currency;
  }

  void setFromAmount(String amount) {
    fromAmount.value = amount;
  }

  void setToAmount(String amount) {
    toAmount.value = amount;
  }

  void swapCurrencies() {
    final temp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = temp;
    
    // Swap amounts
    final tempAmount = fromAmount.value;
    fromAmount.value = toAmount.value;
    toAmount.value = tempAmount;
  }

  void setMaxAmount() {
    if (fromCurrency.value != null) {
      fromAmount.value = fromCurrency.value!.balance.toString();
    }
  }

  // Mock API function
  Future<ApiResponse<SwapTransaction>> executeSwap() async {
    isLoading.value = true;
    
    try {
      // Simulate API delay
      await Future.delayed(Duration(seconds: 2));
      
      // Simulate 90% success rate
      if (_random.nextDouble() < 0.9) {
        final transaction = SwapTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          fromCurrency: fromCurrency.value!,
          toCurrency: toCurrency.value!,
          fromAmount: double.parse(fromAmount.value),
          toAmount: double.parse(toAmount.value),
          exchangeRate: exchangeRate.value,
          timestamp: DateTime.now(),
          status: 'completed',
        );
        
        // Update balance (mock)
        _updateBalance();
        
        return ApiResponse.success(transaction);
      } else {
        return ApiResponse.error('Transaction failed. Please try again.');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateBalance() {
    // Simulate the balance update
    final fromAmount = double.parse(this.fromAmount.value);
    final toAmount = double.parse(this.toAmount.value);
    
    // Find and update balances
    for (int i = 0; i < availableCurrencies.length; i++) {
      final currency = availableCurrencies[i];
      if (currency.symbol == fromCurrency.value!.symbol) {
        availableCurrencies[i] = Currency(
          symbol: currency.symbol,
          name: currency.name,
          iconPath: currency.iconPath,
          balance: currency.balance - fromAmount,
          price: currency.price,
        );
      } else if (currency.symbol == toCurrency.value!.symbol) {
        availableCurrencies[i] = Currency(
          symbol: currency.symbol,
          name: currency.name,
          iconPath: currency.iconPath,
          balance: currency.balance + toAmount,
          price: currency.price,
        );
      }
    }
  }
}