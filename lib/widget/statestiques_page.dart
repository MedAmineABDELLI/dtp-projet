// صفحة إحصائيات الترقيات المحسنة
import 'package:dtp_projet/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EnhancedPromotionStatisticsPage extends StatefulWidget {
  const EnhancedPromotionStatisticsPage({Key? key, required List<Employee> employees}) : super(key: key);

  @override
  _EnhancedPromotionStatisticsPageState createState() => _EnhancedPromotionStatisticsPageState();
}

class _EnhancedPromotionStatisticsPageState extends State<EnhancedPromotionStatisticsPage>
    with SingleTickerProviderStateMixin {
      static const String apiUrl = 'http://localhost/dtp/stat.php';
  Map<String, dynamic>? statisticsData;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          setState(() {
            statisticsData = jsonData['data'];
            isLoading = false;
          });
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception('فشل في تحميل البيانات');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات الترقيات المتقدمة'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportStatistics,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
            Tab(text: 'حسب المنصب', icon: Icon(Icons.work)),
            Tab(text: 'حسب الدرجة', icon: Icon(Icons.grade)),
            Tab(text: 'التحليل العمري', icon: Icon(Icons.people)),
            Tab(text: 'الأداء', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الإحصائيات...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              onPressed: _loadStatistics,
            ),
          ],
        ),
      );
    }

    if (statisticsData == null) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildPositionStatsTab(),
        _buildDegreeStatsTab(),
        _buildAgeAnalysisTab(),
        _buildPerformanceTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final data = statisticsData!;
    final detailedAnalysis = data['detailedAnalysis'] ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقات الإحصائيات الرئيسية
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الموظفين',
                  data['totalEmployees'].toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'المؤهلون للترقية',
                  data['eligibleEmployees'].toString(),
                  Icons.person_add,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'سيتم ترقيتهم',
                  data['promotedEmployees'].toString(),
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'نسبة الترقية',
                  '${data['promotionRate']}%',
                  Icons.percent,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // تحليل مفصل
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'التحليل المفصل',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildAnalysisRow('متوسط العمر', '${detailedAnalysis['averageAge'] ?? 0} سنة'),
                  _buildAnalysisRow('متوسط الخبرة', '${detailedAnalysis['averageSeniority'] ?? 0} سنة'),
                  _buildAnalysisRow('متوسط النقاط', '${detailedAnalysis['averagePoints'] ?? 0}'),
                  _buildAnalysisRow('معدل الأهلية', '${detailedAnalysis['eligibilityRate'] ?? 0}%'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // الرسم البياني الدائري للتوزيع
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'توزيع الموظفين',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDistributionChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionStatsTab() {
    final positionStats = statisticsData!['positionStats'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات المناصب',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: positionStats.length,
            itemBuilder: (context, index) {
              final position = positionStats.keys.elementAt(index);
              final stats = positionStats[position] as Map<String, dynamic>;
              final promotionRate = stats['total'] > 0 
                  ? ((stats['promoted'] / stats['total']) * 100).toStringAsFixed(2)
                  : '0.00';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      stats['total'].toString(),
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    position,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('معدل الترقية: $promotionRate%'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProgressRow('العدد الإجمالي', stats['total'], stats['total']),
                          _buildProgressRow('المؤهلون', stats['eligible'], stats['total']),
                          _buildProgressRow('سيتم ترقيتهم', stats['promoted'], stats['total']),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDegreeStatsTab() {
    final degreeStats = statisticsData!['degreeStats'] as Map<String, dynamic>;
    final sortedDegrees = degreeStats.keys.toList()..sort();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات الدرجات الوظيفية',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: sortedDegrees.length,
            itemBuilder: (context, index) {
              final degree = sortedDegrees[index];
              final stats = degreeStats[degree] as Map<String, dynamic>;
              final promotionRate = stats['total'] > 0 
                  ? ((stats['promoted'] / stats['total']) * 100).toStringAsFixed(1)
                  : '0.0';
              
              return Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'الدرجة $degree',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الإجمالي: ${stats['total']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'المؤهلون: ${stats['eligible']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'المرقون: ${stats['promoted']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$promotionRate%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: double.parse(promotionRate) > 30 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgeAnalysisTab() {
    final ageStats = statisticsData!['ageGroupStats'] as Map<String, dynamic>;
    final seniorityStats = statisticsData!['seniorityStats'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إحصائيات العمر
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cake, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'توزيع الأعمار',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...ageStats.entries.map((entry) => 
                    _buildAgeGroupBar(entry.key, entry.value, statisticsData!['totalEmployees'])
                  ).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // إحصائيات الخبرة
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'توزيع سنوات الخبرة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...seniorityStats.entries.map((entry) => 
                    _buildSeniorityGroupBar(entry.key, entry.value, statisticsData!['totalEmployees'])
                  ).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final detailedAnalysis = statisticsData!['detailedAnalysis'] as Map<String, dynamic>;
    final topPerformers = detailedAnalysis['topPerformers'] as List<dynamic>? ?? [];
    final promotionsByPosition = detailedAnalysis['promotionsByPosition'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أفضل المؤدين
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'أفضل 10 مؤدين',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topPerformers.length,
                    itemBuilder: (context, index) {
                      final performer = topPerformers[index] as Map<String, dynamic>;
                      final totalPoints = (performer['positionSeniorityPoints'] ?? 0) + 
                                        (performer['directorPoints'] ?? 0) + 
                                        (performer['trainingPoints'] ?? 0);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getPerformanceColor(index),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(performer['name'] ?? ''),
                        subtitle: Text('${performer['position']} - الدرجة ${performer['degree']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              totalPoints.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('نقطة', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // معدلات الترقية حسب المنصب
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'معدلات الترقية حسب المنصب',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...promotionsByPosition.entries.map((entry) {
                    final position = entry.key;
                    final data = entry.value as Map<String, dynamic>;
                    return _buildPromotionRateBar(position, data['rate'], data['promoted'], data['total']);
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
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

  Widget _buildProgressRow(String label, int value, int total) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$value من $total'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.7 ? Colors.green : 
              percentage > 0.4 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupBar(String ageGroup, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$ageGroup سنة'),
              Text('$count (${(percentage * 100).toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildSeniorityGroupBar(String seniorityGroup, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$seniorityGroup سنة'),
              Text('$count (${(percentage * 100).toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionRateBar(String position, double rate, int promoted, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  position,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text('$promoted/$total (${rate.toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rate / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              rate > 50 ? Colors.green : 
              rate > 25 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart() {
    final total = statisticsData!['totalEmployees'] as int;
    final eligible = statisticsData!['eligibleEmployees'] as int;
    final promoted = statisticsData!['promotedEmployees'] as int;
    final notEligible = total - eligible;
    final eligibleNotPromoted = eligible - promoted;
    
    return Container(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: promoted,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  'مرقون\n$promoted',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: eligibleNotPromoted,
            child: Container(
              color: Colors.orange[400],
              child: Center(
                child: Text(
                  'مؤهلون\nغير مرقين\n$eligibleNotPromoted',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: notEligible,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  'غير مؤهلين\n$notEligible',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(int index) {
    if (index < 3) return Colors.amber[700]!;
    if (index < 6) return Colors.orange[600]!;
    return Colors.blue[600]!;
  }

  Future<void> _exportStatistics() async {
    try {
      if (statisticsData == null) return;
      
      final report = _generateReport();
      
      // حفظ التقرير في ملف مؤقت
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/promotion_statistics_report.txt');
      await file.writeAsString(report, encoding: utf8);
      
      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'تقرير إحصائيات الترقيات',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تصدير التقرير بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تصدير التقرير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateReport() {
    if (statisticsData == null) return '';
    
    final data = statisticsData!;
    final detailedAnalysis = data['detailedAnalysis'] as Map<String, dynamic>;
    final positionStats = data['positionStats'] as Map<String, dynamic>;
    
    final buffer = StringBuffer();
    
    // رأس التقرير
    buffer.writeln('=== تقرير إحصائيات الترقيات ===');
    buffer.writeln('تاريخ التقرير: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('');
    
    // الإحصائيات العامة
    buffer.writeln('--- الإحصائيات العامة ---');
    buffer.writeln('إجمالي الموظفين: ${data['totalEmployees']}');
    buffer.writeln('المؤهلون للترقية: ${data['eligibleEmployees']}');
    buffer.writeln('سيتم ترقيتهم: ${data['promotedEmployees']}');
    buffer.writeln('نسبة الترقية: ${data['promotionRate']}%');
    buffer.writeln('معدل الأهلية: ${detailedAnalysis['eligibilityRate']}%');
    buffer.writeln('');
    
    // التحليل المفصل
    buffer.writeln('--- التحليل المفصل ---');
    buffer.writeln('متوسط العمر: ${detailedAnalysis['averageAge']} سنة');
    buffer.writeln('متوسط الخبرة: ${detailedAnalysis['averageSeniority']} سنة');
    buffer.writeln('متوسط النقاط: ${detailedAnalysis['averagePoints']}');
    buffer.writeln('');
    
    // إحصائيات المناصب
    buffer.writeln('--- إحصائيات المناصب ---');
    positionStats.forEach((position, stats) {
      final s = stats as Map<String, dynamic>;
      final rate = s['total'] > 0 ? ((s['promoted'] / s['total']) * 100).toStringAsFixed(2) : '0.00';
      buffer.writeln('$position:');
      buffer.writeln('  - الإجمالي: ${s['total']}');
      buffer.writeln('  - المؤهلون: ${s['eligible']}');
      buffer.writeln('  - المرقون: ${s['promoted']}');
      buffer.writeln('  - معدل الترقية: $rate%');
      buffer.writeln('');
    });
    
    return buffer.toString();
  }
}