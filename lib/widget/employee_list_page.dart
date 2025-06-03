// صفحة عرض قائمة الموظفين
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dtp_projet/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key, required List<Employee> employees}) : super(key: key);

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<Employee> employees = [];
  bool isLoading = true;
  String? errorMessage;

  // URL de votre API PHP (remplacez par votre URL)
  static const String apiUrl = 'http://localhost/dtp/get.php';

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> employeesData = jsonResponse['data'];
          
          setState(() {
            employees = employeesData.map((data) => Employee.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonResponse['error'] ?? 'خطأ في تحميل البيانات';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'خطأ في الاتصال بالخادم: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل البيانات: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الموظفين'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل قائمة الموظفين...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الموظفين'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadEmployees,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (employees.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الموظفين'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadEmployees,
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد بيانات موظفين',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // تجميع الموظفين حسب المنصب
    final employeesByPosition = groupEmployeesByPosition(employees);

    return DefaultTabController(
      length: employeesByPosition.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('قائمة الموظفين (${employees.length})'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadEmployees,
              tooltip: 'تحديث البيانات',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(),
              tooltip: 'البحث',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: employeesByPosition.keys.map((position) {
              final count = employeesByPosition[position]!.length;
              return Tab(text: '$position ($count)');
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: employeesByPosition.entries.map((entry) {
            return RefreshIndicator(
              onRefresh: loadEmployees,
              child: _buildEmployeeList(entry.value),
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: loadEmployees,
          tooltip: 'تحديث البيانات',
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(List<Employee> employees) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    // ترتيب الموظفين حسب النقاط (الأعلى أولاً)
    employees.sort((a, b) => b.calculateTotalPoints().compareTo(a.calculateTotalPoints()));
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: employee.isEligibleForPromotion() 
                  ? Colors.green.shade100 
                  : Colors.grey.shade100,
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: employee.isEligibleForPromotion() 
                      ? Colors.green.shade700 
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              employee.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${employee.position} - الدرجة ${employee.degree}'),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('التعيين: ${dateFormatter.format(employee.currentAppointmentDate)}'),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.timeline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('الأقدمية: ${employee.calculateSeniorityInMonths()} شهر'),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.stars, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 4),
                    Text('النقاط: ${employee.calculateTotalPoints().toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  employee.isEligibleForPromotion() ? Icons.trending_up : Icons.trending_flat,
                  color: employee.isEligibleForPromotion() ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  employee.isEligibleForPromotion() ? 'مؤهل' : 'غير مؤهل',
                  style: TextStyle(
                    fontSize: 12,
                    color: employee.isEligibleForPromotion() ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
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
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: employee.isEligibleForPromotion() 
                    ? Colors.green.shade100 
                    : Colors.grey.shade100,
                child: Text(
                  employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: employee.isEligibleForPromotion() 
                        ? Colors.green.shade700 
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  employee.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailSection('المعلومات الأساسية', [
                  _buildDetailRow('رقم التعريف', employee.id),
                  _buildDetailRow('تاريخ الميلاد', dateFormatter.format(employee.birthDate)),
                  _buildDetailRow('العمر', '${employee.calculateAge()} سنة'),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('معلومات الوظيفة', [
                  _buildDetailRow('المنصب', employee.position),
                  _buildDetailRow('الدرجة', employee.degree.toString()),
                  _buildDetailRow('تاريخ أول تعيين', dateFormatter.format(employee.firstAppointmentDate)),
                  _buildDetailRow('تاريخ التعيين الحالي', dateFormatter.format(employee.currentAppointmentDate)),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('النقاط والتقييم', [
                  _buildDetailRow('نقاط الأقدمية في المنصب', employee.positionSeniorityPoints.toStringAsFixed(2)),
                  _buildDetailRow('نقطة المدير', employee.directorPoints.toStringAsFixed(2)),
                  _buildDetailRow('نقاط دورات التكوين', employee.trainingPoints.toStringAsFixed(2)),
                  _buildDetailRow('إجمالي النقاط', employee.calculateTotalPoints().toStringAsFixed(2), 
                    color: Colors.orange.shade700, isBold: true),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('الأقدمية والترقية', [
                  _buildDetailRow('إجمالي الأقدمية', '${employee.calculateSeniorityInMonths()} شهر'),
                  _buildDetailRow('الأقدمية في المنصب الحالي', '${employee.calculateCurrentPositionSeniorityInMonths()} شهر'),
                  _buildDetailRow(
                    'أهلية الترقية',
                    employee.isEligibleForPromotion() ? 'مؤهل للترقية' : 'غير مؤهل للترقية',
                    color: employee.isEligibleForPromotion() ? Colors.green : Colors.red,
                    isBold: true,
                  ),
                ]),
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
            if (employee.isEligibleForPromotion())
              ElevatedButton.icon(
                icon: const Icon(Icons.trending_up, size: 16),
                label: const Text('تفاصيل الترقية'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showPromotionDetails(context, employee);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPromotionDetails(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green),
              SizedBox(width: 8),
              Text('تفاصيل الترقية'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الموظف: ${employee.name}'),
              const SizedBox(height: 8),
              Text('الدرجة الحالية: ${employee.degree}'),
              Text('الدرجة المقترحة: ${employee.degree + 1}'),
              const SizedBox(height: 8),
              Text('إجمالي النقاط: ${employee.calculateTotalPoints().toStringAsFixed(2)}'),
              Text('الأقدمية في المنصب: ${employee.calculateCurrentPositionSeniorityInMonths()} شهر'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredEmployees = employees.where((employee) {
              return employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                     employee.position.toLowerCase().contains(searchQuery.toLowerCase()) ||
                     employee.id.contains(searchQuery);
            }).toList();

            return AlertDialog(
              title: const Text('البحث عن موظف'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'ادخل اسم الموظف أو المنصب أو رقم التعريف',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
                          return ListTile(
                            title: Text(employee.name),
                            subtitle: Text('${employee.position} - الدرجة ${employee.degree}'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showEmployeeDetails(context, employee);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
        );
      },
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