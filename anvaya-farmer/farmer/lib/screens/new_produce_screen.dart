import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/inference_result.dart';
import '../theme/app_theme.dart';
import 'produce_verification_screen.dart';

class NewProduceScreen extends StatefulWidget {
  final String? initialCropName;
  final String? initialCategory;
  final String? initialDescription;
  final Uint8List? initialImageBytes;
  final InferenceResult? inferenceResult;

  const NewProduceScreen({
    super.key,
    this.initialCropName,
    this.initialCategory,
    this.initialDescription,
    this.initialImageBytes,
    this.inferenceResult,
  });

  @override
  State<NewProduceScreen> createState() => _NewProduceScreenState();
}

class _NewProduceScreenState extends State<NewProduceScreen> {
  late TextEditingController _cropNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  String? _selectedCategory;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _cropNameController =
        TextEditingController(text: widget.initialCropName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _priceController = TextEditingController(text: '4.50');
    _dateController = TextEditingController(text: _formatCurrentDate());
    _locationController =
        TextEditingController(text: 'Green Valley Farm, Sector B');
    _selectedCategory = widget.initialCategory ?? 'Vegetables';
    _imageBytes = widget.initialImageBytes;
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  }

  void _getGPSLocation() {
    setState(() {
      _locationController.text = 'GPS: 12.9716° N, 77.5946° E (Verified)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Current GPS Location updated!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF102616),
      ),
    );
  }

  void _publishProduce() {
    if (_cropNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a crop name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131922),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: AppColors.primaryGreen),
            SizedBox(width: 10),
            Text('Produce Published!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Batch "${_cropNameController.text}" has been encrypted and published to the blockchain tracking ledger.',
          style: const TextStyle(color: Color(0xFFA0AEC0)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAIVerified = widget.initialCropName != null ||
        widget.inferenceResult != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131922),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Column(
          children: [
            const Text(
              'New Produce',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 20,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFF2A2E33),
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFF2A2E33),
                        borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 24.0, bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAIVerified)
                  _buildAIVerificationBanner()
                else
                  _buildScanAIShortcut(),

                _buildLabel('CROP NAME'),
                _buildTextField(
                  controller: _cropNameController,
                  hintText: 'e.g., Organic Arabica Coffee',
                  prefixIcon: Icons.eco,
                ),
                const SizedBox(height: 20),

                _buildLabel('DESCRIPTION'),
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'Describe your produce...',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('PRICE (\$)'),
                          _buildTextField(
                            controller: _priceController,
                            hintText: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CATEGORY'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131922),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                dropdownColor: const Color(0xFF131922),
                                hint: const Text('Select',
                                    style: TextStyle(color: Color(0xFF4A5568))),
                                value: _selectedCategory,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF4A5568)),
                                items: [
                                  'Fruits',
                                  'Vegetables',
                                  'Grains',
                                  'Coffee'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('PRODUCTION DATE'),
                _buildTextField(
                  controller: _dateController,
                  hintText: 'mm/dd/yyyy',
                  prefixIcon: Icons.calendar_month,
                ),
                const SizedBox(height: 20),

                _buildLabel('FARM LOCATION'),
                _buildTextField(
                  controller: _locationController,
                  hintText: 'location',
                  prefixIcon: Icons.push_pin,
                  iconColor: Colors.redAccent,
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _getGPSLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E3A24)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gps_fixed,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Get Current GPS',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('PRODUCT IMAGES'),
                Row(
                  children: [
                    if (_imageBytes != null)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProduceVerificationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131922),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF2A3644),
                              style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: AppColors.primaryGreen),
                            const SizedBox(height: 4),
                            Text(
                              _imageBytes != null ? 'Retake photo' : 'Add photo',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Upload up to 5 product images',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF102616),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E3A24)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security,
                          color: Color(0xFFA0AEC0), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Blockchain Verification',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This data will be encrypted and recorded on-chain for transparent supply chain tracking.',
                              style: TextStyle(
                                color: const Color(0xFF6B8775),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Publish Button fixed at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _publishProduce,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                ),
                child: const Text(
                  'Publish Produce',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIVerificationBanner() {
    final produceName = widget.initialCropName ?? 'Produce';
    final confidence = widget.inferenceResult?.confidencePercentage ?? 'Verified';
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2618),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ AI Verified: $produceName',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Auto-filled from Gemini Vision AI ($confidence)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAIShortcut() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProduceVerificationScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF131922),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3644)),
        ),
        child: const Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Produce with AI Camera',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    'Detect produce name & quality automatically',
                    style: TextStyle(color: Color(0xFF718096), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF718096),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? hintText,
    int maxLines = 1,
    IconData? prefixIcon,
    Color? iconColor,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF4A5568)),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: iconColor ?? AppColors.primaryGreen, size: 20)
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
