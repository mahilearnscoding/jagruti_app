import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive/hive.dart';

import '../../services/question_service.dart';
import '../../services/visit_service.dart';
import '../../services/child_service.dart';
import '../../services/sync_manager.dart';
import '../../services/location_service.dart';
import '../../services/camera_service.dart';
import '../../services/appwrite_service.dart';
import '../../utils/constants.dart';

class BaselineVisitScreen extends StatefulWidget {
  final String visitId;
  final String projectId;
  final String childId;
  final String childName;
  final String phase;
  final String? title;

  const BaselineVisitScreen({
    super.key,
    required this.visitId,
    required this.projectId,
    required this.childId,
    required this.childName,
    this.phase = Constants.phaseBaseline,
    this.title,
  });

  @override
  State<BaselineVisitScreen> createState() => _BaselineVisitScreenState();
}

class _BaselineVisitScreenState extends State<BaselineVisitScreen> {
  final Map<String, dynamic> _answers = {};
  List<QuestionBundle> _questions = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final int _questionsPerPage = 4;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  // Location and Photo state
  bool _hasLocation = false;
  bool _hasPhoto = false;
  bool _isCapturingLocation = false;
  bool _isCapturingPhoto = false;
  String? _photoUrl;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Group questions by section
  Map<String, List<QuestionBundle>> get _questionsBySection {
    final grouped = <String, List<QuestionBundle>>{};
    for (final q in _questions) {
      final section = q.section ?? 'General';
      grouped.putIfAbsent(section, () => []).add(q);
    }
    return grouped;
  }

  // Get paginated sections
  List<List<QuestionBundle>> get _paginatedQuestions {
    final pages = <List<QuestionBundle>>[];
    final sections = _questionsBySection.entries.toList()
      ..sort((a, b) => (a.value.first.sectionOrder ?? 999)
          .compareTo(b.value.first.sectionOrder ?? 999));

    for (final sectionEntry in sections) {
      final sectionQuestions = sectionEntry.value;
      for (int i = 0; i < sectionQuestions.length; i += _questionsPerPage) {
        final end = (i + _questionsPerPage > sectionQuestions.length)
            ? sectionQuestions.length
            : i + _questionsPerPage;
        pages.add(sectionQuestions.sublist(i, end));
      }
    }
    return pages;
  }

  int get _totalPages => _paginatedQuestions.length;

  Future<void> _loadForm() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // Get child information to determine age
      final childData = await ChildService.I.getChildById(widget.childId);
      
      // Calculate age in months
      int ageInMonths = 0;
      if (childData != null && childData['date_of_birth'] != null) {
        final dob = DateTime.parse(childData['date_of_birth']);
        final now = DateTime.now();
        final ageYears = now.year - dob.year;
        final ageMonthsRemainder = now.month - dob.month;
        ageInMonths = (ageYears * 12) + ageMonthsRemainder;
      }

      // Get ALL questions for baseline phase - no filtering to preserve existing Kannada questions
      // For demo: always use baseline phase since endline questions not yet in DB
      final effectivePhase = widget.phase == 'endline' ? Constants.phaseBaseline : widget.phase;
      final allQuestions = await QuestionService.I.getQuestionsForPhase(
        projectId: widget.projectId,
        phase: effectivePhase,
      );

      print('✅ Loaded ${allQuestions.length} questions from database (phase: $effectivePhase)');
      
      if (!mounted) return;

      setState(() {
        _questions = allQuestions; // Use ALL questions without filtering
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
      print('❌ Error loading questions: $e');
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _isCapturingLocation = true);
    
    try {
      final position = await LocationService.I.getCurrentLocation();
      if (position != null) {
        setState(() {
          _hasLocation = true;
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location captured: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCapturingLocation = false);
    }
  }

  Future<void> _capturePhoto() async {
    setState(() => _isCapturingPhoto = true);
    
    try {
      final result = await CameraService.I.captureGeotaggedPhotoWithLocation();
      setState(() {
        _hasPhoto = true;
        _photoUrl = result['photoUrl'];
        if (!_hasLocation) {
          _hasLocation = true;
          _latitude = result['latitude'];
          _longitude = result['longitude'];
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCapturingPhoto = false);
    }
  }

  Future<void> _submit() async {
    // Check if location is captured before submitting
    if (!_hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Required validation
    for (var q in _questions) {
      if (q.isRequired && _answers[q.questionId] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${q.text} is required")),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      print('🔍 DEBUG: Starting baseline submission...');
      print('🔍 DEBUG: Visit ID: ${widget.visitId}');
      print('🔍 DEBUG: Answers count: ${_answers.length}');

      // Save each answer locally using Hive
      final answersBox = Hive.box('visit_answers_local');
      for (var q in _questions) {
        final val = _answers[q.questionId];
        if (val != null) {
          final answerId = '${widget.visitId}_${q.questionId}';
          final answerData = {
            'id': answerId,
            'visit': widget.visitId,
            'question': q.questionId,
            'answer_value': val.toString(),
            'created_at': DateTime.now().toIso8601String(),
            'synced': false,
          };
          answersBox.put(answerId, answerData);
          print('✅ DEBUG: Saved answer locally for question ${q.questionId}: $val');
        }
      }

      // Update visit status locally
      final visitsBox = Hive.box('visits_local');
      final visitData = visitsBox.get(widget.visitId) ?? {};
      final updatedVisit = Map<String, dynamic>.from(visitData);
      updatedVisit['status'] = 'completed';
      updatedVisit['completed_at'] = DateTime.now().toIso8601String();
      
      // Add location data if available
      if (_hasLocation && _latitude != null && _longitude != null) {
        updatedVisit['latitude'] = _latitude.toString();
        updatedVisit['longitude'] = _longitude.toString();
      }
      updatedVisit['synced'] = false;
      visitsBox.put(widget.visitId, updatedVisit);

      // Mark child baseline as submitted locally
      await ChildService.I.markBaselineSubmittedLocal(
        childId: widget.childId,
        visitId: widget.visitId,
      );

      print('✅ DEBUG: Baseline visit marked as completed locally');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Baseline Survey Completed!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF26A69A);

    // 1) Loading UI
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Error UI (THIS is what you were missing)
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Assessment: ${widget.childName}"),
          backgroundColor: teal,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Failed to load questions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: teal),
                  onPressed: _loadForm,
                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3) Empty state
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Assessment: ${widget.childName}"),
          backgroundColor: teal,
        ),
        body: const Center(child: Text("No questions found.")),
      );
    }

    // 4) Normal render with PageView
    final pages = _paginatedQuestions;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Assessment: ${widget.childName}"),
        backgroundColor: teal,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_answers.length}/${_questions.length} answered',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(teal),
                ),
              ],
            ),
          ),
          
          // Questions PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: pages.length,
              itemBuilder: (context, pageIndex) {
                final pageQuestions = pages[pageIndex];
                final firstQuestion = pageQuestions.first;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      if (firstQuestion.section != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: teal.withOpacity(0.1),
                            border: Border.all(color: teal),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            firstQuestion.section!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Questions in this page
                      ...pageQuestions.map((q) => _buildQuestionCard(q)),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Location and Photo Capture Section - Side by side like counselling
          if (_currentPage == pages.length - 1) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      'Required before submission',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Location capture button
                        Expanded(
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.only(right: 8),
                            child: ElevatedButton.icon(
                              onPressed: _isCapturingLocation ? null : _captureLocation,
                              icon: _isCapturingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Icon(
                                      _hasLocation ? Icons.check_circle : Icons.location_on,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _hasLocation ? 'Located ✓' : 'Location',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasLocation ? Colors.green : Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                        
                        // Photo capture button
                        Expanded(
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: _isCapturingPhoto ? null : _capturePhoto,
                              icon: _isCapturingPhoto
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Icon(
                                      _hasPhoto ? Icons.check_circle : Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _hasPhoto ? 'Photo ✓' : 'Photo',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasPhoto ? Colors.green : teal,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Navigation and Submit buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Previous button
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                
                const SizedBox(width: 16),
                
                // Next/Submit button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: teal),
                    onPressed: _isSaving ? null : () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _submit();
                      }
                    },
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _currentPage < pages.length - 1 ? 'Next' : 'SUBMIT',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionBundle q) {
    const teal = Color(0xFF26A69A);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${q.text}${q.isRequired ? ' *' : ''}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Single choice
            if (['single_choice', 'single_select'].contains(q.type))
              ...q.options.map(
                (opt) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _answers[q.questionId] == opt['value'] 
                          ? teal 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RadioListTile<String>(
                    title: Text(opt['label']!),
                    value: opt['value']!,
                    groupValue: _answers[q.questionId],
                    onChanged: (v) => setState(() => _answers[q.questionId] = v),
                    activeColor: teal,
                  ),
                ),
              )
            else if (q.type == 'multi_choice')
              ...q.options.map((opt) {
                final current = (_answers[q.questionId] as Set<String>?) ?? <String>{};
                final value = opt['value']!;
                final checked = current.contains(value);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: checked ? teal : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    title: Text(opt['label']!),
                    value: checked,
                    onChanged: (v) {
                      final next = {...current};
                      if (v == true) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      setState(() => _answers[q.questionId] = next);
                    },
                    activeColor: teal,
                  ),
                );
              })
            else
              TextField(
                keyboardType: (q.type == 'number' || q.type == 'decimal')
                    ? TextInputType.number
                    : TextInputType.text,
                onChanged: (v) => _answers[q.questionId] = v,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: teal, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  /// Determines if a question should be included based on child's age and question content
  bool _shouldIncludeQuestionForAge(String questionText, int ageInMonths) {
    // Questions only for 6-35 months (young children)
    final young6to35Keywords = [
      'breast', 'breastfeed', 'ಸ್ತನ್ಯ', 'ಎದೆಹಾಲು', // breastfeeding related
      'first start giving', 'ಮೊದಲ', 'ಆರಂಭ', // introduction of food
    ];
    
    // Questions only for 36-59 months (older children)  
    final older36to59Keywords = [
      'hot cooked lunch', 'lunch', 'ಮಧ್ಯಾಹ್ನ ಊಟ', // lunch at anganwadi
      'breakfast', 'ಉದುರಾಸ್ತ', // breakfast
      'attend', 'ಹಾಜರಾತಿ', // attendance
      'anganwadi', 'ಅಂಗನವಾಡಿ', // anganwadi specific
    ];
    
    // Check if this is a young child specific question (6-35 months)
    final isYoungChildQuestion = young6to35Keywords.any((keyword) => 
        questionText.contains(keyword.toLowerCase()));
    
    // Check if this is an older child specific question (36-59 months)
    final isOlderChildQuestion = older36to59Keywords.any((keyword) => 
        questionText.contains(keyword.toLowerCase()));
    
    // Apply age-based filtering
    if (isYoungChildQuestion && ageInMonths >= 36) {
      return false; // Don't show breastfeeding questions to older children
    }
    
    if (isOlderChildQuestion && ageInMonths < 36) {
      return false; // Don't show complex anganwadi questions to young children
    }
    
    // Include all other questions (general questions apply to all ages)
    return true;
  }}
