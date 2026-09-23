class Fund {
  final int id;
  final String name, category, risk;
  final double return3y, expense;
  const Fund(this.id, this.name, this.category, this.risk, this.return3y, this.expense);
  factory Fund.fromJson(Map<String, dynamic> json) => Fund(
    json['id'] as int, json['name'] as String, json['category'] as String,
    json['risk_level'] as String, (json['three_year_return'] as num).toDouble(),
    (json['expense_ratio'] as num).toDouble(),
  );
}

