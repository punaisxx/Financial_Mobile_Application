import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/swap_controller.dart';
import '../controllers/auth_controller.dart';

class SwapPage extends StatefulWidget {
  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  final SwapController swapController = Get.put(SwapController());
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  bool _isFromFocused = false;
  bool _isToFocused = false;

  @override
  void initState() {
    super.initState();

    _fromFocusNode.addListener(() {
      setState(() {
        _isFromFocused = _fromFocusNode.hasFocus;
      });
    });

    _toFocusNode.addListener(() {
      setState(() {
        _isToFocused = _toFocusNode.hasFocus;
      });
    });

    ever<String>(swapController.fromAmount, (val) {
      if (_fromController.text != val) {
        _fromController.text = val;
        _fromController.selection = TextSelection.fromPosition(
          TextPosition(offset: _fromController.text.length),
        );
      }
    });

    ever<String>(swapController.toAmount, (val) {
      if (_toController.text != val) {
        _toController.text = val;
        _toController.selection = TextSelection.fromPosition(
          TextPosition(offset: _toController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _onKeyboardTap(String value) {
    final controller = _isFromFocused ? _fromController : _toController;
    final currentText = controller.text;
    String newText;

    if (value == 'backspace') {
      if (currentText.isNotEmpty) {
        newText = currentText.substring(0, currentText.length - 1);
      } else {
        newText = '';
      }
    } else if (value == '.' && currentText.contains('.')) {
      return; 
    } else if (value == '.' && currentText.isEmpty) {
      newText = '0.';
    } else {
      newText = currentText + value;
    }

    if (newText.contains('.')) {
      final parts = newText.split('.');
      if (parts.length > 1 && parts[1].length > 8) {
        return;
      }
    }

    controller.text = newText;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );

    if (_isFromFocused) {
      swapController.setFromAmount(newText);
    } else {
      swapController.setToAmount(newText);
    }
  }

  bool _canSwap() {
    final fromCurrency = swapController.fromCurrency.value;
    final toCurrency = swapController.toCurrency.value;
    final fromAmount = swapController.fromAmount.value;
    
    // Check if currencies are selected and different
    if (fromCurrency == null || toCurrency == null) return false;
    if (fromCurrency.symbol == toCurrency.symbol) return false;
    
    // Check if amount is valid
    final amount = double.tryParse(fromAmount) ?? 0.0;
    if (amount <= 0) return false;
    
    return swapController.canSwap.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: authController.signOut,
        ),
        title: Text('Swap', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwapCard(title: 'From', isFrom: true),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -20), 
                          child: Container(
                            margin: EdgeInsets.only(top: 40), 
                            child: _buildSwapCard(title: 'To', isFrom: false),
                          ),
                        ),
                        
                        Transform.translate(
                          offset: Offset(0, -20),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                swapController.swapCurrencies();
                                _fromController.clear();
                                _toController.clear();
                                swapController.setFromAmount('');
                                swapController.setToAmount('');
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9A7AF7),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.grey[300]!, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Icon(Icons.swap_vert, size: 28, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Transform.translate(
                      offset: Offset(0, -4),
                      child: Obx(() {
                        final from = swapController.fromCurrency.value?.symbol ?? '';
                        final to = swapController.toCurrency.value?.symbol ?? '';
                        final rate = swapController.exchangeRate.value.toStringAsFixed(6);
                        
                        if (from == to || from.isEmpty || to.isEmpty) {
                          return SizedBox(height: 20);
                        }
                        
                        return Center(
                          child: Text(
                            '1 $from ≈ $rate $to',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),

                    if (!(_isFromFocused || _isToFocused)) ...[
                      SizedBox(height: 8), // ลดระยะห่าง
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _canSwap()
                                  ? () => Get.toNamed('/confirmation')
                                  : null,
                              child: Text('Continue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canSwap()
                                    ? Colors.black
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
            if (_isFromFocused || _isToFocused) _buildCustomKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapCard({required String title, required bool isFrom}) {
    final controller = isFrom ? _fromController : _toController;
    final focusNode = isFrom ? _fromFocusNode : _toFocusNode;

    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 2),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  readOnly: true,
                  showCursor: true,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
              Spacer(),
              Obx(() {
                final currency = isFrom
                    ? swapController.fromCurrency.value
                    : swapController.toCurrency.value;

                return GestureDetector(
                  onTap: () => _showCurrencySelector(isFrom),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          currency?.iconPath ?? 'assets/images/currencies/usdt.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (_, __, ___) => Icon(Icons.currency_exchange),
                        ),
                        SizedBox(width: 8),
                        Text(
                          currency?.symbol ?? 'Select',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 8),
          if (isFrom)
            Obx(() {
              final fromCurrency = swapController.fromCurrency.value;
              final maxValue = fromCurrency?.balance ?? 0.0;

              return Text(
                'Max: ${maxValue.toStringAsFixed(4)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCustomKeyboard() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildKeyboardButton('1'),
              _buildKeyboardButton('2'),
              _buildKeyboardButton('3'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildKeyboardButton('4'),
              _buildKeyboardButton('5'),
              _buildKeyboardButton('6'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildKeyboardButton('7'),
              _buildKeyboardButton('8'),
              _buildKeyboardButton('9'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildKeyboardButton('.'),
              _buildKeyboardButton('0'),
              _buildKeyboardButton('backspace', isBackspace: true),
            ],
          ),
          SizedBox(height: 16),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSwap()
                      ? () => Get.toNamed('/confirmation')
                      : null,
                  child: Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSwap()
                        ? Colors.black
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildKeyboardButton(String value, {bool isBackspace = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => _onKeyboardTap(value),
          child: Container(
            height: 50,
            child: Center(
              child: isBackspace
                  ? Icon(Icons.backspace_outlined, size: 20, color: Colors.grey[600])
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencySelector(bool isFrom) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            ...swapController.availableCurrencies.map((currency) {
              return ListTile(
                leading: Image.asset(
                  currency.iconPath,
                  height: 32,
                  width: 32,
                  errorBuilder: (_, __, ___) => Icon(Icons.currency_bitcoin),
                ),
                title: Text(currency.name),
                subtitle: Text(currency.symbol),
                trailing: Text('\$${currency.price.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  if (isFrom) {
                    swapController.setFromCurrency(currency);
                    // Clear amounts when selecting new currency
                    _fromController.clear();
                    _toController.clear();
                    swapController.setFromAmount('');
                    swapController.setToAmount('');
                  } else {
                    swapController.setToCurrency(currency);
                    _fromController.clear();
                    _toController.clear();
                    swapController.setFromAmount('');
                    swapController.setToAmount('');
                  }
                  Get.back();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}