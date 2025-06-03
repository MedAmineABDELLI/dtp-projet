import 'package:dtp_projet/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SearchEmployeePage extends StatefulWidget {
  const SearchEmployeePage({Key? key, required List<Employee> employees}) : super(key: key);

  @override
  _SearchEmployeePageState createState() => _SearchEmployeePageState();
}

class _SearchEmployeePageState extends State<SearchEmployeePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> _filteredEmployees = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounceTimer;
  
 
  
  
  @override
  void initState() {
    super.initState();
    _filteredEmployees = [];
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن موظف'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'بحث بالاسم أو رقم التعريف',
                prefixIcon: _isLoading 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _clearSearch();
                  },
                ),
                border: const OutlineInputBorder(),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredEmployees.isEmpty && _searchController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'أدخل اسم أو رقم تعريف للبحث',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
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
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    
    if (_filteredEmployees.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد نتائج للبحث',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                employee.name.isNotEmpty ? employee.name[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              employee.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${employee.position} - الدرجة ${employee.degree}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (employee.isEligibleForPromotion())
                  const Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                const Icon(Icons.arrow_forward_ios, size: 16),
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

  void _onSearchChanged(String query) {
    // Annuler le timer précédent
    _debounceTimer?.cancel();
    
    // Créer un nouveau timer pour éviter trop de requêtes
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        _clearSearch();
      } else if (query.trim().length >= 2) { // Rechercher seulement si au moins 2 caractères
        _performSearch(query.trim());
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _filteredEmployees = [];
      _errorMessage = '';
      _isLoading = false;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final uri = Uri.parse('http://localhost/dtp/chercher.php')
          .replace(queryParameters: {'query': query});
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> employeesJson = data['employees'] ?? [];
          final List<Employee> employees = employeesJson
              .map((json) => Employee.fromJson(json))
              .toList();
          
          setState(() {
            _filteredEmployees = employees;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['error'] ?? 'خطأ في البحث';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'خطأ في الخادم (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال بالخادم';
        _isLoading = false;
      });
      print('Error searching employees: $e');
    }
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(employee.name)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('رقم التعريف', employee.id),
                _buildDetailRow('تاريخ الميلاد', dateFormatter.format(employee.birthDate)),
                _buildDetailRow('العمر', '${employee.calculateAge()} سنة'),
                _buildDetailRow('تاريخ أول تعيين', dateFormatter.format(employee.firstAppointmentDate)),
                _buildDetailRow('تاريخ التعيين الحالي', dateFormatter.format(employee.currentAppointmentDate)),
                _buildDetailRow('المنصب', employee.position),
                _buildDetailRow('الدرجة', employee.degree.toString()),
                const Divider(),
                _buildDetailRow('نقاط الأقدمية في المنصب', employee.positionSeniorityPoints.toString()),
                _buildDetailRow('نقطة المدير', employee.directorPoints.toString()),
                _buildDetailRow('نقاط دورات التكوين', employee.trainingPoints.toString()),
                _buildDetailRow('إجمالي النقاط', employee.calculateTotalPoints().toString(), 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _buildDetailRow('الأقدمية الإجمالية', '${employee.calculateSeniorityInMonths()} شهر'),
                _buildDetailRow('الأقدمية في المنصب الحالي', '${employee.calculateCurrentPositionSeniorityInMonths()} شهر'),
                _buildDetailRow(
                  'أهلية الترقية',
                  employee.isEligibleForPromotion() ? 'مؤهل للترقية' : 'غير مؤهل للترقية',
                  color: employee.isEligibleForPromotion() ? Colors.green : Colors.red,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildDetailRow(String label, String value, {Color? color, TextStyle? style}) {
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
              style: (style ?? const TextStyle()).copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}