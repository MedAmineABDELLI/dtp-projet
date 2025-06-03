import 'package:dtp_projet/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // État pour gérer le chargement
  bool _isLoading = false;

  // URL de votre API (à modifier selon votre configuration)
  static const String API_BASE_URL = 'http://localhost/dtp';
  
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

  // Méthode pour envoyer les données à l'API
  Future<Map<String, dynamic>> _addEmployeeToDatabase(Employee employee) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/ajouter.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': employee.id,
          'name': employee.name,
          'birth_date': DateFormat('yyyy-MM-dd').format(employee.birthDate),
          'first_appointment_date': DateFormat('yyyy-MM-dd').format(employee.firstAppointmentDate),
          'current_appointment_date': DateFormat('yyyy-MM-dd').format(employee.currentAppointmentDate),
          'position': employee.position,
          'degree': employee.degree,
          'position_seniority_points': employee.positionSeniorityPoints,
          'director_points': employee.directorPoints,
          'training_points': employee.trainingPoints,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'خطأ في الخادم: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: ${e.toString()}'
      };
    }
  }

  // Méthode pour afficher les messages d'erreur ou de succès
  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Dialogue de confirmation
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الإضافة'),
          content: const Text('هل أنت متأكد من إضافة هذا الموظف؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موظف جديد'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Indicateur de chargement
              if (_isLoading)
                const LinearProgressIndicator(),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'رقم التعريف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم التعريف';
                  }
                  if (value.length < 3) {
                    return 'رقم التعريف يجب أن يحتوي على 3 أحرف على الأقل';
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
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم واللقب';
                  }
                  if (value.length < 2) {
                    return 'الاسم يجب أن يحتوي على حرفين على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildDateField(
                label: 'تاريخ الميلاد',
                value: _birthDate,
                icon: Icons.cake,
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
                icon: Icons.work_history,
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
                icon: Icons.work,
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
                  prefixIcon: Icon(Icons.business_center),
                ),
                value: _position,
                items: _positions.map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
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
                  prefixIcon: Icon(Icons.grade),
                ),
                value: _degree,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('الدرجة ${index + 1}'),
                  );
                }),
                onChanged: _isLoading ? null : (value) {
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
                  prefixIcon: Icon(Icons.timeline),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقاط الأقدمية';
                  }
                  try {
                    double parsedValue = double.parse(value);
                    if (parsedValue < 0) {
                      return 'النقاط يجب أن تكون قيمة موجبة';
                    }
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
                  prefixIcon: Icon(Icons.star),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقطة المدير';
                  }
                  try {
                    double parsedValue = double.parse(value);
                    if (parsedValue < 0 || parsedValue > 20) {
                      return 'نقطة المدير يجب أن تكون بين 0 و 20';
                    }
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
                  prefixIcon: Icon(Icons.school),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نقاط دورات التكوين';
                  }
                  try {
                    double parsedValue = double.parse(value);
                    if (parsedValue < 0) {
                      return 'النقاط يجب أن تكون قيمة موجبة';
                    }
                  } catch (e) {
                    return 'يرجى إدخال قيمة رقمية صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('جاري الإضافة...'),
                      ],
                    )
                  : const Text('إضافة الموظف', style: TextStyle(fontSize: 16)),
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
    required IconData icon,
    required Function(DateTime) onChanged,
  }) {
    final formatter = DateFormat('yyyy-MM-dd');
    
    return InkWell(
      onTap: _isLoading ? null : () async {
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
          prefixIcon: Icon(icon),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(value),
              style: TextStyle(
                color: _isLoading ? Colors.grey : null,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: _isLoading ? Colors.grey : null,
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Afficher dialogue de confirmation
      bool confirmed = await _showConfirmationDialog();
      if (!confirmed) return;

      setState(() {
        _isLoading = true;
      });

      try {
        // Créer l'objet Employee
        final employee = Employee(
          id: _idController.text.trim(),
          name: _nameController.text.trim(),
          birthDate: _birthDate,
          firstAppointmentDate: _firstAppointmentDate,
          currentAppointmentDate: _currentAppointmentDate,
          position: _position,
          degree: _degree,
          positionSeniorityPoints: double.parse(_positionSeniorityController.text),
          directorPoints: double.parse(_directorPointsController.text),
          trainingPoints: double.parse(_trainingPointsController.text),
        );

        // Envoyer à l'API
        final result = await _addEmployeeToDatabase(employee);

        if (result['success'] == true) {
          // Succès
          _showMessage('تم إضافة الموظف بنجاح', false);
          
          // Appeler le callback
          widget.onEmployeeAdded(employee);
          
          // Attendre un peu avant de fermer
          await Future.delayed(const Duration(seconds: 1));
          
          // Fermer la page
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Erreur
          _showMessage(result['message'] ?? 'حدث خطأ غير متوقع', true);
        }
      } catch (e) {
        _showMessage('خطأ: ${e.toString()}', true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}