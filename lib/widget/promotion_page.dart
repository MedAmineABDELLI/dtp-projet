import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dtp_projet/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PromotionCalculationPage extends StatefulWidget {
  const PromotionCalculationPage({Key? key, required List<Employee> employees}) : super(key: key);

  @override
  State<PromotionCalculationPage> createState() => _PromotionCalculationPageState();
}

class _PromotionCalculationPageState extends State<PromotionCalculationPage> {
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
          title: const Text('حساب الترقيات'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل بيانات الموظفين...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('حساب الترقيات'),
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
          title: const Text('حساب الترقيات'),
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

    // تجميع الموظفين حسب المنصب والدرجة
    final employeesByPosition = groupEmployeesByPosition(employees);

    return DefaultTabController(
      length: employeesByPosition.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حساب الترقيات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadEmployees,
              tooltip: 'تحديث البيانات',
            ),
          ],
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _generateAndPrintPDF(position, degree, employees, promotedEmployees);
            },
            child: const Text('طباعة'),
          ),
        ],
      );
    },
  );
}

Future<void> _generateAndPrintPDF(
  String position, 
  int degree, 
  List<Employee> employees, 
  List<Employee> promotedEmployees,
) async {
  try {
    // Afficher un indicateur de chargement
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du PDF en cours...')),
    );

    // 1. Vérifier la disponibilité du service d'impression
    

    // 2. Charger la police arabe
    final ByteData fontData;
    try {
      fontData = await rootBundle.load("fonts/Cairo.ttf");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement de la police: $e')),
      );
      return;
    }
    final ttf = pw.Font.ttf(fontData);

    // 3. Création du document PDF
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttf,
        italic: ttf,
        boldItalic: ttf,
      ),
    );

    // 4. Construction du contenu PDF
    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // En-tête du document
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'تقرير الترقيات',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'المنصب: $position - الدرجة: $degree',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    'تاريخ التقرير: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Section 1: Liste de tous les employés
            pw.Text(
              'قائمة جميع الموظفين:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
               // backgroundColor: PdfColors.grey300,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              headers: [
                'الاسم واللقب',
                'النقاط',
                'الأقدمية (شهر)',
                'الترقية',
              ],
              data: employees.map((employee) {
                final isPromoted = promotedEmployees.contains(employee);
                return [
                  employee.name,
                  employee.calculateTotalPoints().toStringAsFixed(2),
                  employee.calculateSeniorityInMonths().toString(),
                  isPromoted ? 'نعم' : 'لا',
                ];
              }).toList(),
              cellStyle: const pw.TextStyle(
                //: pw.TextAlign.center,
              ),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
            ),
            
            // Section 2: Liste des employés promus
            if (promotedEmployees.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Text(
                'الموظفين المترقين:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                 // backgroundColor: PdfColors.grey300,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                headers: [
                  'الاسم واللقب',
                  'النقاط',
                  'الدرجة الجديدة',
                ],
                data: promotedEmployees.map((employee) {
                  return [
                    employee.name,
                    employee.calculateTotalPoints().toStringAsFixed(2),
                    '${degree + 1}',
                  ];
                }).toList(),
                cellStyle: const pw.TextStyle(
                 // textAlign: pw.TextAlign.center,
                ),
              ),
            ],
            
            // Section 3: Statistiques
            pw.SizedBox(height: 30),
            pw.Text(
              'إحصائيات الترقية:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Bullet(text: 'عدد الموظفين الكلي: ${employees.length}'),
            pw.Bullet(text: 'عدد المترقين: ${promotedEmployees.length}'),
            pw.Bullet(
              text: 'نسبة الترقية: ${((promotedEmployees.length / employees.length) * 100).toStringAsFixed(1)}%',
            ),
            
            // Pied de page
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'تم إنشاء هذا التقرير تلقائياً بواسطة نظام إدارة الموارد البشرية',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ];
        },
      ),
    );

    // 5. Impression du document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      format: PdfPageFormat.a4,
      name: 'تقرير_الترقيات_${position}_$degree',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء التقرير بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e, stack) {
    debugPrint('Erreur lors de la génération du PDF: $e');
    debugPrint('Stack trace: $stack');
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ في إنشاء التقرير: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
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