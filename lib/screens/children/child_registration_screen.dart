import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/child_service.dart';
import '../../utils/constants.dart';
import '../visits/baseline_visit_screen.dart';

class ChildRegistrationScreen extends StatefulWidget {
  const ChildRegistrationScreen({super.key});

  @override
  State<ChildRegistrationScreen> createState() => _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Essential fields only
  final _childNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianContactController = TextEditingController();
  DateTime? _childDateOfBirth;
  String? _childGender;

  bool _isLoading = false;

  @override
  void dispose() {
    _childNameController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    super.dispose();
  }

  Future<void> _registerChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_childDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select child\'s date of birth')),
      );
      return;
    }

    if (_childGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select child\'s gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the child service that already works
      final childId = await ChildService.I.createChildLocal(
        projectId: Constants.projectDocId,
        name: _childNameController.text.trim(),
        dob: _childDateOfBirth!,
        gender: _childGender!.toLowerCase(),
        guardianName: _guardianNameController.text.trim(),
        guardianContact: _guardianContactController.text.trim(),
      );

      if (mounted) {
        // Navigate directly to baseline questions - use a dummy visit id for now
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BaselineVisitScreen(
              childId: childId,
              visitId: 'baseline_${DateTime.now().millisecondsSinceEpoch}',
              projectId: Constants.projectDocId,
              childName: _childNameController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register Child'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter basic child information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Child's name
              _buildTextField(
                controller: _childNameController,
                label: "Child's name",
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Child name is required';
                  }
                  return null;
                },
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

              // Gender
              _buildFieldWithOptions(
                label: "Child's gender",
                selectedValue: _childGender,
                options: const ['Male', 'Female'],
                onChanged: (value) => setState(() => _childGender = value),
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // Guardian name
              _buildTextField(
                controller: _guardianNameController,
                label: 'Guardian/Parent name',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Guardian name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Guardian contact
              _buildTextField(
                controller: _guardianContactController,
                label: 'Contact number',
                keyboardType: TextInputType.phone,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contact number is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Enter a valid contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register Child',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
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
          spacing: 12,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}