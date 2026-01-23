import 'package:flutter/material.dart';

import '../../services/question_service.dart';
import '../../services/visit_service.dart';
import '../../services/child_service.dart';
import '../../services/sync_manager.dart';

class BaselineVisitScreen extends StatefulWidget {
  final String visitId;
  final String projectId;
  final String childId;
  final String childName;

  const BaselineVisitScreen({
    super.key,
    required this.visitId,
    required this.projectId,
    required this.childId,
    required this.childName,
  });

  @override
  State<BaselineVisitScreen> createState() => _BaselineVisitScreenState();
}

class _BaselineVisitScreenState extends State<BaselineVisitScreen> {
  final Map<String, dynamic> _answers = {};
  List<QuestionBundle> _questions = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final qs = await QuestionService.I.getBaselineQuestions(widget.projectId);
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
      await ChildService.I.markBaselineSubmittedLocal(
        childId: widget.childId,
        visitId: widget.visitId,
      );

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

    // 4) Normal render
    return Scaffold(
      appBar: AppBar(
        title: Text("Assessment: ${widget.childName}"),
        backgroundColor: teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length + 1,
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: teal),
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SUBMIT", style: TextStyle(color: Colors.white)),
            );
          }

          final q = _questions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${q.text}${q.isRequired ? ' *' : ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Single choice
                  if (['single_choice', 'single_select'].contains(q.type))
                    ...q.options.map(
                      (opt) => RadioListTile(
                        title: Text(opt['label']!),
                        value: opt['value'],
                        groupValue: _answers[q.questionId],
                        onChanged: (v) => setState(() => _answers[q.questionId] = v),
                      ),
                    )
                  else
                    TextField(
                      keyboardType: (q.type == 'number' || q.type == 'decimal')
                          ? TextInputType.number
                          : TextInputType.text,
                      onChanged: (v) => _answers[q.questionId] = v,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
