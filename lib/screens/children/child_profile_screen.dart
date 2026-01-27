import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/visit_service.dart';
import '../../services/sync_manager.dart';
import '../../services/local_storage_service.dart';
import '../../services/counselling_service.dart';
import '../../utils/constants.dart';
import '../visits/baseline_visit_screen.dart';
import '../visits/counselling_screen.dart';

class ChildProfileScreen extends StatefulWidget {
  final String projectId;
  final String childId;
  final String childName;
  final Map<String, dynamic> child;

  const ChildProfileScreen({
    super.key,
    required this.projectId,
    required this.childId,
    required this.childName,
    required this.child,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  late Map<String, dynamic> _childData;
  bool _isCounsellingLoading = false;
  bool _isEndlineLoading = false;

  @override
  void initState() {
    super.initState();
    _childData = Map<String, dynamic>.from(widget.child);
    _refreshChildData();
  }

  void _refreshChildData() async {
    final box = Hive.box('children_local');
    final local = box.get(widget.childId);
    if (local != null) {
      setState(() {
        _childData = Map<String, dynamic>.from(local);
      });
    }
    
    // Also check counselling completion from database
    try {
      final isCounsellingCompleted = await CounsellingService.I.isCounsellingCompleted(
        childId: widget.childId,
        projectId: widget.projectId,
      );
      if (isCounsellingCompleted && _childData['counsellingStatus'] != 'submitted') {
        _childData['counsellingStatus'] = 'submitted';
        box.put(widget.childId, _childData);
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Error checking counselling status: $e');
    }
  }

  //check if counselling is completed
  bool get _counsellingComplete => _childData['counsellingStatus'] == 'submitted';

  // Endline is enabled after counselling completion (baseline is already done)
  bool get _endlineEnabled => _counsellingComplete;

  Future<void> _startCounselling() async {
    setState(() => _isCounsellingLoading = true);

    try {
      await SyncManager.I.trySync();

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CounsellingScreen(
            projectId: widget.projectId,
            childId: widget.childId,
            childName: widget.childName,
          ),
        ),
      );

      if (result == true) {
        _refreshChildData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting counselling: $e')),
      );
    } finally {
      setState(() => _isCounsellingLoading = false);
    }
  }

  Future<void> _startEndline() async {
    if (!_counsellingComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Counselling survey must be completed first'),
        ),
      );
      return;
    }

    setState(() => _isEndlineLoading = true);

    try {
      final fwId = LocalStorageService.I.fieldWorkerId ?? 'unknown_worker';
      final visitId = await VisitService.I.createVisitLocal(
        childId: widget.childId,
        phase: Constants.phaseEndline,
        fwId: fwId,
      );

      await SyncManager.I.trySync();

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BaselineVisitScreen(
            visitId: visitId,
            projectId: widget.projectId,
            childId: widget.childId,
            childName: widget.childName,
            phase: Constants.phaseEndline,
            title: 'Endline: ${widget.childName}',
          ),
        ),
      );

      if (result == true) {
        _refreshChildData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting endline: $e')),
      );
    } finally {
      setState(() => _isEndlineLoading = false);
    }
  }

  Widget _statusBadge(String label, bool isComplete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? Colors.green : Colors.orange,
        ),
      ),
      child: Text(
        isComplete ? '✓ $label Done' : '○ $label Pending',
        style: TextStyle(
          color: isComplete ? Colors.green.shade800 : Colors.orange.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profile'),
        backgroundColor: teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: teal, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: teal,
                        child: Text(
                          (widget.childName[0]).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.childName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${widget.childId.substring(0, 8)}...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Basic details
                  _buildDetailRow('Guardian', _childData['guardian_name'] ?? 'N/A'),
                  _buildDetailRow('Contact', _childData['guardian_contact'] ?? 'N/A'),
                  _buildDetailRow(
                    'Age',
                    _childData['date_of_birth'] != null
                        ? '${(DateTime.now().difference(DateTime.parse(_childData['date_of_birth'])).inDays ~/ 365)} years'
                        : 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Phase Status Section
            Text(
              'Remaining Assessment Phases',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Note about baseline completion
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Baseline assessment completed',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Counselling Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _statusBadge('Counselling', _counsellingComplete),
                  const SizedBox(width: 8),
                  if (_counsellingComplete)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Endline Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _endlineEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(8),
                color: !_endlineEnabled ? Colors.grey.shade50 : null,
              ),
              child: Row(
                children: [
                  Opacity(
                    opacity: _endlineEnabled ? 1.0 : 0.5,
                    child: _statusBadge(
                      'Endline',
                      _childData['endlineStatus'] == 'submitted',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_childData['endlineStatus'] == 'submitted')
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  if (!_endlineEnabled && _childData['endlineStatus'] != 'submitted')
                    Tooltip(
                      message: 'Counselling must be completed first',
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Section
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Counselling Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: _isCounsellingLoading ? null : _startCounselling,
                child: _isCounsellingLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _counsellingComplete ? 'View Counselling' : 'Start Counselling',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Endline Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _endlineEnabled ? teal : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: !_endlineEnabled || _isEndlineLoading ? null : _startEndline,
                child: _isEndlineLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _childData['endlineStatus'] == 'submitted'
                            ? 'View Endline'
                            : 'Start Endline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Info text for endline gate
            if (!_endlineEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete Counselling survey to unlock Endline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
