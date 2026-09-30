import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Real swipe-to-confirm slider widget.
/// The green circle drags horizontally within the pill and follows the finger.
/// Past ~80% of the track it completes and triggers [onConfirmed]; otherwise it springs back.
/// A tap does NOT navigate.
class SwipeToConfirmSlider extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String text;

  const SwipeToConfirmSlider({
    super.key,
    required this.onConfirmed,
    this.text = 'Get Started',
  });

  @override
  State<SwipeToConfirmSlider> createState() => _SwipeToConfirmSliderState();
}

class _SwipeToConfirmSliderState extends State<SwipeToConfirmSlider>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isCompleted = false;

  late AnimationController _springController;
  Animation<double>? _springAnimation;

  final double _knobSize = 52.0;
  final double _padding = 8.0;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _springController.addListener(() {
      if (_springAnimation != null) {
        setState(() {
          _dragOffset = _springAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _springBack() {
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutBack,
      ),
    );
    _springController.forward(from: 0.0);
  }

  void _completeDrag(double maxDrag) {
    setState(() => _isCompleted = true);
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: maxDrag,
    ).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutCubic,
      ),
    );
    _springController.forward(from: 0.0).then((_) {
      HapticFeedback.lightImpact();
      widget.onConfirmed();
      // Reset smoothly in case user returns to screen
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isCompleted = false;
            _dragOffset = 0.0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - _knobSize - (_padding * 2);
        final progress = maxDrag > 0 ? (_dragOffset / maxDrag).clamp(0.0, 1.0) : 0.0;
        final contentOpacity = (1.0 - (progress * 1.35)).clamp(0.0, 1.0);

        return Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF141715),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color(0xFF222724),
              width: 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Fading Center Text & Right Triple Chevron
              Opacity(
                opacity: contentOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 48), // space for knob
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      // Right Triple Chevron: >>>
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_right_rounded, color: Color(0x5594A3B8), size: 18),
                          Icon(Icons.chevron_right_rounded, color: Color(0x9994A3B8), size: 18),
                          Icon(Icons.chevron_right_rounded, color: Color(0xFFFFFFFF), size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Draggable Green Knob
              Positioned(
                left: _padding + _dragOffset,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    if (_isCompleted) return;
                    _springController.stop();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_isCompleted) return;
                    if (progress >= 0.80) {
                      _completeDrag(maxDrag);
                    } else {
                      _springBack();
                    }
                  },
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.45),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
