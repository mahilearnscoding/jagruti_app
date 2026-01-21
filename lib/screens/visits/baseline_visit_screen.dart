import 'package:flutter/material.dart';
import '../../services/question_service.dart';
import '../../services/visit_service.dart';

class BaselineVisitScreen extends StatefulWidget {
  final String visitId;
  final String projectId;
  final String childName;
  const BaselineVisitScreen({super.key, required this.visitId, required this.projectId, required this.childName});

  @override
  State<BaselineVisitScreen> createState() => _BaselineVisitScreenState();
}

class _BaselineVisitScreenState extends State<BaselineVisitScreen> {
  final Map<String, dynamic> _answers = {}; 
  List<QuestionBundle> _questions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  void _loadForm() async {
    final qs = await QuestionService.I.getBaselineQuestions(widget.projectId);
    if (mounted) {
      setState(() { 
        _questions = qs; 
        _isLoading = false; 
      });
    }
  }

  void _submit() async {
    for (var q in _questions) {
      if (q.isRequired && _answers[q.questionId] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${q.text} is required")));
        return;
      }
    }

    setState(() => _isSaving = true);
    
    try {
      for (var q in _questions) {
        if (_answers[q.questionId] != null) {
          await VisitService.I.saveAnswer(
            visitId: widget.visitId, 
            questionId: q.questionId, 
            value: _answers[q.questionId]
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Survey Saved!")));
        Navigator.pop(context, true); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assessment: ${widget.childName}"), backgroundColor: const Color(0xFF26A69A)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _questions.isEmpty 
          ? const Center(child: Text("No questions found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length + 1,
              itemBuilder: (context, index) {
                if (index == _questions.length) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("SUBMIT", style: TextStyle(color: Colors.white)),
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
                        Text("${q.text}${q.isRequired ? ' *' : ''}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (['single_choice', 'single_select'].contains(q.type))
                          ...q.options.map((opt) => RadioListTile(
                            title: Text(opt['label']!),
                            value: opt['value'],
                            groupValue: _answers[q.questionId],
                            onChanged: (v) => setState(() => _answers[q.questionId] = v),
                          ))
                        else
                          TextField(
                            keyboardType: q.type == 'number' || q.type == 'decimal' ? TextInputType.number : TextInputType.text,
                            onChanged: (v) => _answers[q.questionId] = v,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}