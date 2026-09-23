import 'package:flutter/material.dart';
import '../models/fund.dart';

class FundCard extends StatelessWidget {
  const FundCard({super.key, required this.fund, required this.inBasket, required this.basketView, required this.busy, required this.onPressed});
  final Fund fund;
  final bool inBasket, basketView, busy;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Padding(
      padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(fund.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 5, children: [
          Chip(label: Text(fund.category), visualDensity: VisualDensity.compact),
          Chip(label: Text('${fund.risk} risk'), backgroundColor: fund.risk == 'High' ? colors.errorContainer : colors.secondaryContainer, visualDensity: VisualDensity.compact),
        ]),
        Text('3-year return  ${fund.return3y.toStringAsFixed(1)}%  •  Expense  ${fund.expense.toStringAsFixed(2)}%'),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(
          onPressed: busy || (!basketView && inBasket) ? null : onPressed,
          icon: Icon(basketView ? Icons.remove_circle_outline : (inBasket ? Icons.check : Icons.add)),
          label: Text(basketView ? 'Remove' : (inBasket ? 'In basket' : 'Add to basket')),
        )),
      ]),
    ));
  }
}
