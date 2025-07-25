import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Entry point of the app.
///
/// This widget initializes the [MaterialApp] and directs users to the [HomePage].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CigaretteTrackerApp());
}

/// Top‑level widget for the cigarette tracking application.
class CigaretteTrackerApp extends StatelessWidget {
  const CigaretteTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cigarette Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

/// The main page of the application.
///
/// Shows a floating action button to log a cigarette and tabs for daily,
/// weekly, monthly and yearly analytics.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DateTime> _events = [];
  final DateFormat _dayFormat = DateFormat('dd MMM');
  final DateFormat _monthFormat = DateFormat('MMM');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEvents();
  }

  /// Loads the stored events from [SharedPreferences].
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('events') ?? [];
    setState(() {
      _events = stored.map((e) => DateTime.parse(e)).toList();
    });
  }

  /// Saves the events list to [SharedPreferences].
  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = _events.map((e) => e.toIso8601String()).toList();
    await prefs.setStringList('events', stringList);
  }

  /// Adds a new cigarette event with the current timestamp.
  Future<void> _logCigarette() async {
    setState(() {
      _events.add(DateTime.now());
    });
    await _saveEvents();
  }

  /// Returns the count of cigarettes smoked on a particular day.
  int _getDailyCount(DateTime day) {
    return _events.where((event) => event.year == day.year && event.month == day.month && event.day == day.day).length;
  }

  /// Builds a map for the last [days] days (including today) with counts.
  Map<DateTime, int> _aggregateByDay(int days) {
    final now = DateTime.now();
    final Map<DateTime, int> data = {};
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      data[date] = _getDailyCount(date);
    }
    return data;
  }

  /// Builds a map aggregated by month for the last [months] months (including the current month).
  Map<DateTime, int> _aggregateByMonth(int months) {
    final now = DateTime.now();
    final Map<DateTime, int> data = {};
    for (int i = 0; i < months; i++) {
      final DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final int count = _events.where((event) => event.year == monthDate.year && event.month == monthDate.month).length;
      data[monthDate] = count;
    }
    return data;
  }

  /// Creates bar chart data from daily counts.
  List<BarChartGroupData> _buildBarGroupsFromDaily(Map<DateTime, int> data) {
    final List<BarChartGroupData> groups = [];
    int index = 0;
    data.entries.toList().reversed.forEach((entry) {
      groups.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: entry.value.toDouble(),
            colors: [Colors.blue],
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
      index++;
    });
    return groups;
  }

  /// Creates bar chart data from monthly counts.
  List<BarChartGroupData> _buildBarGroupsFromMonthly(Map<DateTime, int> data) {
    final List<BarChartGroupData> groups = [];
    int index = 0;
    data.entries.toList().reversed.forEach((entry) {
      groups.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: entry.value.toDouble(),
            colors: [Colors.purple],
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
      index++;
    });
    return groups;
  }

  /// Builds the widget for a bar chart with titles derived from the provided key list.
  Widget _buildBarChart({required List<BarChartGroupData> groups, required List<String> bottomTitles}) {
    return BarChart(
      BarChartData(
        barGroups: groups,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(color: Colors.grey.shade600, fontSize: 10);
                final index = value.toInt();
                if (index < 0 || index >= bottomTitles.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(bottomTitles[index], style: style),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// Builds the daily analytics view.
  Widget _buildDailyTab() {
    final dailyData = _aggregateByDay(1);
    final count = dailyData.values.first;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s count: $count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _buildBarChart(
                groups: _buildBarGroupsFromDaily(dailyData),
                bottomTitles: ['Today'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the weekly analytics view.
  Widget _buildWeeklyTab() {
    final weeklyData = _aggregateByDay(7);
    final List<String> titles = weeklyData.keys.toList().reversed.map((d) => _dayFormat.format(d)).toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total this week: ${weeklyData.values.reduce((a, b) => a + b)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBarChart(
              groups: _buildBarGroupsFromDaily(weeklyData),
              bottomTitles: titles,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the monthly analytics view.
  Widget _buildMonthlyTab() {
    final monthlyData = _aggregateByDay(30);
    final List<String> titles = monthlyData.keys.toList().reversed.map((d) => _dayFormat.format(d)).toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total last 30 days: ${monthlyData.values.reduce((a, b) => a + b)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBarChart(
              groups: _buildBarGroupsFromDaily(monthlyData),
              bottomTitles: titles,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the yearly analytics view.
  Widget _buildYearlyTab() {
    final yearlyData = _aggregateByMonth(12);
    final List<String> titles = yearlyData.keys.toList().reversed.map((d) => _monthFormat.format(d)).toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total last 12 months: ${yearlyData.values.reduce((a, b) => a + b)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBarChart(
              groups: _buildBarGroupsFromMonthly(yearlyData),
              bottomTitles: titles,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cigarette Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildWeeklyTab(),
          _buildMonthlyTab(),
          _buildYearlyTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logCigarette,
        tooltip: 'Log Cigarette',
        child: const Icon(Icons.add),
      ),
    );
  }
}
