import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Fitness Tracker',
  theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.grey[100]),
  home: InputScreen(),
));

class InputScreen extends StatefulWidget {
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _fKey = GlobalKey<FormState>();
  final _n = TextEditingController(), _s = TextEditingController(), _c = TextEditingController(), _m = TextEditingController();

  void _goNext() {
    if (_fKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen(
        name: _n.text.trim(),
        steps: int.parse(_s.text),
        cal: int.parse(_c.text),
        min: int.parse(_m.text),
      )));
    }
  }

  Widget _inputField(String label, IconData icon, TextEditingController c, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter $label" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text("Set Fitness Goals"),
      centerTitle: true,
      elevation: 0,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _fKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, color: Colors.blue, size: 70),
                  SizedBox(height: 8),
                  Text("Fitness Tracker", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  SizedBox(height: 20),
                  _inputField("Your Name", Icons.person, _n),
                  _inputField("Target Steps", Icons.directions_walk, _s, number: true),
                  _inputField("Target Calories (kcal)", Icons.local_fire_department, _c, number: true),
                  _inputField("Target Active Minutes", Icons.timer, _m, number: true),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.dashboard),
                    label: Text("Show Dashboard"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _goNext,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class DashboardScreen extends StatelessWidget {
  final String name;
  final int steps, cal, min;
  const DashboardScreen({required this.name, required this.steps, required this.cal, required this.min});

  @override
  Widget build(BuildContext context) {
    final s = (steps * 0.75).toInt(), c = (cal * 0.82).toInt(), m = (min * 0.65).toInt();
    return Scaffold(
      appBar: AppBar(title: Text("Your Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Hello, $name 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            StatCard("Steps", s, steps, Icons.directions_walk),
            StatCard("Calories", c, cal, Icons.local_fire_department),
            StatCard("Active Minutes", m, min, Icons.timer),
            SizedBox(height: 24),
            Text("Weekly Activity Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Padding(padding: EdgeInsets.all(12), child: ActivityChart()),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int cur, target;
  final IconData icon;
  const StatCard(this.title, this.cur, this.target, this.icon);

  @override
  Widget build(BuildContext context) {
    final p = (cur / target).clamp(0.0, 1.0);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text("$cur / $target", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: p,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 6),
            Text("${(p * 100).toStringAsFixed(0)}% completed", style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class ActivityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LineChart(LineChartData(
    gridData: FlGridData(show: false),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
      bottomTitles: AxisTitles(sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (v, _) {
          const d = ["M", "T", "W", "T", "F", "S", "S"];
          return Padding(padding: EdgeInsets.only(top: 4), child: Text(d[v.toInt() % 7], style: TextStyle(fontSize: 12)));
        },
      )),
    ),
    borderData: FlBorderData(show: false),
    minX: 0, maxX: 6, minY: 0, maxY: 10,
    lineBarsData: [
      LineChartBarData(
        spots: [for (var i = 0; i < 7; i++) FlSpot(i.toDouble(), (3 + i % 5).toDouble())],
        isCurved: true,
        color: Colors.blue,
        barWidth: 4,
        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
        dotData: FlDotData(show: true),
      )
    ],
  ));
}