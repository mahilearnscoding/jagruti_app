import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appwrite/appwrite.dart';
import '../../services/appwrite_service.dart';
import '../../utils/constants.dart';

const Color teal = Color(0xFF26A69A);

class ChildRegistrationScreen extends StatefulWidget {
  final String projectId;

  const ChildRegistrationScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ChildRegistrationScreen> createState() => _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Controllers for text fields
  final _householdHeadNameController = TextEditingController();
  final _villageController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherAgeController = TextEditingController();
  final _childNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianContactController = TextEditingController();

  // Form data
  String? _householdHeadGender;
  String? _totalMembers;
  String? _socialGroup;
  String? _primaryOccupation;
  String? _parentMigration;
  String? _mgnregaCard;
  String? _dustLevel;
  String? _motherLiteracy;
  String? _fatherLiteracy;
  String? _cookingFuel;
  String? _sanitationFacility;
  String? _drinkingWater;
  String? _handwashingFacility;
  String? _bplCard;
  String? _pdsFood;
  String? _areaType;
  String? _motherEducation;
  String? _motherAnaemia;
  String? _motherOccupation;
  String? _decisionMaking;
  DateTime? _childDateOfBirth;
  String? _childGender;
  String? _birthOrder;
  String? _primaryCaregiver;
  String? _caregiverTime;
  String? _anganwadiEnrolled;

  final List<String> _pages = [
    'Child Registration',
  ];

  @override
  void dispose() {
    _householdHeadNameController.dispose();
    _villageController.dispose();
    _motherNameController.dispose();
    _motherAgeController.dispose();
    _childNameController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    // Skip form validation - we'll do our own validation below
    
    // Validate essential fields
    if (_childNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child name is required')),
      );
      return;
    }
    if (_childDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of birth is required')),
      );
      return;
    }
    if (_childGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gender is required')),
      );
      return;
    }
    if (_guardianNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardian name is required')),
      );
      return;
    }
    if (_guardianContactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardian contact is required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final aw = AppwriteService.I;
      await aw.ensureSession();
      
      print('🔍 DEBUG: Starting child registration...');
      print('🔍 DEBUG: Project ID: ${widget.projectId}');
      print('🔍 DEBUG: Child name: ${_childNameController.text.trim()}');

      final childData = {
        'project': widget.projectId,
        'name': _childNameController.text.trim(),
        'date_of_birth': _childDateOfBirth!.toIso8601String(),
        'gender': _childGender!,
        'guardian_name': _guardianNameController.text.trim(),
        'guardian_contact': _guardianContactController.text.trim(),
      };

      print('🔍 DEBUG: Child data prepared, creating document...');
      print('🔍 DEBUG: Collection: ${Constants.colChildren}');

      final doc = await aw.create(
        collectionId: Constants.colChildren,
        documentId: ID.unique(),
        data: childData,
      );

      print('✅ DEBUG: Child created successfully with ID: ${doc.$id}');

      // Create baseline visit record immediately
      final visitData = {
        'child': doc.$id,
        'field_worker': (await aw.account.get()).$id,
        'visit_date': DateTime.now().toIso8601String(),
        'phase': 'baseline',
        'status': 'in_progress',
      };

      final visitDoc = await aw.create(
        collectionId: Constants.colVisits,
        documentId: ID.unique(),
        data: visitData,
      );

      print('✅ DEBUG: Baseline visit created with ID: ${visitDoc.$id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child registered successfully!')),
        );
        
        // Navigate to baseline questions with visit ID
        Navigator.pushReplacementNamed(
          context,
          '/baseline_visit',
          arguments: {
            'childId': doc.$id,
            'visitId': visitDoc.$id,  // Pass visit ID for saving answers
            'childName': _childNameController.text.trim(),
            'projectId': widget.projectId,
          },
        );
      }
    } catch (e) {
      print('❌ DEBUG: Child registration failed: $e');
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering child: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Child - ${_pages[_currentPage]}'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [

            // Single page child registration form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child Registration',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Child Name
                      _buildTextField(
                        controller: _childNameController,
                        label: "Child's Name *",
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      // Date of birth
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date of Birth *', style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          )),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 365)),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _childDateOfBirth = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _childDateOfBirth != null
                                        ? "${_childDateOfBirth!.day}/${_childDateOfBirth!.month}/${_childDateOfBirth!.year}"
                                        : 'Select date of birth',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _childDateOfBirth != null ? Colors.black : Colors.grey[600],
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, color: teal),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Gender
                      _buildFieldWithOptions(
                        label: "Gender",
                        selectedValue: _childGender,
                        options: const ['Male', 'Female', 'Other'],
                        onChanged: (value) => setState(() => _childGender = value),
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      // Guardian Name
                      _buildTextField(
                        controller: _guardianNameController,
                        label: "Guardian Name *",
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      // Guardian Contact
                      _buildTextField(
                        controller: _guardianContactController,
                        label: "Guardian Contact *",
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Register button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitRegistration,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Register Child',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Household Background Characteristics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _householdHeadNameController,
            label: 'Name of head of household',
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildFieldWithOptions(
            label: 'Gender of head of household',
            selectedValue: _householdHeadGender,
            options: const ['Male', 'Female', 'Other'],
            onChanged: (value) => setState(() => _householdHeadGender = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildFieldWithOptions(
            label: 'Total number of members in household',
            selectedValue: _totalMembers,
            options: const ['1-3', '4-6', '7-10', 'More than 10'],
            onChanged: (value) => setState(() => _totalMembers = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _villageController,
            label: 'Village/Area',
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMotherPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mother Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _motherNameController,
            label: "Mother's name",
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _motherAgeController,
            label: "Mother's age (in years)",
            keyboardType: TextInputType.number,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildFieldWithOptions(
            label: 'Mother can read and write',
            selectedValue: _motherLiteracy,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _motherLiteracy = value),
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChildPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Child Characteristics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _childNameController,
            label: "Child's name",
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Date of birth
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Child's date of birth *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _childDateOfBirth = date);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _childDateOfBirth != null
                            ? DateFormat('dd/MM/yyyy').format(_childDateOfBirth!)
                            : 'Select date of birth',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildFieldWithOptions(
            label: "Child's gender",
            selectedValue: _childGender,
            options: const ['Male', 'Female'],
            onChanged: (value) => setState(() => _childGender = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _guardianNameController,
            label: 'Guardian/Contact person name',
            isRequired: true,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _guardianContactController,
            label: 'Contact number',
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: teal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildFieldWithOptions({
    required String label,
    required String? selectedValue,
    required List<String> options,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return InkWell(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? teal.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? teal : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? teal : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (isRequired && selectedValue == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select an option',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}