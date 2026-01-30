import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appwrite/appwrite.dart';
import '../../services/appwrite_service.dart';
import '../../utils/constants.dart';

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
  final _childIdController = TextEditingController();
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
  String? _dietaryPattern;
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
    'Household Background',
    'Mother Details',
    'Child Details',
  ];

  @override
  void dispose() {
    _householdHeadNameController.dispose();
    _villageController.dispose();
    _motherNameController.dispose();
    _motherAgeController.dispose();
    _childNameController.dispose();
    _childIdController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final aw = AppwriteService.I;
      await aw.ensureSession();

      // Calculate child's age
      int ageYears = 0;
      int ageMonths = 0;
      if (_childDateOfBirth != null) {
        final now = DateTime.now();
        ageYears = now.year - _childDateOfBirth!.year;
        ageMonths = now.month - _childDateOfBirth!.month;
        if (ageMonths < 0) {
          ageYears--;
          ageMonths += 12;
        }
      }

      final childData = {
        'name': _childNameController.text.trim(),
        'project': widget.projectId,
        'gender': _childGender ?? 'Male',
        'date_of_birth': _childDateOfBirth?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'guardian_name': _guardianNameController.text.trim(),
        'guardian_contact': _guardianContactController.text.trim(),
        
        // Household data
        'household_head_name': _householdHeadNameController.text.trim(),
        'household_head_gender': _householdHeadGender,
        'total_members': _totalMembers,
        'social_group': _socialGroup,
        'primary_occupation': _primaryOccupation,
        'parent_migration': _parentMigration,
        'mgnrega_card': _mgnregaCard,
        'dust_level': _dustLevel,
        'mother_literacy': _motherLiteracy,
        'father_literacy': _fatherLiteracy,
        'cooking_fuel': _cookingFuel,
        'sanitation_facility': _sanitationFacility,
        'drinking_water': _drinkingWater,
        'handwashing_facility': _handwashingFacility,
        'dietary_pattern': _dietaryPattern,
        'bpl_card': _bplCard,
        'pds_food': _pdsFood,
        
        // Mother data
        'mother_name': _motherNameController.text.trim(),
        'mother_age': _motherAgeController.text.trim(),
        'village_name': _villageController.text.trim(),
        'area_type': _areaType,
        'mother_education': _motherEducation,
        'mother_anaemia': _motherAnaemia,
        'mother_occupation': _motherOccupation,
        'decision_making': _decisionMaking,
        
        // Child specific data
        'child_id': _childIdController.text.trim(),
        'age_years': ageYears,
        'age_months': ageMonths,
        'birth_order': _birthOrder,
        'primary_caregiver': _primaryCaregiver,
        'caregiver_time': _caregiverTime,
        'anganwadi_enrolled': _anganwadiEnrolled,
      };

      final doc = await aw.create(
        collectionId: Constants.colChildren,
        documentId: ID.unique(),
        data: childData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Child registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering child: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        title: Text('Register Child - ${_pages[_currentPage]}'),
        backgroundColor: teal,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(_pages.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < _pages.length - 1 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage ? teal : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildHouseholdPage(),
                  _buildMotherPage(),
                  _buildChildPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: teal),
                      onPressed: _isSubmitting ? null : () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _submitRegistration();
                        }
                      },
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _currentPage < _pages.length - 1 ? 'Next' : 'Register Child',
                              style: const TextStyle(color: Colors.white),
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

          // Head of household name
          _buildTextField(
            controller: _householdHeadNameController,
            label: 'Name of head of household',
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Gender of head
          _buildFieldWithOptions(
            label: 'Gender of head of household',
            selectedValue: _householdHeadGender,
            options: const ['Male', 'Female', 'Other'],
            onChanged: (value) => setState(() => _householdHeadGender = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Total members
          _buildFieldWithOptions(
            label: 'Total number of members in household',
            selectedValue: _totalMembers,
            options: const ['1-3', '4-6', '7-10', 'More than 10'],
            onChanged: (value) => setState(() => _totalMembers = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Social group
          _buildFieldWithOptions(
            label: 'Social group/caste of household',
            selectedValue: _socialGroup,
            options: const ['Scheduled Caste', 'Scheduled Tribe', 'Other Backward Class', 'General', 'Other'],
            onChanged: (value) => setState(() => _socialGroup = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Primary occupation
          _buildFieldWithOptions(
            label: 'Primary occupation (main source of income)',
            selectedValue: _primaryOccupation,
            options: const ['Agriculture', 'Daily wage labour', 'Small business', 'Government job', 'Private job', 'Other'],
            onChanged: (value) => setState(() => _primaryOccupation = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Parent migration
          _buildFieldWithOptions(
            label: 'Does any parent migrate for work?',
            selectedValue: _parentMigration,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _parentMigration = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // MGNREGA card
          _buildFieldWithOptions(
            label: 'Does household have MGNREGA job card?',
            selectedValue: _mgnregaCard,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _mgnregaCard = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Dust level
          _buildFieldWithOptions(
            label: 'Is there dust around home due to mining?',
            selectedValue: _dustLevel,
            options: const ['Yes, a lot', 'Yes, some', 'No'],
            onChanged: (value) => setState(() => _dustLevel = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Village/Area
          _buildTextField(
            controller: _villageController,
            label: 'Village/Area',
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
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Gender of head
          _buildDropdown(
            'Gender of head of household',
            _householdHeadGender,
            ['Male', 'Female', 'Other'],
            (value) => setState(() => _householdHeadGender = value),
          ),
          const SizedBox(height: 16),

          // Total members
          _buildDropdown(
            'Total number of members in household',
            _totalMembers,
            ['1-3', '4-5', '6-7', '8 or more'],
            (value) => setState(() => _totalMembers = value),
          ),
          const SizedBox(height: 16),

          // Social group
          _buildDropdown(
            'Social group/caste of household',
            _socialGroup,
            ['Scheduled Caste (SC)', 'Scheduled Tribe (ST)', 'Other Backward Class (OBC)', 'General', 'Prefer not to say'],
            (value) => setState(() => _socialGroup = value),
          ),
          const SizedBox(height: 16),

          // Primary occupation
          _buildDropdown(
            'Primary occupation (main source of income)',
            _primaryOccupation,
            ['Mining-related work', 'Daily wage labour (non-mining)', 'Agriculture (own land)', 'Salaried job', 'Self-employed/business', 'Other'],
            (value) => setState(() => _primaryOccupation = value),
          ),
          const SizedBox(height: 16),

          // Parent migration
          _buildDropdown(
            'Does any parent migrate for work?',
            _parentMigration,
            ['No', 'Yes, father', 'Yes, mother'],
            (value) => setState(() => _parentMigration = value),
          ),
          const SizedBox(height: 16),

          // MGNREGA card
          _buildDropdown(
            'Does household have MGNREGA job card?',
            _mgnregaCard,
            ['Yes', 'No', "Don't know"],
            (value) => setState(() => _mgnregaCard = value),
          ),
          const SizedBox(height: 16),

          // Dust level
          _buildDropdown(
            'Is there dust around home due to mining?',
            _dustLevel,
            ['Yes, a lot', 'Some', 'No'],
            (value) => setState(() => _dustLevel = value),
          ),
          const SizedBox(height: 16),

          // Mother literacy
          _buildDropdown(
            'Literacy status of mother',
            _motherLiteracy,
            ['Cannot read or write', 'Can read and write', 'Completed primary school or above'],
            (value) => setState(() => _motherLiteracy = value),
          ),
          const SizedBox(height: 16),

          // Father literacy
          _buildDropdown(
            'Literacy status of father',
            _fatherLiteracy,
            ['Cannot read or write', 'Can read and write', 'Completed primary school or above'],
            (value) => setState(() => _fatherLiteracy = value),
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

          // Mother's name
          _buildTextField(
            controller: _motherNameController,
            label: "Mother's name",
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Mother's age
          _buildTextField(
            controller: _motherAgeController,
            label: "Mother's age (in years)",
            keyboardType: TextInputType.number,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Area type
          _buildFieldWithOptions(
            label: 'Type of area',
            selectedValue: _areaType,
            options: const ['Rural', 'Urban', 'Semi-urban'],
            onChanged: (value) => setState(() => _areaType = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Mother's literacy
          _buildFieldWithOptions(
            label: 'Mother can read and write',
            selectedValue: _motherLiteracy,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _motherLiteracy = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Mother's education
          _buildFieldWithOptions(
            label: 'Mother\'s highest level of education',
            selectedValue: _motherEducation,
            options: const ['No formal education', 'Primary', 'Secondary', 'Higher secondary', 'Graduate and above'],
            onChanged: (value) => setState(() => _motherEducation = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Father's literacy
          _buildFieldWithOptions(
            label: 'Father can read and write',
            selectedValue: _fatherLiteracy,
            options: const ['Yes', 'No', 'Not applicable'],
            onChanged: (value) => setState(() => _fatherLiteracy = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Mother's anaemia
          _buildFieldWithOptions(
            label: 'Mother has anaemia',
            selectedValue: _motherAnaemia,
            options: const ['Yes', 'No', 'Don\'t know'],
            onChanged: (value) => setState(() => _motherAnaemia = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Mother's occupation
          _buildFieldWithOptions(
            label: 'Mother\'s primary occupation',
            selectedValue: _motherOccupation,
            options: const ['Homemaker', 'Agriculture', 'Daily wage labour', 'Small business', 'Government job', 'Private job', 'Other'],
            onChanged: (value) => setState(() => _motherOccupation = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Decision making
          _buildFieldWithOptions(
            label: 'Who makes decisions about child\'s food and health?',
            selectedValue: _decisionMaking,
            options: const ['Mother', 'Father', 'Both parents', 'Grandmother', 'Other family member'],
            onChanged: (value) => setState(() => _decisionMaking = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Cooking fuel
          _buildFieldWithOptions(
            label: 'Type of cooking fuel mainly used',
            selectedValue: _cookingFuel,
            options: const ['LPG/Gas', 'Electricity', 'Kerosene', 'Coal/charcoal', 'Wood', 'Other'],
            onChanged: (value) => setState(() => _cookingFuel = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Sanitation facility
          _buildFieldWithOptions(
            label: 'Sanitation facility (toilet) access',
            selectedValue: _sanitationFacility,
            options: const ['Yes, with water inside', 'Yes, but water outside', 'No toilet facility'],
            onChanged: (value) => setState(() => _sanitationFacility = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Drinking water source
          _buildFieldWithOptions(
            label: 'Main source of drinking water',
            selectedValue: _drinkingWater,
            options: const ['Piped water', 'Tube well/borehole', 'Protected well', 'Unprotected well', 'Surface water', 'Other'],
            onChanged: (value) => setState(() => _drinkingWater = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Handwashing facility
          _buildFieldWithOptions(
            label: 'Handwashing facility with soap and water',
            selectedValue: _handwashingFacility,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _handwashingFacility = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // BPL card
          _buildFieldWithOptions(
            label: 'BPL/ration card available',
            selectedValue: _bplCard,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _bplCard = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // PDS food grains
          _buildFieldWithOptions(
            label: 'Receives food grains from PDS as per norms',
            selectedValue: _pdsFood,
            options: const ['Yes', 'No', 'Sometimes'],
            onChanged: (value) => setState(() => _pdsFood = value),
            isRequired: true,
          ),
        ],
      ),
    );
  }
          _buildDropdown(
            'Area type',
            _areaType,
            ['Rural', 'Urban'],
            (value) => setState(() => _areaType = value),
          ),
          const SizedBox(height: 16),

          // Mother's education
          _buildDropdown(
            "Mother's educational attainment",
            _motherEducation,
            ['No formal schooling', 'Primary school (up to Class 5)', 'Upper primary (Class 6-8)', 'Secondary (Class 9-10)', 'Higher secondary (Class 11-12)', 'Graduate or above'],
            (value) => setState(() => _motherEducation = value),
          ),
          const SizedBox(height: 16),

          // Mother's anaemia status
          _buildDropdown(
            "Mother's anaemia status",
            _motherAnaemia,
            ['Not anaemic', 'Mild anaemia', 'Moderate anaemia', 'Severe anaemia', 'Not tested/Don\'t know'],
            (value) => setState(() => _motherAnaemia = value),
          ),
          const SizedBox(height: 16),

          // Mother's occupation
          _buildDropdown(
            "Mother's occupation",
            _motherOccupation,
            ['Homemaker', 'Agricultural labour', 'Non-agricultural labour', 'Salaried employment', 'Self-employed', 'Other'],
            (value) => setState(() => _motherOccupation = value),
          ),
          const SizedBox(height: 16),

          // Decision making
          _buildDropdown(
            'Who makes decisions in household?',
            _decisionMaking,
            ['Mother alone', 'Mother jointly with spouse/family', 'Spouse alone', 'Other family members', 'Mother does not participate'],
            (value) => setState(() => _decisionMaking = value),
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

          // Child's name
          _buildTextField(
            controller: _childNameController,
            label: "Child's name",
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Child ID
          _buildTextField(
            controller: _childIdController,
            label: "Child ID (optional)",
          ),
          const SizedBox(height: 20),

          // Date of birth
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: "Child's date of birth",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
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
                    border: Border.all(
                      color: _childDateOfBirth != null ? teal : Colors.grey.shade300,
                      width: _childDateOfBirth != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _childDateOfBirth != null ? teal : Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _childDateOfBirth != null
                            ? DateFormat('dd/MM/yyyy').format(_childDateOfBirth!)
                            : 'Select date of birth',
                        style: TextStyle(
                          color: _childDateOfBirth != null ? Colors.black87 : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Child's gender
          _buildFieldWithOptions(
            label: "Child's gender",
            selectedValue: _childGender,
            options: const ['Male', 'Female'],
            onChanged: (value) => setState(() => _childGender = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Birth order
          _buildFieldWithOptions(
            label: 'Birth order of child',
            selectedValue: _birthOrder,
            options: const ['1st child', '2nd child', '3rd child', '4th child or more'],
            onChanged: (value) => setState(() => _birthOrder = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Primary caregiver
          _buildFieldWithOptions(
            label: 'Who is the primary caregiver of the child?',
            selectedValue: _primaryCaregiver,
            options: const ['Mother', 'Father', 'Grandmother', 'Grandfather', 'Other relative', 'Non-relative'],
            onChanged: (value) => setState(() => _primaryCaregiver = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Caregiver time
          _buildFieldWithOptions(
            label: 'How much time does primary caregiver spend with child daily?',
            selectedValue: _caregiverTime,
            options: const ['Most of the day', 'Half day', 'Few hours', 'Very little time'],
            onChanged: (value) => setState(() => _caregiverTime = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Anganwadi enrollment
          _buildFieldWithOptions(
            label: 'Is child enrolled in Anganwadi Centre?',
            selectedValue: _anganwadiEnrolled,
            options: const ['Yes', 'No'],
            onChanged: (value) => setState(() => _anganwadiEnrolled = value),
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Guardian details
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
}
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _childDateOfBirth != null
                    ? DateFormat('dd/MM/yyyy').format(_childDateOfBirth!)
                    : 'Select date',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Child's gender
          _buildDropdown(
            "Child's gender",
            _childGender,
            ['Male', 'Female', 'Other'],
            (value) => setState(() => _childGender = value),
          ),
          const SizedBox(height: 16),

          // Guardian name
          TextFormField(
            controller: _guardianNameController,
            decoration: const InputDecoration(
              labelText: "Guardian's name",
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Guardian contact
          TextFormField(
            controller: _guardianContactController,
            decoration: const InputDecoration(
              labelText: "Guardian's contact",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Birth order
          _buildDropdown(
            'Birth order of child',
            _birthOrder,
            ['1st', '2nd', '3rd or higher'],
            (value) => setState(() => _birthOrder = value),
          ),
          const SizedBox(height: 16),

          // Primary caregiver
          _buildDropdown(
            'Primary caregiver during day',
            _primaryCaregiver,
            ['Father', 'Grandmother/grandfather', 'Other adult family member', 'Older sibling', 'Neighbour/childcare provider', 'Anganwadi worker/centre', 'Other'],
            (value) => setState(() => _primaryCaregiver = value),
          ),
          const SizedBox(height: 16),

          // Caregiver interaction time
          _buildDropdown(
            'Daily interaction time with caregiver',
            _caregiverTime,
            ['Less than 15 minutes', '15-30 minutes', 'More than 30 minutes'],
            (value) => setState(() => _caregiverTime = value),
          ),
          const SizedBox(height: 16),

          // Anganwadi enrollment
          _buildDropdown(
            'Child enrolled in Anganwadi Centre?',
            _anganwadiEnrolled,
            ['Yes', 'No', "Don't know"],
            (value) => setState(() => _anganwadiEnrolled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
      isExpanded: true,
    );
  }
}