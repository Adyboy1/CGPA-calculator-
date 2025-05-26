import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CgpaCalculatorApp());
}

class CgpaCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CGPA Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CgpaCalculatorHome(),
    );
  }
}

class CgpaCalculatorHome extends StatefulWidget {
  @override
  _CgpaCalculatorHomeState createState() => _CgpaCalculatorHomeState();
}

class _CgpaCalculatorHomeState extends State<CgpaCalculatorHome> {
  final List<String> _selectedGrades = ['A', 'A', 'A', 'A', 'A', 'A'];

  final TextEditingController _previousCgpaController = TextEditingController();
  final TextEditingController _previousCreditHoursController = TextEditingController();
  final TextEditingController _newSubjectController = TextEditingController();
  final TextEditingController _newCreditController = TextEditingController();

  final Map<String, double> _gradePointMap = {
    'A': 10.0,
    'A-': 9.0,
    'B': 8.0,
    'B-': 7.0,
    'C': 6.0,
    'C-': 5.0,
    'D': 4.0,
  };

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'DSA', 'credits': 4},
    {'name': 'DBS', 'credits': 4},
    {'name': 'MUP', 'credits': 4},
    {'name': 'POM', 'credits': 3},
    {'name': 'CW', 'credits': 3},
    {'name': 'SOP', 'credits': 3},
  ];

  double totalGradePoints = 0.0;
  double totalCreditHours = 0.0;
  double cgpa = 0.0;
  double sgpa = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPreviousData();
  }

  Future<void> _loadPreviousData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousCgpaController.text = prefs.getString('previousCgpa') ?? '';
      _previousCreditHoursController.text = prefs.getString('previousCreditHours') ?? '';
    });
  }

  Future<void> _savePreviousData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('previousCgpa', _previousCgpaController.text);
    await prefs.setString('previousCreditHours', _previousCreditHoursController.text);
  }

  void calculateCgpa() {
    totalGradePoints = 0.0;
    totalCreditHours = 0.0;
    double currentSemesterGradePoints = 0.0;
    double currentSemesterCreditHours = 0.0;

    for (int i = 0; i < _subjects.length; i++) {
      double gradePoint = _gradePointMap[_selectedGrades[i]] ?? 0.0;
      double creditHour = _subjects[i]['credits'];

      currentSemesterGradePoints += gradePoint * creditHour;
      currentSemesterCreditHours += creditHour;
    }

    setState(() {
      sgpa = (currentSemesterCreditHours > 0)
          ? currentSemesterGradePoints / currentSemesterCreditHours
          : 0.0;
    });

    double previousCgpa = double.tryParse(_previousCgpaController.text) ?? 0.0;
    double previousCreditHours = double.tryParse(_previousCreditHoursController.text) ?? 0.0;

    if (previousCreditHours > 0) {
      totalGradePoints += previousCgpa * previousCreditHours;
      totalCreditHours += previousCreditHours;
    }

    totalGradePoints += currentSemesterGradePoints;
    totalCreditHours += currentSemesterCreditHours;

    setState(() {
      cgpa = (totalCreditHours > 0) ? totalGradePoints / totalCreditHours : 0.0;
    });

    _savePreviousData();
  }

  void clearInputs() {
    setState(() {
      _selectedGrades.fillRange(0, _selectedGrades.length, 'A');
      _previousCgpaController.clear();
      _previousCreditHoursController.clear();
      totalGradePoints = 0.0;
      totalCreditHours = 0.0;
      cgpa = 0.0;
      sgpa = 0.0;
    });

    _clearSavedData();
  }

  Future<void> _clearSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('previousCgpa');
    await prefs.remove('previousCreditHours');
  }

  void addCourse() {
    String name = _newSubjectController.text.trim();
    int? credits = int.tryParse(_newCreditController.text);

    if (name.isNotEmpty && credits != null && credits > 0) {
      setState(() {
        _subjects.add({'name': name, 'credits': credits});
        _selectedGrades.add('A');
      });
      _newSubjectController.clear();
      _newCreditController.clear();
    }
  }

  void removeCourse(int index) {
    setState(() {
      _subjects.removeAt(index);
      _selectedGrades.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CGPA Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _previousCgpaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Previous CGPA',
              ),
            ),
            TextField(
              controller: _previousCreditHoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Previous Total Credit Hours',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSubjectController,
                    decoration: InputDecoration(labelText: 'New Course Name'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _newCreditController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Credit Units'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addCourse,
                  child: Text('Add Course'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _subjects[index]['name'],
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: DropdownButton<String>(
                              value: _selectedGrades[index],
                              items: _gradePointMap.keys.map((String grade) {
                                return DropdownMenuItem<String>(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (String? newGrade) {
                                setState(() {
                                  _selectedGrades[index] = newGrade!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${_subjects[index]['credits']} Units'),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeCourse(index),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: calculateCgpa,
              child: Text('Calculate CGPA & SGPA'),
            ),
            SizedBox(height: 20),
            Text(
              'Your SGPA is: ${sgpa.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your CGPA is: ${cgpa.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: clearInputs,
              child: Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }
}
