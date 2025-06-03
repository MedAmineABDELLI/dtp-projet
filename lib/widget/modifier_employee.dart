import 'package:dtp_projet/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditEmployeePage extends StatefulWidget {
  final Employee employee;

  const EditEmployeePage({Key? key, required this.employee, required Null Function(dynamic updatedEmployee) onEmployeeUpdated}) : super(key: key);

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _positionSeniorityPointsController = TextEditingController();
  final _directorPointsController = TextEditingController();
  final _trainingPointsController = TextEditingController();
  
  DateTime? _birthDate;
  DateTime? _firstAppointmentDate;
  DateTime? _currentAppointmentDate;
  
  bool _isLoading = false;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final employee = widget.employee;
    _nameController.text = employee.name;
    _positionController.text = employee.position;
    _degreeController.text = employee.degree.toString();
    _positionSeniorityPointsController.text = employee.positionSeniorityPoints.toString();
    _directorPointsController.text = employee.directorPoints.toString();
    _trainingPointsController.text = employee.trainingPoints.toString();
    
    _birthDate = employee.birthDate;
    _firstAppointmentDate = employee.firstAppointmentDate;
    _currentAppointmentDate = employee.currentAppointmentDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _degreeController.dispose();
    _positionSeniorityPointsController.dispose();
    _directorPointsController.dispose();
    _trainingPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات الموظف'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveEmployee,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ID (non modifiable)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'رقم التعريف',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.employee.id,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Informations personnelles
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المعلومات الشخصية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Nom
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم الكامل *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الاسم مطلوب';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Date de naissance
                            InkWell(
                              onTap: () => _selectDate(context, 'birth'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'تاريخ الميلاد *',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _birthDate != null
                                                ? _dateFormatter.format(_birthDate!)
                                                : 'اختر التاريخ',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Informations professionnelles
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المعلومات المهنية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Poste
                            TextFormField(
                              controller: _positionController,
                              decoration: const InputDecoration(
                                labelText: 'المنصب *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'المنصب مطلوب';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Degré
                            TextFormField(
                              controller: _degreeController,
                              decoration: const InputDecoration(
                                labelText: 'الدرجة *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.grade),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الدرجة مطلوبة';
                                }
                                final degree = int.tryParse(value);
                                if (degree == null || degree < 1) {
                                  return 'أدخل درجة صحيحة';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Dates de nomination
                            InkWell(
                              onTap: () => _selectDate(context, 'first'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'تاريخ أول تعيين *',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _firstAppointmentDate != null
                                                ? _dateFormatter.format(_firstAppointmentDate!)
                                                : 'اختر التاريخ',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            InkWell(
                              onTap: () => _selectDate(context, 'current'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'تاريخ التعيين الحالي *',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _currentAppointmentDate != null
                                                ? _dateFormatter.format(_currentAppointmentDate!)
                                                : 'اختر التاريخ',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Points
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'النقاط',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _positionSeniorityPointsController,
                              decoration: const InputDecoration(
                                labelText: 'نقاط الأقدمية في المنصب',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.star),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _directorPointsController,
                              decoration: const InputDecoration(
                                labelText: 'نقطة المدير',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.supervisor_account),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _trainingPointsController,
                              decoration: const InputDecoration(
                                labelText: 'نقاط دورات التكوين',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.school),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEmployee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('حفظ التعديلات'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    DateTime? initialDate;
    DateTime firstDate = DateTime(1950);
    DateTime lastDate = DateTime.now();
    
    switch (type) {
      case 'birth':
        initialDate = _birthDate ?? DateTime(1980);
        lastDate = DateTime.now().subtract(const Duration(days: 365 * 18)); // 18 ans minimum
        break;
      case 'first':
        initialDate = _firstAppointmentDate ?? DateTime(2000);
        break;
      case 'current':
        initialDate = _currentAppointmentDate ?? DateTime.now();
        firstDate = _firstAppointmentDate ?? DateTime(2000);
        break;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ar'),
    );
    
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'birth':
            _birthDate = picked;
            break;
          case 'first':
            _firstAppointmentDate = picked;
            if (_currentAppointmentDate != null && _currentAppointmentDate!.isBefore(picked)) {
              _currentAppointmentDate = picked;
            }
            break;
          case 'current':
            _currentAppointmentDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_birthDate == null || _firstAppointmentDate == null || _currentAppointmentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد جميع التواريخ المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employeeData = {
        'id': widget.employee.id,
        'name': _nameController.text.trim(),
        'birth_date': _dateFormatter.format(_birthDate!),
        'first_appointment_date': _dateFormatter.format(_firstAppointmentDate!),
        'current_appointment_date': _dateFormatter.format(_currentAppointmentDate!),
        'position': _positionController.text.trim(),
        'degree': int.parse(_degreeController.text),
        'position_seniority_points': double.tryParse(_positionSeniorityPointsController.text) ?? 0.0,
        'director_points': double.tryParse(_directorPointsController.text) ?? 0.0,
        'training_points': double.tryParse(_trainingPointsController.text) ?? 0.0,
      };

      final response = await http.post(
        Uri.parse('http://localhost/dtp/modifier.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(employeeData),
      ).timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث بيانات الموظف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retourner true pour indiquer la modification
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error'] ?? 'خطأ في تحديث البيانات'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاتصال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}