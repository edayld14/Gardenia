import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({Key? key}) : super(key: key);

  Future<int> _getProductCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.length;
  }

  Future<int> _getOrderCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    return snapshot.docs.length;
  }

  Future<int> _getUserCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: FutureBuilder<List<int>>(
        future: Future.wait([
          _getProductCount(),
          _getOrderCount(),
          _getUserCount(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Ürünler', data[0], Icons.shopping_bag),
                    _buildStatCard('Siparişler', data[1], Icons.receipt),
                    _buildStatCard('Kullanıcılar', data[2], Icons.person),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sipariş Dağılımı (Dummy)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 40,
                          color: Colors.blue,
                          title: 'Mobilya',
                        ),
                        PieChartSectionData(
                          value: 30,
                          color: Colors.green,
                          title: 'Saksı',
                        ),
                        PieChartSectionData(
                          value: 20,
                          color: Colors.orange,
                          title: 'Toprak',
                        ),
                        PieChartSectionData(
                          value: 10,
                          color: Colors.red,
                          title: 'Diğer',
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}
