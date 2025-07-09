class Currency {
  final String symbol;
  final String name;
  final String iconPath; // ← ใช้ path ของไฟล์ .png
  final double balance;
  final double price;

  Currency({
    required this.symbol,
    required this.name,
    required this.iconPath,
    required this.balance,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'iconPath': iconPath,
      'balance': balance,
      'price': price,
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      symbol: json['symbol'],
      name: json['name'],
      iconPath: json['iconPath'], // <- ต้องตรง
      balance: json['balance']?.toDouble() ?? 0.0,
      price: json['price']?.toDouble() ?? 0.0,
    );
  }
}