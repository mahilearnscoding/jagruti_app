import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/child_service.dart';
import '../../services/visit_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/sync_manager.dart';
import '../../utils/constants.dart';
import '../visits/baseline_visit_screen.dart';

class AddChildScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  const AddChildScreen({super.key, required this.projectId, required this.projectName});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _nameCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _gender = 'female';
  DateTime? _dob;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _saveAndStartBaseline() async {
    if (_nameCtrl.text.isEmpty || _dob == null || _guardianCtrl.text.isEmpty || _contactCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required: Name, DOB, Guardian Name, and Contact")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1) Create Child LOCAL-FIRST (works offline)
      final childId = await ChildService.I.createChildLocal(
        projectId: widget.projectId,
        name: _nameCtrl.text,
        gender: _gender,
        dob: _dob!,
        guardianName: _guardianCtrl.text,
        guardianContact: _contactCtrl.text,
      );

      // 2) Auto-create Baseline Visit LOCAL-FIRST
      final fwId = LocalStorageService.I.fieldWorkerId ?? 'unknown_worker';

      final visitId = await VisitService.I.createVisitLocal(
        childId: childId,
        phase: Constants.phaseBaseline,
        fwId: fwId,
      );

      // NOTE: No sync here! Child will be synced only after baseline is submitted

      // 3) Navigate to survey (same flow, but now we pass childId too)
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BaselineVisitScreen(
            visitId: visitId,
            projectId: widget.projectId,
            childId: childId,
            childName: _nameCtrl.text,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Child Registration"),
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Child Name"),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: _gender,
              items: ['male', 'female', 'other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v!),
              decoration: const InputDecoration(labelText: "Gender"),
            ),
            const SizedBox(height: 12),

            ListTile(
              title: Text(_dob == null ? "Select Date of Birth" : DateFormat('yyyy-MM-dd').format(_dob!)),
              trailing: const Icon(Icons.calendar_today),
              tileColor: Colors.grey[200],
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _guardianCtrl,
              decoration: const InputDecoration(labelText: "Guardian Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _contactCtrl,
              decoration: const InputDecoration(labelText: "Guardian Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                onPressed: _isLoading ? null : _saveAndStartBaseline,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE & START BASELINE",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
