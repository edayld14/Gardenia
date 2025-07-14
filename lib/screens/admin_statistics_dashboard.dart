import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminStatisticsDashboard extends StatefulWidget {
  const AdminStatisticsDashboard({Key? key}) : super(key: key);

  @override
  State<AdminStatisticsDashboard> createState() =>
      _AdminStatisticsDashboardState();
}

class _AdminStatisticsDashboardState extends State<AdminStatisticsDashboard> {
  int totalOrders = 0;
  bool isLoading = true;
  Map<String, int> dailyOrders = {};

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      int orderCount = snapshot.docs.length;
      Map<String, int> tempDailyOrders = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['createdAt'];

        if (timestamp is Timestamp) {
          final date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());

          if (tempDailyOrders.containsKey(date)) {
            tempDailyOrders[date] = tempDailyOrders[date]! + 1;
          } else {
            tempDailyOrders[date] = 1;
          }
        }
      }

      final sortedDailyOrders = Map.fromEntries(
        tempDailyOrders.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );

      setState(() {
        totalOrders = orderCount;
        dailyOrders = sortedDailyOrders;
        isLoading = false;
      });
    } catch (e) {
      print("Hata oluştu: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Genel İstatistikler',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildInfoTile('Toplam Sipariş', totalOrders.toString()),
              const SizedBox(height: 16),
              Text(
                'Günlük Sipariş Sayısı',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildBarChart(),
            ],
          ),
        );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final barGroups = <BarChartGroupData>[];
    final labels = dailyOrders.keys.toList();
    final maxOrders =
        dailyOrders.values.isNotEmpty
            ? dailyOrders.values.reduce((a, b) => a > b ? a : b)
            : 1;

    for (int i = 0; i < labels.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyOrders[labels[i]]!.toDouble(),
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          maxY: (maxOrders + 2).toDouble(),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index < labels.length) {
                    final day = labels[index].substring(5); // 'MM-dd'
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(day, style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }
}
