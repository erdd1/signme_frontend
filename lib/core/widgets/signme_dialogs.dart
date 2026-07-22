import 'package:flutter/material.dart';
import '../design_system/index.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// Action button configuration for dialogs
class SignmeAlertAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;

  const SignmeAlertAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// Generic alert dialog with customizable actions
class SignmeAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<SignmeAlertAction> actions;
  final IconData? icon;
  final Color? iconColor;

  const SignmeAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      backgroundColor: SignmeColors.surface,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(SignmeSpacing.lg),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon (if provided)
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(bottom: SignmeSpacing.md),
                  child: Icon(
                    icon,
                    size: SignmeSpacing.iconXl,
                    color: iconColor ?? SignmeColors.primary,
                  ),
                ),

              // Title
              Text(
                title,
                style: SignmeTypography.headlineMedium.copyWith(
                  color: SignmeColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: SignmeSpacing.md),

              // Message
              Text(
                message,
                style: SignmeTypography.bodyMedium.copyWith(
                  color: SignmeColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: SignmeSpacing.lg),

              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  actions.length,
                  (index) {
                    final action = actions[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < actions.length - 1 ? SignmeSpacing.sm : 0,
                      ),
                      child: _buildActionButton(action),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(SignmeAlertAction action) {
    if (action.isDestructive) {
      return SignmeSecondaryButton(
        label: action.label,
        onPressed: action.onPressed,
        color: SignmeColors.error,
      );
    }

    if (action.isDefault) {
      return SignmePrimaryButton(
        label: action.label,
        onPressed: action.onPressed,
      );
    }

    return SignmeSecondaryButton(
      label: action.label,
      onPressed: action.onPressed,
    );
  }
}

/// Confirmation dialog (Yes/No)
class SignmeConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final bool isDangerous;

  const SignmeConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.icon,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return SignmeAlertDialog(
      title: title,
      message: message,
      icon: icon,
      iconColor: isDangerous ? SignmeColors.error : SignmeColors.primary,
      actions: [
        SignmeAlertAction(
          label: cancelLabel,
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
        ),
        SignmeAlertAction(
          label: confirmLabel,
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          isDestructive: isDangerous,
          isDefault: true,
        ),
      ],
    );
  }
}

/// Loading dialog with spinner
class SignmeLoadingDialog extends StatelessWidget {
  final String message;
  final bool barrierDismissible;

  const SignmeLoadingDialog({
    super.key,
    this.message = 'Loading...',
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        ),
        backgroundColor: SignmeColors.surface,
        child: Container(
          padding: EdgeInsets.all(SignmeSpacing.lg),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: SignmeSpacing.iconXl,
                height: SignmeSpacing.iconXl,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SignmeColors.primary),
                ),
              ),
              const SizedBox(height: SignmeSpacing.lg),
              Text(
                message,
                style: SignmeTypography.bodyMedium.copyWith(
                  color: SignmeColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input dialog for text input
class SignmeInputDialog extends StatefulWidget {
  final String title;
  final String message;
  final String hint;
  final String submitLabel;
  final String cancelLabel;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;
  final String? initialValue;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const SignmeInputDialog({
    super.key,
    required this.title,
    required this.message,
    required this.hint,
    required this.onSubmit,
    this.submitLabel = 'Submit',
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  State<SignmeInputDialog> createState() => _SignmeInputDialogState();
}

class _SignmeInputDialogState extends State<SignmeInputDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.validator?.call(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.of(context).pop(_controller.text);
    widget.onSubmit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      backgroundColor: SignmeColors.surface,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(SignmeSpacing.lg),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.title,
                style: SignmeTypography.headlineMedium.copyWith(
                  color: SignmeColors.onSurface,
                ),
              ),

              SizedBox(height: SignmeSpacing.sm),

              // Message
              Text(
                widget.message,
                style: SignmeTypography.bodyMedium.copyWith(
                  color: SignmeColors.textSecondary,
                ),
              ),

              SizedBox(height: SignmeSpacing.lg),

              // Input field
              SignmeTextInput(
                label: widget.hint,
                hint: widget.hint,
                controller: _controller,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                errorText: _error,
                onChanged: (_) {
                  setState(() => _error = null);
                },
              ),

              SizedBox(height: SignmeSpacing.lg),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: SignmeSecondaryButton(
                      label: widget.cancelLabel,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onCancel?.call();
                      },
                    ),
                  ),
                  SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: SignmePrimaryButton(
                      label: widget.submitLabel,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show alert dialog
Future<void> showSignmeAlert(
  BuildContext context, {
  required String title,
  required String message,
  required List<SignmeAlertAction> actions,
  IconData? icon,
  Color? iconColor,
  bool barrierDismissible = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => SignmeAlertDialog(
      title: title,
      message: message,
      actions: actions,
      icon: icon,
      iconColor: iconColor,
    ),
  );
}

/// Helper function to show confirmation dialog
Future<bool?> showSignmeConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  IconData? icon,
  bool isDangerous = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SignmeConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: icon,
      isDangerous: isDangerous,
    ),
  );
}

/// Helper function to show loading dialog
Future<T?> showSignmeLoadingDialog<T>(
  BuildContext context, {
  String message = 'Loading...',
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => SignmeLoadingDialog(
      message: message,
      barrierDismissible: barrierDismissible,
    ),
  );
}

/// Helper function to show input dialog
Future<String?> showSignmeInputDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String hint,
  String submitLabel = 'Submit',
  String cancelLabel = 'Cancel',
  required ValueChanged<String> onSubmit,
  VoidCallback? onCancel,
  String? initialValue,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SignmeInputDialog(
      title: title,
      message: message,
      hint: hint,
      submitLabel: submitLabel,
      cancelLabel: cancelLabel,
      onSubmit: onSubmit,
      onCancel: onCancel,
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    ),
  );
}
