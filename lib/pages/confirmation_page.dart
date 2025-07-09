import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/swap_controller.dart';

class ConfirmationPage extends StatelessWidget {
  final SwapController swapController = Get.find<SwapController>();

  String _formatAmount(String input) {
    if (input.isEmpty) return '0';

    if (input.contains('.')) {
      input = input.replaceFirst(RegExp(r'(?<=\d)0+$'), '');
      input = input.replaceFirst(RegExp(r'\.$'), '');
    }

    input = input.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.error_outline, color: Colors.black),
            onPressed: () {
              // TODO: แสดง dialog หรือ snackBar อธิบายเพิ่มเติม
            },
          ),
        ],

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _buildCurrencySwapIcon(
                      swapController.fromCurrency.value?.iconPath ?? '',
                      swapController.toCurrency.value?.iconPath ?? '',
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${swapController.fromCurrency.value?.symbol ?? ''} to ${swapController.toCurrency.value?.symbol ?? ''}',
                          style: TextStyle(
                            fontSize: 36,
                            // fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Asset will swap instantly',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Swap ${swapController.fromCurrency.value?.symbol ?? ''}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            '${_formatAmount(swapController.fromAmount.value)} ${swapController.fromCurrency.value?.symbol ?? ''}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To ${swapController.toCurrency.value?.symbol ?? ''}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            '${_formatAmount(swapController.toAmount.value)} ${swapController.toCurrency.value?.symbol ?? ''}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Fee',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              SizedBox(width: 6),
                              Container(
                                width: 18,
                                height: 18,
                                child: Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$0.00',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Rate',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          SizedBox(width: 6),
                          Icon(Icons.error_outline, size: 16, color: Colors.grey[600]),
                        ],
                      ),
                      Obx(() => Text(
                        '1 ${swapController.fromCurrency.value?.symbol} = '
                        '${swapController.exchangeRate.value.toStringAsFixed(6)} '
                        '${swapController.toCurrency.value?.symbol}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      )),
                    ],
                  ),

                  SizedBox(height: 12),
                ],
              ),
            ),

            Spacer(),

            Obx(() => swapController.isLoading.value
    ? Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Processing transaction...'),
        ],
      )
    : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              'Review the above before confirming.\nOnce made, your transaction is irreversible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SlideToConfirmButton(onConfirm: _executeSwap),
        ],
      )),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySwapIcon(String icon1, String icon2) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -8,
            child: Image.asset(
              icon1,
              width: 64,
              height: 64,
              errorBuilder: (_, __, ___) => Icon(Icons.currency_exchange, size: 32),
            ),
          ),
          Positioned(
            right: -8,
            child: Image.asset(
              icon2,
              width: 64,
              height: 64,
              errorBuilder: (_, __, ___) => Icon(Icons.currency_exchange, size: 32),
            ),
          ),
        ],
      ),
    );
  }


  void _executeSwap() async {
    final result = await swapController.executeSwap();
    if (result.success) {
      Get.offAndToNamed('/success', arguments: result.data);
    } else {
      Get.snackbar(
        'Error',
        result.message ?? 'Transaction failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class SlideToConfirmButton extends StatefulWidget {
  final VoidCallback onConfirm;

  SlideToConfirmButton({required this.onConfirm});

  @override
  _SlideToConfirmButtonState createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton> {
  double _dragPosition = 0;
  double _maxDrag = 0;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _maxDrag = constraints.maxWidth - 60;

      return Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                _isConfirmed ? 'Confirmed!' : 'Swipe to confirm',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600]),
              ),
            ),
            Positioned(
              left: _dragPosition,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _dragPosition = (_dragPosition + details.delta.dx)
                        .clamp(0.0, _maxDrag);
                  });
                },
                onPanEnd: (details) {
                  if (_dragPosition >= _maxDrag * 0.8) {
                    setState(() {
                      _dragPosition = _maxDrag;
                      _isConfirmed = true;
                    });
                    widget.onConfirm();
                  } else {
                    setState(() {
                      _dragPosition = 0;
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isConfirmed ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    _isConfirmed ? Icons.check : Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
