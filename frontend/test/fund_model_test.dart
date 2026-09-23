import 'package:flutter_test/flutter_test.dart';
import 'package:mutual_fund_basket/models/fund.dart';

void main() {
  test('parses fund API response', () {
    final fund = Fund.fromJson({'id': 1, 'name': 'Cedar', 'category': 'Equity', 'risk_level': 'High', 'three_year_return': 14.5, 'expense_ratio': 0.65});
    expect(fund.id, 1);
    expect(fund.return3y, 14.5);
  });
}
