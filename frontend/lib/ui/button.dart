import 'package:flutter/material.dart';

class OutlineButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;
  final IconData? icon;
  final Color? textColor;
  final Color? bgColor;
  const OutlineButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.textColor,
    this.bgColor,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      foregroundColor: widget.textColor ?? Colors.white,
      backgroundColor: widget.bgColor ?? Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    if (widget.icon != null) {
      return OutlinedButton.icon(
        onPressed: _isLoading ? null : _handlePress,
        icon:
            _isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Icon(widget.icon),
        label: Text(widget.label, style: const TextStyle(fontSize: 18)),
        style: buttonStyle,
      );
    }

    return OutlinedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: buttonStyle,
      child:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(widget.label, style: const TextStyle(fontSize: 18)),
    );
  }
}
