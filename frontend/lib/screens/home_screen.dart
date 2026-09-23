import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../services/fund_api.dart';
import '../widgets/fund_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final api = FundApi();
  int tab = 0;
  bool loading = true;
  int? workingId;
  String? error;
  List<Fund> funds = [], basket = [];
  @override void initState() { super.initState(); reload(); }
  Future<void> reload() async {
    setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([api.funds(), api.basket()]);
      if (mounted) setState(() { funds = results[0]; basket = results[1]; });
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> change(Fund fund, bool adding) async {
    setState(() => workingId = fund.id);
    try {
      if (adding) { await api.add(fund.id); } else { await api.remove(fund.id); }
      final latest = await api.basket();
      if (mounted) setState(() => basket = latest);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        await reload();
      }
    } finally { if (mounted) setState(() => workingId = null); }
  }
  @override Widget build(BuildContext context) {
    final shown = tab == 0 ? funds : basket;
    final ids = basket.map((f) => f.id).toSet();
    return Scaffold(
      appBar: AppBar(title: Text(tab == 0 ? 'Explore funds' : 'My basket'), actions: [IconButton(tooltip: 'Log out', onPressed: () => AuthService().logout(), icon: const Icon(Icons.logout))]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (index) { setState(() => tab = index); reload(); }, destinations: const [NavigationDestination(icon: Icon(Icons.list_alt), label: 'Funds'), NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: 'Basket')]),
      body: loading ? const Center(child: CircularProgressIndicator()) : error != null
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!, textAlign: TextAlign.center), TextButton(onPressed: reload, child: const Text('Retry'))]))
        : shown.isEmpty ? Center(child: Text(tab == 0 ? 'No funds available.' : 'Your basket is empty.'))
        : RefreshIndicator(onRefresh: reload, child: ListView.builder(itemCount: shown.length, itemBuilder: (context, index) {
          final f = shown[index];
          final added = ids.contains(f.id);
          return FundCard(
            fund: f, inBasket: added, basketView: tab == 1,
            busy: workingId != null,
            onPressed: () => change(f, tab == 0),
          );
        })),
    );
  }
}
