import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:collection';

void main() {
  runApp(const PromotionManagementApp());
}

class PromotionManagementApp extends StatelessWidget {
  const PromotionManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة الترقيات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Cairo',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      locale: const Locale('ar', ''),
      home: const HomePage(),
    );
  }
}

// نموذج البيانات للموظف
class Employee {
  String id;
  String name;
  DateTime birthDate;
  DateTime firstAppointmentDate;
  DateTime currentAppointmentDate;
  String position;
  int degree;
  double positionSeniorityPoints;
  double directorPoints;
  double trainingPoints;

  Employee({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.firstAppointmentDate,
    required this.currentAppointmentDate,
    required this.position,
    required this.degree,
    this.positionSeniorityPoints = 0.0,
    this.directorPoints = 0.0,
    this.trainingPoints = 0.0,
  });

  // حساب إجمالي النقاط
  double calculateTotalPoints() {
    return positionSeniorityPoints + directorPoints + trainingPoints;
  }

  // حساب الأقدمية بالأشهر
  int calculateSeniorityInMonths() {
    final DateTime now = DateTime.now();
    int months = (now.year - currentAppointmentDate.year) * 12;
    months += now.month - currentAppointmentDate.month;
    return months;
  }

  // التحقق من أهلية الترقية (30 شهر أو أكثر)
  bool isEligibleForPromotion() {
    return calculateSeniorityInMonths() >= 30;
  }

  // نسخة من الموظف مع درجة جديدة
  Employee copyWithNewDegree(int newDegree) {
    return Employee(
      id: id,
      name: name,
      birthDate: birthDate,
      firstAppointmentDate: firstAppointmentDate,
      currentAppointmentDate: DateTime.now(),
      position: position,
      degree: newDegree,
      positionSeniorityPoints: positionSeniorityPoints,
      directorPoints: directorPoints,
      trainingPoints: trainingPoints,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Employee> _employees = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام إدارة الترقيات'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'نظام إدارة الترقيات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'مديرية الأشغال العمومية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('إضافة موظف جديد'),
              onTap: () {
                Navigator.pop(context);
                _showAddEmployeeDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('عرض الموظفين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeListPage(employees: _employees),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('حساب الترقيات'),
              onTap: () {
                Navigator.pop(context);
                if (_employees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إضافة موظفين أولاً'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PromotionCalculationPage(employees: _employees),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/dtp_logo.png', height: 150, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 100)),
            const SizedBox(height: 30),
            const Text(
              'نظام إدارة الترقيات',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'مديرية الأشغال العمومية',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة موظف جديد'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                _showAddEmployeeDialog();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calculate),
              label: const Text('حساب الترقيات'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _employees.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PromotionCalculationPage(employees: _employees),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  // عرض مربع حوار إضافة موظف جديد
  void _showAddEmployeeDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEmployeePage(
          onEmployeeAdded: (employee) {
            setState(() {
              _employees.add(employee);
            });
          },
        ),
      ),
    );
  }
}

// صفحة إضافة موظف جديد
class AddEmployeePage extends StatefulWidget {
  final Function(Employee) onEmployeeAdded;

  const AddEmployeePage({Key? key, required this.onEmployeeAdded}) : super(key: key);

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _birthDate = DateTime(1980);
  DateTime _firstAppointmentDate = DateTime.now();
  DateTime _currentAppointmentDate = DateTime.now();
  String _position = 'مهندس';
  int _degree = 1;
  final _positionSeniorityController = TextEditingController(text: '0.0');
  final _directorPointsController = TextEditingController(text: '0.0');
  final _trainingPointsController = TextEditingController(text: '0.0');

  final List<String> _positions = [
    'مهندس',
    'متصرف',
    'تقني',
    'عون أمن',
    'عون إداري',
    'مدير',
    'أخرى'
  ];

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _positionSeniorityController.dispose();
    _directorPointsController.dispose();
    _trainingPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موظف جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'رقم التعريف',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم التعريف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم واللقب',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم واللقب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تاريخ الميلاد',
                value: _birthDate,
                onChanged: (date) {
                  setState(() {
                    _birthDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تاريخ أول تعيين في الرتبة',
                value: _firstAppointmentDate,
                onChanged: (date) {
                  setState(() {
                    _firstAppointmentDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تاريخ التعيين الحالي',
                value: _currentAppointmentDate,
                onChanged: (date) {
                  setState(() {
                    _currentAppointmentDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'المنصب',
                  border: OutlineInputBorder(),
                ),
                value: _position,
                items: _positions.map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _position = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'الدرجة',
                  border: OutlineInputBorder(),
                ),
                value: _degree,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('الدرجة ${index + 1}'),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _degree = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionSeniorityController,
                decoration: const InputDecoration(
                  labelText: 'نقاط الأقدمية في المنصب',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقاط الأقدمية';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _directorPointsController,
                decoration: const InputDecoration(
                  labelText: 'نقطة المدير',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقطة المدير';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trainingPointsController,
                decoration: const InputDecoration(
                  labelText: 'نقاط دورات التكوين',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقاط دورات التكوين';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('إضافة الموظف'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    final formatter = DateFormat('yyyy-MM-dd');
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          locale: const Locale('ar', ''),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatter.format(value)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        id: _idController.text,
        name: _nameController.text,
        birthDate: _birthDate,
        firstAppointmentDate: _firstAppointmentDate,
        currentAppointmentDate: _currentAppointmentDate,
        position: _position,
        degree: _degree,
        positionSeniorityPoints: double.parse(_positionSeniorityController.text),
        directorPoints: double.parse(_directorPointsController.text),
        trainingPoints: double.parse(_trainingPointsController.text),
      );

      widget.onEmployeeAdded(employee);
      Navigator.pop(context);
    }
  }
}

// صفحة عرض قائمة الموظفين
class EmployeeListPage extends StatelessWidget {
  final List<Employee> employees;

  const EmployeeListPage({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تجميع الموظفين حسب المنصب
    final employeesByPosition = groupEmployeesByPosition(employees);

    return DefaultTabController(
      length: employeesByPosition.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الموظفين'),
          bottom: TabBar(
            isScrollable: true,
            tabs: employeesByPosition.keys.map((position) {
              return Tab(text: position);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: employeesByPosition.entries.map((entry) {
            return _buildEmployeeList(entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(List<Employee> employees) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              employee.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المنصب: ${employee.position}'),
                Text('الدرجة: ${employee.degree}'),
                Text('تاريخ التعيين الحالي: ${dateFormatter.format(employee.currentAppointmentDate)}'),
                Text('الأقدمية: ${employee.calculateSeniorityInMonths()} شهر'),
              ],
            ),
            trailing: Icon(
              employee.isEligibleForPromotion() ? Icons.check_circle : Icons.cancel,
              color: employee.isEligibleForPromotion() ? Colors.green : Colors.red,
            ),
            onTap: () {
              // عرض تفاصيل أكثر عن الموظف
              _showEmployeeDetails(context, employee);
            },
          ),
        );
      },
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(employee.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('رقم التعريف', employee.id),
                _buildDetailRow('تاريخ الميلاد', dateFormatter.format(employee.birthDate)),
                _buildDetailRow('تاريخ أول تعيين', dateFormatter.format(employee.firstAppointmentDate)),
                _buildDetailRow('تاريخ التعيين الحالي', dateFormatter.format(employee.currentAppointmentDate)),
                _buildDetailRow('المنصب', employee.position),
                _buildDetailRow('الدرجة', employee.degree.toString()),
                _buildDetailRow('نقاط الأقدمية في المنصب', employee.positionSeniorityPoints.toString()),
                _buildDetailRow('نقطة المدير', employee.directorPoints.toString()),
                _buildDetailRow('نقاط دورات التكوين', employee.trainingPoints.toString()),
                _buildDetailRow('إجمالي النقاط', employee.calculateTotalPoints().toString()),
                _buildDetailRow('الأقدمية', '${employee.calculateSeniorityInMonths()} شهر'),
                _buildDetailRow(
                  'أهلية الترقية',
                  employee.isEligibleForPromotion() ? 'مؤهل للترقية' : 'غير مؤهل للترقية',
                  color: employee.isEligibleForPromotion() ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  // تجميع الموظفين حسب المنصب
  Map<String, List<Employee>> groupEmployeesByPosition(List<Employee> employees) {
    final result = SplayTreeMap<String, List<Employee>>();
    
    for (final employee in employees) {
      if (!result.containsKey(employee.position)) {
        result[employee.position] = [];
      }
      result[employee.position]!.add(employee);
    }
    
    return result;
  }
}

// صفحة حساب الترقيات
class PromotionCalculationPage extends StatelessWidget {
  final List<Employee> employees;

  const PromotionCalculationPage({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تجميع الموظفين حسب المنصب والدرجة
    final employeesByPosition = groupEmployeesByPosition(employees);

    return DefaultTabController(
      length: employeesByPosition.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حساب الترقيات'),
          bottom: TabBar(
            isScrollable: true,
            tabs: employeesByPosition.keys.map((position) {
              return Tab(text: position);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: employeesByPosition.entries.map((entry) {
            return _buildPromotionResults(entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPromotionResults(String position, Map<int, List<Employee>> employeesByDegree) {
    return ListView.builder(
      itemCount: employeesByDegree.keys.length,
      itemBuilder: (context, index) {
        final degree = employeesByDegree.keys.elementAt(index);
        final employeesInDegree = employeesByDegree[degree]!;
        
        // ترتيب الموظفين حسب النقاط
        employeesInDegree.sort((a, b) => b.calculateTotalPoints().compareTo(a.calculateTotalPoints()));
        
        // تطبيق قاعدة 4-4-2 للترقية
        final promotedEmployees = applyPromotionRule(employeesInDegree);
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'الدرجة $degree (${employeesInDegree.length} موظف)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.all(16),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'الاسم واللقب',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'النقاط',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'الأقدمية',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'الترقية',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...employeesInDegree.map((employee) {
                      final isPromoted = promotedEmployees.contains(employee);
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isPromoted ? Colors.green[50] : null,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(employee.name),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              employee.calculateTotalPoints().toStringAsFixed(2),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${employee.calculateSeniorityInMonths()} شهر',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isPromoted ? Icons.check_circle : Icons.cancel,
                              color: isPromoted ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              if (promotedEmployees.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'الموظفين المترقين إلى الدرجة ${degree + 1}:',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'الاسم واللقب',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'النقاط',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'الدرجة الجديدة',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ...promotedEmployees.map((employee) {
                        return TableRow(
                          decoration: BoxDecoration(color: Colors.green[50]),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(employee.name),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                employee.calculateTotalPoints().toStringAsFixed(2),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${degree + 1}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('طباعة التقرير'),
                  onPressed: () {
                    // يمكن إضافة وظيفة طباعة هنا
                    _showPrintDialog(context, position, degree, employeesInDegree, promotedEmployees);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPrintDialog(
    BuildContext context, 
    String position, 
    int degree, 
    List<Employee> employees, 
    List<Employee> promotedEmployees
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('طباعة التقرير'),
          content: const Text('سيتم تصدير تقرير الترقيات إلى PDF. هل تريد المتابعة؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // تنفيذ طباعة التقرير (يمكن إضافة المزيد من الوظائف هنا)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري تصدير التقرير...'),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('طباعة'),
            ),
          ],
        );
      },
    );
  }

  // تجميع الموظفين حسب المنصب والدرجة
  Map<String, Map<int, List<Employee>>> groupEmployeesByPosition(List<Employee> employees) {
    final result = SplayTreeMap<String, Map<int, List<Employee>>>();
    
    for (final employee in employees) {
      if (!result.containsKey(employee.position)) {
        result[employee.position] = SplayTreeMap<int, List<Employee>>();
      }
      
      final degreesMap = result[employee.position]!;
      if (!degreesMap.containsKey(employee.degree)) {
        degreesMap[employee.degree] = [];
      }
      
      degreesMap[employee.degree]!.add(employee);
    }
    
    return result;
  }

  // تطبيق قاعدة الترقية (4-4-2)
  List<Employee> applyPromotionRule(List<Employee> employees) {
    final eligibleEmployees = employees.where((e) => e.isEligibleForPromotion()).toList();
    if (eligibleEmployees.isEmpty) return [];
    
    // ترتيب الموظفين المؤهلين حسب النقاط
    eligibleEmployees.sort((a, b) => b.calculateTotalPoints().compareTo(a.calculateTotalPoints()));
    
    // تطبيق نسبة الترقية 40%
    final promotionCount = (eligibleEmployees.length * 0.4).ceil();
    return eligibleEmployees.take(promotionCount).toList();
  }
}

// صفحة إحصائيات الترقيات
class PromotionStatisticsPage extends StatelessWidget {
  final List<Employee> employees;

  const PromotionStatisticsPage({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحليل البيانات
    final totalEmployees = employees.length;
    final eligibleCount = employees.where((e) => e.isEligibleForPromotion()).length;
    final promotedEmployees = calculatePromotedEmployees();
    
    // إحصائيات حسب المنصب
    final positionStats = calculatePositionStats();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات الترقيات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص الترقيات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('إجمالي الموظفين', totalEmployees.toString()),
                    _buildStatRow('المؤهلون للترقية', eligibleCount.toString()),
                    _buildStatRow('سيتم ترقيتهم', promotedEmployees.length.toString()),
                    _buildStatRow(
                      'نسبة الترقية',
                      '${((promotedEmployees.length / totalEmployees) * 100).toStringAsFixed(2)}%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'إحصائيات حسب المنصب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: positionStats.length,
              itemBuilder: (context, index) {
                final position = positionStats.keys.elementAt(index);
                final stats = positionStats[position]!;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow('العدد الإجمالي', stats['total'].toString()),
                        _buildStatRow('المؤهلون للترقية', stats['eligible'].toString()),
                        _buildStatRow('سيتم ترقيتهم', stats['promoted'].toString()),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('تصدير الإحصائيات'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري تصدير الإحصائيات...'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // حساب الموظفين الذين سيتم ترقيتهم
  List<Employee> calculatePromotedEmployees() {
    final result = <Employee>[];
    final employeesByPosition = _groupEmployeesByPosition();
    
    for (final position in employeesByPosition.keys) {
      final employeesByDegree = employeesByPosition[position]!;
      
      for (final degree in employeesByDegree.keys) {
        final employeesInDegree = employeesByDegree[degree]!;
        
        // تطبيق قاعدة الترقية
        final eligibleEmployees = employeesInDegree.where((e) => e.isEligibleForPromotion()).toList();
        eligibleEmployees.sort((a, b) => b.calculateTotalPoints().compareTo(a.calculateTotalPoints()));
        
        final promotionCount = (eligibleEmployees.length * 0.4).ceil();
        result.addAll(eligibleEmployees.take(promotionCount));
      }
    }
    
    return result;
  }

  // حساب إحصائيات حسب المنصب
  Map<String, Map<String, int>> calculatePositionStats() {
    final result = <String, Map<String, int>>{};
    final employeesByPosition = _groupEmployeesByPosition();
    final promotedEmployees = calculatePromotedEmployees();
    
    for (final position in employeesByPosition.keys) {
      int total = 0;
      int eligible = 0;
      
      final employeesByDegree = employeesByPosition[position]!;
      for (final employeeList in employeesByDegree.values) {
        total += employeeList.length;
        eligible += employeeList.where((e) => e.isEligibleForPromotion()).length;
      }
      
      final promoted = promotedEmployees.where((e) => e.position == position).length;
      
      result[position] = {
        'total': total,
        'eligible': eligible,
        'promoted': promoted,
      };
    }
    
    return result;
  }

  // تجميع الموظفين حسب المنصب والدرجة
  Map<String, Map<int, List<Employee>>> _groupEmployeesByPosition() {
    final result = <String, Map<int, List<Employee>>>{};
    
    for (final employee in employees) {
      if (!result.containsKey(employee.position)) {
        result[employee.position] = <int, List<Employee>>{};
      }
      
      final degreesMap = result[employee.position]!;
      if (!degreesMap.containsKey(employee.degree)) {
        degreesMap[employee.degree] = [];
      }
      
      degreesMap[employee.degree]!.add(employee);
    }
    
    return result;
  }
}

// صفحة البحث عن موظف
class SearchEmployeePage extends StatefulWidget {
  final List<Employee> employees;

  const SearchEmployeePage({Key? key, required this.employees}) : super(key: key);

  @override
  _SearchEmployeePageState createState() => _SearchEmployeePageState();
}

class _SearchEmployeePageState extends State<SearchEmployeePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> _filteredEmployees = [];
  
  @override
  void initState() {
    super.initState();
    _filteredEmployees = [];
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن موظف'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'بحث بالاسم أو رقم التعريف',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _filteredEmployees = [];
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _filteredEmployees.isEmpty && _searchController.text.isEmpty
                ? const Center(
                    child: Text(
                      'أدخل اسم أو رقم تعريف للبحث',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : _filteredEmployees.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد نتائج للبحث',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(employee.name),
                              subtitle: Text('${employee.position} - الدرجة ${employee.degree}'),
                              trailing: employee.isEligibleForPromotion()
                                  ? const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                    )
                                  : null,
                              onTap: () {
                                _showEmployeeDetails(context, employee);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = [];
      } else {
        _filteredEmployees = widget.employees
            .where((employee) =>
                employee.name.contains(query) || employee.id.contains(query))
            .toList();
      }
    });
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(employee.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('رقم التعريف', employee.id),
                _buildDetailRow('تاريخ الميلاد', dateFormatter.format(employee.birthDate)),
                _buildDetailRow('تاريخ أول تعيين', dateFormatter.format(employee.firstAppointmentDate)),
                _buildDetailRow('تاريخ التعيين الحالي', dateFormatter.format(employee.currentAppointmentDate)),
                _buildDetailRow('المنصب', employee.position),
                _buildDetailRow('الدرجة', employee.degree.toString()),
                _buildDetailRow('نقاط الأقدمية في المنصب', employee.positionSeniorityPoints.toString()),
                _buildDetailRow('نقطة المدير', employee.directorPoints.toString()),
                _buildDetailRow('نقاط دورات التكوين', employee.trainingPoints.toString()),
                _buildDetailRow('إجمالي النقاط', employee.calculateTotalPoints().toString()),
                _buildDetailRow('الأقدمية', '${employee.calculateSeniorityInMonths()} شهر'),
                _buildDetailRow(
                  'أهلية الترقية',
                  employee.isEligibleForPromotion() ? 'مؤهل للترقية' : 'غير مؤهل للترقية',
                  color: employee.isEligibleForPromotion() ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// صفحة تحرير بيانات الموظف
class EditEmployeePage extends StatefulWidget {
  final Employee employee;
  final Function(Employee) onEmployeeUpdated;

  const EditEmployeePage({
    Key? key,
    required this.employee,
    required this.onEmployeeUpdated,
  }) : super(key: key);

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late DateTime _birthDate;
  late DateTime _firstAppointmentDate;
  late DateTime _currentAppointmentDate;
  late String _position;
  late int _degree;
  late TextEditingController _positionSeniorityController;
  late TextEditingController _directorPointsController;
  late TextEditingController _trainingPointsController;

  final List<String> _positions = [
    'مهندس',
    'متصرف',
    'تقني',
    'عون أمن',
    'عون إداري',
    'مدير',
    'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة المحكمات بقيم الموظف الحالي
    _idController = TextEditingController(text: widget.employee.id);
    _nameController = TextEditingController(text: widget.employee.name);
    _birthDate = widget.employee.birthDate;
    _firstAppointmentDate = widget.employee.firstAppointmentDate;
    _currentAppointmentDate = widget.employee.currentAppointmentDate;
    _position = widget.employee.position;
    _degree = widget.employee.degree;
    _positionSeniorityController = TextEditingController(
      text: widget.employee.positionSeniorityPoints.toString(),
    );
    _directorPointsController = TextEditingController(
      text: widget.employee.directorPoints.toString(),
    );
    _trainingPointsController = TextEditingController(
      text: widget.employee.trainingPoints.toString(),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _positionSeniorityController.dispose();
    _directorPointsController.dispose();
    _trainingPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات الموظف'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'رقم التعريف',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم التعريف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم واللقب',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم واللقب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تاريخ الميلاد',
                value: _birthDate,
                onChanged: (date) {
                  setState(() {
                    _birthDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تاريخ أول تعيين في الرتبة',
                value: _firstAppointmentDate,
                onChanged: (date) {
                  setState(() {
                    _firstAppointmentDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'تاريخ التعيين الحالي',
                value: _currentAppointmentDate,
                onChanged: (date) {
                  setState(() {
                    _currentAppointmentDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'المنصب',
                  border: OutlineInputBorder(),
                ),
                value: _position,
                items: _positions.map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _position = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'الدرجة',
                  border: OutlineInputBorder(),
                ),
                value: _degree,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('الدرجة ${index + 1}'),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _degree = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionSeniorityController,
                decoration: const InputDecoration(
                  labelText: 'نقاط الأقدمية في المنصب',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقاط الأقدمية';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _directorPointsController,
                decoration: const InputDecoration(
                  labelText: 'نقطة المدير',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقطة المدير';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trainingPointsController,
                decoration: const InputDecoration(
                  labelText: 'نقاط دورات التكوين',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقاط دورات التكوين';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateEmployee,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('حفظ التغييرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    final formatter = DateFormat('yyyy-MM-dd');
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          locale: const Locale('ar', ''),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatter.format(value)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  void _updateEmployee() {
    if (_formKey.currentState!.validate()) {
      final updatedEmployee = Employee(
        id: _idController.text,
        name: _nameController.text,
        birthDate: _birthDate,
        firstAppointmentDate: _firstAppointmentDate,
        currentAppointmentDate: _currentAppointmentDate,
        position: _position,
        degree: _degree,
        positionSeniorityPoints: double.parse(_positionSeniorityController.text),
        directorPoints: double.parse(_directorPointsController.text),
        trainingPoints: double.parse(_trainingPointsController.text),
      );

      widget.onEmployeeUpdated(updatedEmployee);
      Navigator.pop(context);
    }
  }
}