import 'package:flutter/material.dart';

import '../../services/question_service.dart';
import '../../services/visit_service.dart';
import '../../services/child_service.dart';
import '../../services/sync_manager.dart';
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
      final qs = await QuestionService.I.getQuestionsForPhase(
        projectId: widget.projectId,
        phase: widget.phase,
      );
      if (!mounted) return;

      setState(() {
        _questions = qs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
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
      // LOCAL-FIRST: save each answer locally + enqueue sync
      for (var q in _questions) {
        final val = _answers[q.questionId];
        if (val != null) {
          await VisitService.I.saveAnswerLocal(
            visitId: widget.visitId,
            questionId: q.questionId,
            value: val,
          );
        }
      }

      // Mark visit submitted locally
      await VisitService.I.markVisitSubmittedLocal(visitId: widget.visitId);

      // Mark child baseline submitted locally
      switch (widget.phase) {
        case Constants.phaseBaseline:
          await ChildService.I.markBaselineSubmittedLocal(
            childId: widget.childId,
            visitId: widget.visitId,
          );
          break;
        case Constants.phaseCounselling:
          await ChildService.I.markCounsellingSubmittedLocal(
            childId: widget.childId,
            visitId: widget.visitId,
          );
          break;
        case Constants.phaseEndline:
          await ChildService.I.markEndlineSubmittedLocal(
            childId: widget.childId,
            visitId: widget.visitId,
          );
          break;
      }

      // Best-effort sync now (if online)
      await SyncManager.I.trySync();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Survey Saved (offline-first)!")),
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
}
