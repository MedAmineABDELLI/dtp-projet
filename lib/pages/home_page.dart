import 'package:dtp_projet/models/employee.dart';
import 'package:dtp_projet/models/leave.dart';
import 'package:dtp_projet/widget/ajouter_employee.dart';
import 'package:dtp_projet/widget/chercher_employee.dart';
import 'package:dtp_projet/widget/employee_list_page.dart';
import 'package:dtp_projet/widget/gestion_conge.dart';
import 'package:dtp_projet/widget/modifier_employee.dart';
import 'package:dtp_projet/widget/promotion_page.dart';
import 'package:dtp_projet/widget/statestiques_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Employee> _employees = [];
  final List<Leave> _leaves = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام تسيير الموارد البشرية للمؤسسة الأشغال العمومية'),
        backgroundColor: Colors.blue,
        actions: [
          // إشعار للإجازات المعلقة
          if (_getPendingLeavesCount() > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showPendingLeavesDialog(),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${_getPendingLeavesCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
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
                    'نظام تسيير الموارد البشرية',
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
            
            // قسم الموظفين
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'إدارة الموظفين',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
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
                    builder: (context) => EmployeeListPage(
                      employees: _employees,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('البحث عن موظف'),
              onTap: () {
                Navigator.pop(context);
                if (_employees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يوجد موظفين للبحث فيهم'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchEmployeePage(employees: _employees),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل بيانات موظف'),
              onTap: () {
                Navigator.pop(context);
                if (_employees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يوجد موظفين للتعديل'),
                    ),
                  );
                } else {
                  _showEmployeeSelectionDialog();
                }
              },
            ),

            const Divider(),

            // قسم الترقيات
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'إدارة الترقيات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
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
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('إحصائيات الترقيات'),
              onTap: () {
                Navigator.pop(context);
                if (_employees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يوجد موظفين لعرض الإحصائيات'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnhancedPromotionStatisticsPage(employees: _employees),
                    ),
                  );
                }
              },
            ),

            const Divider(),

            // قسم الإجازات - الجديد
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'إدارة الإجازات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: Stack(
                children: [
                  const Icon(Icons.event_available, color: Colors.teal),
                  if (_getPendingLeavesCount() > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_getPendingLeavesCount()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              title: const Text('إدارة الإجازات والعطل'),
              subtitle: _getActiveLeaveCount() > 0 
                  ? Text('${_getActiveLeaveCount()} موظف في إجازة حالياً')
                  : null,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaveManagementPage(
                      employees: _employees,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار المؤسسة
              Image.asset(
                'assets/dtp_logo.png', 
                height: 150, 
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.business, size: 100, color: Colors.blue),
              ),
              const SizedBox(height: 30),
              
              // عنوان النظام
              const Text(
                'نظام تسسير الإدارة',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'مديرية الأشغال العمومية',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // إحصائيات سريعة
              _buildQuickStats(),
              const SizedBox(height: 40),

              // الأزرار الرئيسية
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  // إدارة الموظفين
                  _buildMainButton(
                    icon: Icons.person_add,
                    label: 'إضافة موظف جديد',
                    color: Colors.blue,
                    onPressed: _showAddEmployeeDialog,
                  ),
                  _buildMainButton(
                    icon: Icons.list,
                    label: 'عرض الموظفين',
                    color: Colors.green,
                    onPressed: _employees.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeListPage(employees: _employees),
                        ),
                      );
                    },
                  ),
                  _buildMainButton(
                    icon: Icons.search,
                    label: 'البحث عن موظف',
                    color: Colors.orange,
                    onPressed: _employees.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchEmployeePage(employees: _employees),
                        ),
                      );
                    },
                  ),
                  
                  // إدارة الترقيات
                  _buildMainButton(
                    icon: Icons.calculate,
                    label: 'حساب الترقيات',
                    color: Colors.purple,
                    onPressed: _employees.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PromotionCalculationPage(employees: _employees),
                        ),
                      );
                    },
                  ),
                  _buildMainButton(
                    icon: Icons.bar_chart,
                    label: 'إحصائيات الترقيات',
                    color: Colors.indigo,
                    onPressed: _employees.isEmpty ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnhancedPromotionStatisticsPage(employees: _employees),
                        ),
                      );
                    },
                  ),
                  
                  // إدارة الإجازات - الجديد
                  _buildMainButton(
                    icon: Icons.event_available,
                    label: 'إدارة الإجازات',
                    color: Colors.teal,
                    badge: _getPendingLeavesCount(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaveManagementPage(employees: _employees),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء الإحصائيات السريعة
  Widget _buildQuickStats() {
    final employeesOnLeave = _getActiveLeaveCount();
    final pendingPromotions = _employees.where((e) => e.isEligibleForPromotion()).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.teal.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'إحصائيات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.people,
                value: '${_employees.length}',
                label: 'إجمالي الموظفين',
                color: Colors.blue,
              ),
              _buildStatItem(
                icon: Icons.trending_up,
                value: '$pendingPromotions',
                label: 'مؤهل للترقية',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.event_busy,
                value: '$employeesOnLeave',
                label: 'في إجازة',
                color: Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.pending,
                value: '${_getPendingLeavesCount()}',
                label: 'طلبات معلقة',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // بناء الأزرار الرئيسية
  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
    int? badge,
  }) {
    return Container(
      width: 180,
      height: 120,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: onPressed != null
                      ? LinearGradient(
                          colors: [color.withOpacity(0.1), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: onPressed != null ? color : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onPressed != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // الحصول على عدد الطلبات المعلقة
  int _getPendingLeavesCount() {
    return _leaves.where((leave) => leave.status == "En attente").length;
  }

  // الحصول على عدد الموظفين في إجازة
  int _getActiveLeaveCount() {
    return _leaves.where((leave) => 
      leave.isActive && leave.status == "Approuvé"
    ).length;
  }

  // عرض حوار الطلبات المعلقة
  void _showPendingLeavesDialog() {
    final pendingLeaves = _leaves.where((leave) => leave.status == "En attente").toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طلبات الإجازة المعلقة'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: pendingLeaves.length,
            itemBuilder: (context, index) {
              final leave = pendingLeaves[index];
              return ListTile(
                leading: Icon(leave.typeIcon, color: Colors.orange),
                title: Text(leave.employeeName),
                subtitle: Text('${leave.type} - ${leave.duration} يوم'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveManagementPage(employees: _employees),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveManagementPage(employees: _employees),
                ),
              );
            },
            child: const Text('إدارة الطلبات'),
          ),
        ],
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

  // عرض قائمة الموظفين لاختيار موظف للتعديل
  void _showEmployeeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر موظف للتعديل'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final employee = _employees[index];
                return ListTile(
                  title: Text(employee.name),
                  subtitle: Text('${employee.position} - الدرجة ${employee.degree}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    _editEmployee(employee, index);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  // تعديل موظف
  void _editEmployee(Employee employee, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmployeePage(
          employee: employee,
          onEmployeeUpdated: (updatedEmployee) {
            setState(() {
              _employees[index] = updatedEmployee;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث بيانات الموظف بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }
}