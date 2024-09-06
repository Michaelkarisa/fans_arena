import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatelessWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Line Chart Example',style: TextStyle(color: Colors.black),),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(1, 100),
                        const FlSpot(2, 400),
                        const FlSpot(3, 500),
                        const FlSpot(4, 650),
                        const FlSpot(5, 780),
                        const FlSpot(6, 860),
                        const FlSpot(7, 920),
                        const FlSpot(8, 1050),
                        const FlSpot(9, 1090),
                        const FlSpot(10, 1175),
                        const FlSpot(11, 1199),
                        const FlSpot(12, 1350),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(axisNameSize: 16,axisNameWidget: Text('views'),),
                    bottomTitles: AxisTitles(
                      axisNameSize: 16,axisNameWidget: Text('months'),
                    ),
                  ),
                ),
              ),
            ),
SizedBox(
  height: 300,
  child: BarChart(
  BarChartData(
    barGroups: [
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData( toY: 100)],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [BarChartRodData( toY: 250)],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [BarChartRodData( toY: 350)],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [BarChartRodData( toY: 400)],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [BarChartRodData( toY: 450)],
      ),
      BarChartGroupData(
        x: 6,
        barRods: [BarChartRodData( toY: 550)],
      ),
      BarChartGroupData(
        x: 7,
        barRods: [BarChartRodData( toY: 650)],
      ),
      BarChartGroupData(
        x: 8,
        barRods: [BarChartRodData( toY: 700)],
      ),
      BarChartGroupData(
        x: 9,
        barRods: [BarChartRodData( toY: 850)],
      ),
      BarChartGroupData(
        x: 10,
        barRods: [BarChartRodData( toY: 920)],
      ),
      BarChartGroupData(
        x: 11,
        barRods: [BarChartRodData( toY: 1020)],
      ),
      BarChartGroupData(
        x: 12,
        barRods: [BarChartRodData( toY: 1150)],
      ),
    ],
    titlesData: const FlTitlesData(
      leftTitles:  AxisTitles(axisNameSize: 16,axisNameWidget: Text('views'),),
      bottomTitles:  AxisTitles(axisNameSize: 16,axisNameWidget: Text('months'),),
    ),
  ),
),)
          ],
        ),
      ),
    );
  }
}


