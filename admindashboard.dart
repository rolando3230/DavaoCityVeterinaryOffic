import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartData {
  String meat;
  double kg;
  int headcount;
  DateTime date;

  ChartData({required this.meat, required this.kg, required this.headcount, required this.date});

  ChartData.fromMap(Map<String, dynamic>? map)
      : meat = map?['meat'] ?? '',
        kg = (map?['kg'] as num?)?.toDouble() ?? 0.0,
        headcount = map?['headcount'] ?? 0,
        date = (map?['date'] as Timestamp?)?.toDate() ?? DateTime.now();
}

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts from Firebase'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Report').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ChartData> dataList = [];
            snapshot.data!.docs.forEach((doc) {
              dataList.add(ChartData.fromMap(doc.data() as Map<String, dynamic>?));
            });
            return ListView(
              children: [
                const SizedBox(height: 10),
                buildKgLineChart(dataList),
                const SizedBox(height: 10),
                buildHeadcountBarChart(dataList),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildKgLineChart(List<ChartData> data) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: data.length.toDouble() - 1,
            minY: 0,
            maxY: getMaxKg(data),
            lineBarsData: [
              LineChartBarData(
                spots: buildKgSpots(data),
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> buildKgSpots(List<ChartData> data) {
    return data.map((chartData) => FlSpot(data.indexOf(chartData).toDouble(), chartData.kg)).toList();
  }

  double getMaxKg(List<ChartData> data) {
    return data.isNotEmpty ? data.map((chartData) => chartData.kg).reduce((max, current) => max > current ? max : current) : 1.0;
  }

  Widget buildHeadcountBarChart(List<ChartData> data) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: getMaxHeadcount(data),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: buildHeadcountBarGroups(data),
          ),
        ),
      ),
    );
  }

  double getMaxHeadcount(List<ChartData> data) {
    return data.isNotEmpty ? data.map((chartData) => chartData.headcount.toDouble()).reduce((max, current) => max > current ? max : current) : 1.0;
  }

  List<BarChartGroupData> buildHeadcountBarGroups(List<ChartData> data) {
    return List.generate(
      data.length,
      (index) => BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            fromY: data[index].headcount.toDouble(),
            color: Colors.blue,
            width: 16, toY: 10,
          ),
        ],
      ),
    );
  }
}

