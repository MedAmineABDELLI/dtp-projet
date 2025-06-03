import 'package:flutter/material.dart';
import 'package:dtp_projet/models/employee.dart';
import 'package:dtp_projet/models/leave.dart';
import 'package:file_selector/file_selector.dart';

class LeaveManagementPage extends StatefulWidget {
  final List<Employee> employees;
  
  const LeaveManagementPage({Key? key, required this.employees}) : super(key: key);

  @override
  _LeaveManagementPageState createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends State<LeaveManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Leave> _leaves = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإجازات والعطل'),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle), text: 'طلب إجازة'),
            Tab(icon: Icon(Icons.list), text: 'جميع الطلبات'),
            Tab(icon: Icon(Icons.people), text: 'الموظفون في إجازة'),
            Tab(icon: Icon(Icons.analytics), text: 'إحصائيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestLeaveTab(),
          _buildAllLeavesTab(),
          _buildActiveEmployeesTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  // تبويب طلب إجازة جديدة
  Widget _buildRequestLeaveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'طلب إجازة جديد',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _LeaveRequestForm(
                    employees: widget.employees,
                    onSubmit: _addLeaveRequest,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLeaveTypesInfo(),
        ],
      ),
    );
  }

  // تبويب جميع طلبات الإجازة
  Widget _buildAllLeavesTab() {
    if (_leaves.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد طلبات إجازة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaves.length,
      itemBuilder: (context, index) {
        final leave = _leaves[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: leave.statusColor,
              child: Icon(leave.typeIcon, color: Colors.white),
            ),
            title: Text(leave.employeeName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('النوع: ${leave.type}'),
                Text('من ${_formatDate(leave.startDate)} إلى ${_formatDate(leave.endDate)}'),
                Text('المدة: ${leave.duration} يوم'),
                Text('الحالة: ${leave.status}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('عرض التفاصيل'),
                  ),
                ),
                if (leave.status == "En attente") ...[
                  const PopupMenuItem(
                    value: 'approve',
                    child: ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text('موافقة'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: ListTile(
                      leading: Icon(Icons.close, color: Colors.red),
                      title: Text('رفض'),
                    ),
                  ),
                ],
              ],
              onSelected: (value) => _handleLeaveAction(value.toString(), leave, index),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // تبويب الموظفين في إجازة حالياً
  Widget _buildActiveEmployeesTab() {
    final activeLeaves = _leaves.where((leave) => 
      leave.isActive && leave.status == "Approuvé"
    ).toList();

    if (activeLeaves.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'جميع الموظفين في العمل',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeLeaves.length,
      itemBuilder: (context, index) {
        final leave = activeLeaves[index];
        final remainingDays = leave.endDate.difference(DateTime.now()).inDays;
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(leave.typeIcon, color: Colors.white),
            ),
            title: Text(leave.employeeName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('في إجازة ${leave.type}'),
                Text('العودة بعد: $remainingDays يوم'),
                LinearProgressIndicator(
                  value: 1 - (remainingDays / leave.duration),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(leave.statusColor),
                ),
              ],
            ),
            trailing: Text(
              '${leave.duration} يوم',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // تبويب الإحصائيات
  Widget _buildStatisticsTab() {
    final stats = _calculateStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('إجمالي الطلبات', stats['total'].toString(), Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('في الانتظار', stats['pending'].toString(), Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('موافق عليها', stats['approved'].toString(), Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('مرفوضة', stats['rejected'].toString(), Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات حسب النوع',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTypeStatistics(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStatistics() {
    final typeStats = <String, int>{};
    for (final leave in _leaves) {
      typeStats[leave.type] = (typeStats[leave.type] ?? 0) + 1;
    }

    return Column(
      children: typeStats.entries.map((entry) {
        final percentage = (_leaves.isEmpty ? 0.0 : entry.value / _leaves.length);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(entry.key),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.value}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  // معلومات أنواع الإجازات
  Widget _buildLeaveTypesInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'قوانين الإجازات في الجزائر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLeaveTypeInfo(
              'إجازة مرضية',
              '6 أشهر كحد أقصى (3 أشهر بـ100% + 3 أشهر بـ50%)',
              Icons.local_hospital,
              Colors.red,
            ),
            _buildLeaveTypeInfo(
              'إجازة أمومة',
              '14 أسبوع (6 قبل الولادة + 8 بعد الولادة) بـ100%',
              Icons.child_care,
              Colors.pink,
            ),
            _buildLeaveTypeInfo(
              'إجازة سنوية',
              '30 يوم عمل سنوياً بـ100%',
              Icons.beach_access,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeInfo(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // إضافة طلب إجازة جديد
  void _addLeaveRequest(Leave leave) {
    setState(() {
      _leaves.add(leave);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلب الإجازة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    
    _tabController.animateTo(1); // الانتقال لتبويب جميع الطلبات
  }

  // التعامل مع إجراءات الإجازة
  void _handleLeaveAction(String action, Leave leave, int index) {
    switch (action) {
      case 'view':
        _showLeaveDetails(leave);
        break;
      case 'approve':
        _updateLeaveStatus(index, 'Approuvé');
        break;
      case 'reject':
        _updateLeaveStatus(index, 'Rejeté');
        break;
    }
  }

  // تحديث حالة الإجازة
  void _updateLeaveStatus(int index, String status) {
    setState(() {
      _leaves[index] = _leaves[index].copyWith(status: status);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم $status الطلب'),
        backgroundColor: status == 'Approuvé' ? Colors.green : Colors.red,
      ),
    );
  }

  // عرض تفاصيل الإجازة
  void _showLeaveDetails(Leave leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل إجازة ${leave.employeeName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('النوع:', leave.type),
              _buildDetailRow('من:', _formatDate(leave.startDate)),
              _buildDetailRow('إلى:', _formatDate(leave.endDate)),
              _buildDetailRow('المدة:', '${leave.duration} يوم'),
              _buildDetailRow('الحالة:', leave.status),
              _buildDetailRow('نسبة الراتب:', '${leave.salaryPercentage}%'),
              if (leave.reason != null) _buildDetailRow('السبب:', leave.reason!),
              if (leave.medicalCertificatePath != null) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.attachment),
                  label: const Text('عرض الشهادة الطبية'),
                  onPressed: () => _viewMedicalCertificate(leave.medicalCertificatePath!),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // عرض الشهادة الطبية
  void _viewMedicalCertificate(String path) {
    // هنا يمكن إضافة منطق عرض الملف
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض الشهادة: $path')),
    );
  }

  // حساب الإحصائيات
  Map<String, int> _calculateStatistics() {
    return {
      'total': _leaves.length,
      'pending': _leaves.where((l) => l.status == "En attente").length,
      'approved': _leaves.where((l) => l.status == "Approuvé").length,
      'rejected': _leaves.where((l) => l.status == "Rejeté").length,
    };
  }

  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// فورم طلب الإجازة
class _LeaveRequestForm extends StatefulWidget {
  final List<Employee> employees;
  final Function(Leave) onSubmit;

  const _LeaveRequestForm({
    required this.employees,
    required this.onSubmit,
  });

  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<_LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  Employee? _selectedEmployee;
  String _selectedType = 'Annuel';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _reason;
  String? _medicalCertificatePath;
  
  final List<String> _leaveTypes = ['Annuel', 'Maladie', 'Maternité'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // اختيار الموظف
          DropdownButtonFormField<Employee>(
            value: _selectedEmployee,
            decoration: const InputDecoration(
              labelText: 'اختر الموظف',
              border: OutlineInputBorder(),
            ),
            items: widget.employees.map((employee) {
              return DropdownMenuItem(
                value: employee,
                child: Text('${employee.name} - ${employee.position}'),
              );
            }).toList(),
            onChanged: (employee) {
              setState(() {
                _selectedEmployee = employee;
              });
            },
            validator: (value) => value == null ? 'يرجى اختيار موظف' : null,
          ),
          const SizedBox(height: 16),
          
          // نوع الإجازة
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'نوع الإجازة',
              border: OutlineInputBorder(),
            ),
            items: _leaveTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (type) {
              setState(() {
                _selectedType = type!;
                _medicalCertificatePath = null; // إعادة تعيين الشهادة
              });
            },
          ),
          const SizedBox(height: 16),
          
          // التواريخ
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ البداية',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _startDate != null 
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'اختر التاريخ',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ النهاية',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _endDate != null 
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'اختر التاريخ',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // السبب
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'السبب (اختياري)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => _reason = value,
          ),
          const SizedBox(height: 16),
          
          // رفع الشهادة الطبية
          if (_selectedType == 'Maladie' || _selectedType == 'Maternité') ...[
            Card(
              color: Colors.amber.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'الشهادة الطبية مطلوبة لهذا النوع من الإجازة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(_medicalCertificatePath != null 
                          ? 'تم رفع الشهادة' 
                          : 'رفع الشهادة الطبية'),
                      onPressed: _uploadMedicalCertificate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _medicalCertificatePath != null 
                            ? Colors.green 
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // زر الإرسال
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              child: const Text(
                'إرسال طلب الإجازة',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          _endDate = null; // إعادة تعيين تاريخ النهاية
        } else {
          _endDate = date;
        }
      });
    }
  }

Future<void> _uploadMedicalCertificate() async {
  try {
    // Définir les extensions autorisées
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Fichiers justificatifs',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    // Ouvrir le sélecteur de fichiers
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        _medicalCertificatePath = file.name; // ou file.path si supporté
        // Pour lire les données du fichier :
        // _medicalCertificateBytes = await file.readAsBytes();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الشهادة الطبية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    debugPrint('Erreur de téléchargement: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ في رفع الملف: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد تواريخ الإجازة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تاريخ النهاية يجب أن يكون بعد تاريخ البداية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // التحقق من الشهادة الطبية للإجازات المرضية وإجازة الأمومة
    if ((_selectedType == 'Maladie' || _selectedType == 'Maternité') && 
        _medicalCertificatePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الشهادة الطبية مطلوبة لهذا النوع من الإجازة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final duration = _endDate!.difference(_startDate!).inDays + 1;
    final durationInMonths = (duration / 30).ceil();
    final salaryPercentage = Leave.calculateSalaryPercentage(_selectedType, durationInMonths);

    // التحقق من حدود الإجازة
    if (!_validateLeaveDuration(duration)) return;

    final leave = Leave(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: _selectedEmployee!.id ,
      employeeName: _selectedEmployee!.name,
      type: _selectedType,
      startDate: _startDate!,
      endDate: _endDate!,
      medicalCertificatePath: _medicalCertificatePath,
      reason: _reason,
      requestDate: DateTime.now(),
      duration: duration,
      salaryPercentage: salaryPercentage,
    );

    widget.onSubmit(leave);
    _resetForm();
  }

  bool _validateLeaveDuration(int duration) {
    switch (_selectedType) {
      case 'Maladie':
        if (duration > 180) { // 6 أشهر
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الإجازة المرضية لا يمكن أن تتجاوز 6 أشهر'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case 'Maternité':
        if (duration > 98) { // 14 أسبوع
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('إجازة الأمومة لا يمكن أن تتجاوز 14 أسبوع'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case 'Annuel':
        if (duration > 30) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الإجازة السنوية لا يمكن أن تتجاوز 30 يوم'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
    }
    return true;
  }

  void _resetForm() {
    setState(() {
      _selectedEmployee = null;
      _selectedType = 'Annuel';
      _startDate = null;
      _endDate = null;
      _reason = null;
      _medicalCertificatePath = null;
    });
    _formKey.currentState!.reset();
  }
}