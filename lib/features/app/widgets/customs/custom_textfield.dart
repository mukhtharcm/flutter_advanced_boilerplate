import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_boilerplate/i18n/strings.g.dart';
import 'package:flutter_advanced_boilerplate/utils/constants.dart';
import 'package:flutter_advanced_boilerplate/utils/methods/shortcuts.dart';
import 'package:flutter_advanced_boilerplate/utils/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:styled_text/styled_text.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.formControlName,
    this.validationMessages,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.hasCounter = false,
    this.hintText = '',
    this.labelText = '',
    this.extraInfo = '',
    this.maxLines = 1,
    this.minLines,
    this.minLength,
    this.maxLength,
    this.isRequired = false,
    this.inputFormatters,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.staticValue = '',
    this.showErrors = true,
    this.obscureText = false,
  }) : assert(
          !hasCounter || maxLength != null,
          'Max length must be provided when counter is active.',
        );

  final Map<String, String> Function(FormControl<Object?>)? validationMessages;
  final String extraInfo;
  final String formControlName;
  final bool hasCounter;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String labelText;
  final int? maxLength;
  final int? maxLines;
  final int? minLength;
  final int? minLines;
  final void Function(FormControl<Object?>)? onTap;
  final bool readOnly;
  final bool showErrors;
  final String staticValue;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final bool obscureText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late Color _textFieldBackground;

  @override
  void didChangeDependencies() {
    _textFieldBackground = getCustomOnPrimaryColor(context).withOpacity(0.05);
    super.didChangeDependencies();
  }

  void onFocusChange({required bool focus}) {
    setState(() {
      _textFieldBackground = focus
          ? getCustomOnPrimaryColor(context).withOpacity(0.1)
          : getCustomOnPrimaryColor(context).withOpacity(0.05);
    });
  }

  InputDecoration getTextFieldDecoration(FormGroup form) {
    return InputDecoration(
      disabledBorder: const UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Constants.defaultBorderRadius)),
        borderSide: BorderSide(
          style: BorderStyle.none,
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Constants.defaultBorderRadius)),
        borderSide: BorderSide(
          style: BorderStyle.none,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(Constants.defaultBorderRadius)),
        borderSide: BorderSide(
          color: Palette.red.withOpacity(0.3),
          width: 4,
        ),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(Constants.defaultBorderRadius)),
        borderSide: BorderSide(
          color: Palette.red.withOpacity(0.3),
          width: 4,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(Constants.defaultBorderRadius)),
        borderSide: BorderSide(
          color: widget.isRequired && form.control(widget.formControlName).valid
              ? Palette.green.withOpacity(0.5)
              : Colors.transparent,
          width: 4,
        ),
      ),
      filled: true,
      errorMaxLines: 2,
      fillColor: _textFieldBackground,
      suffixIcon: widget.suffixIcon,
      suffixIconConstraints: const BoxConstraints(
        maxHeight: 50,
        maxWidth: 50,
      ),
      hintText: widget.hintText,
      labelText: widget.labelText,
      contentPadding: widget.labelText.isNotEmpty
          ? const EdgeInsets.fromLTRB(
              Constants.paddingL,
              Constants.paddingS - 2,
              Constants.paddingXXL,
              Constants.paddingS - 2,
            )
          : null,
    );
  }

  Widget? buildCounter(
    BuildContext context, {
    required int currentLength,
    int? maxLength,
  }) {
    return !widget.hasCounter
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.symmetric(
              vertical: 1.5,
              horizontal: 4,
            ),
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(color: getCustomOnPrimaryColor(context).withOpacity(0.2)),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(32)),
            ),
            child: StyledText(
              text: '<bold>$currentLength</bold>/$maxLength',
              style: getTextTheme(context).caption,
              tags: {
                'bold': StyledTextTag(
                  style: getTextTheme(context).caption!.apply(
                        fontWeightDelta: 1,
                        color: widget.minLength != null && currentLength < widget.minLength!
                            ? Palette.red.withOpacity(0.5)
                            : getTheme(context).primary,
                      ),
                ),
              },
            ),
          );
  }

  IconData getIcon(FormGroup form) {
    if (form.status != ControlStatus.disabled && !form.control(widget.formControlName).valid) {
      return MdiIcons.asterisk;
    }

    return MdiIcons.check;
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        return Focus(
          onFocusChange: (focusStatus) => onFocusChange(focus: focusStatus),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: Constants.paddingXS),
                child: Column(
                  children: [
                    ReactiveTextField(
                      showErrors: widget.showErrors ? null : (_) => false,
                      controller:
                          widget.staticValue.isNotEmpty ? TextEditingController(text: widget.staticValue) : null,
                      readOnly: widget.readOnly,
                      obscureText: widget.obscureText,
                      onTap: widget.onTap,
                      formControlName: widget.formControlName,
                      validationMessages: {
                        ValidationMessage.minLength: (_) => Translations.of(context)
                            .core
                            .errors
                            .form
                            .minLength(field: widget.labelText, count: widget.minLength.toString()),
                        ValidationMessage.maxLength: (_) => Translations.of(context)
                            .core
                            .errors
                            .form
                            .maxLength(field: widget.labelText, count: widget.maxLength.toString()),
                        ValidationMessage.required: (_) => context.t.core.errors.form.required(field: widget.labelText),
                        ValidationMessage.email: (_) => context.t.core.errors.form.email,
                      },
                      maxLength: widget.maxLength,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      keyboardType: widget.keyboardType,
                      textCapitalization: widget.textCapitalization,
                      buildCounter: (context, {required int currentLength, required bool isFocused, int? maxLength}) {
                        return buildCounter(context, currentLength: currentLength, maxLength: maxLength);
                      },
                      decoration: getTextFieldDecoration(form),
                      inputFormatters: widget.inputFormatters,
                    ),
                    if (widget.extraInfo.isNotEmpty) ...{
                      Padding(
                        padding: const EdgeInsets.only(
                          left: Constants.paddingXS,
                          top: Constants.paddingS / 2,
                          bottom: Constants.paddingS / 2,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              MdiIcons.information,
                              size: 16,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  widget.extraInfo,
                                  style: getTextTheme(context).caption!.copyWith(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                  ],
                ),
              ),
              if (widget.isRequired) ...{
                Positioned(
                  right: Constants.paddingM,
                  top: Constants.paddingXL,
                  child: Icon(
                    getIcon(form),
                    size: 14,
                    color: getCustomOnPrimaryColor(context),
                  ),
                ),
              },
            ],
          ),
        );
      },
    );
  }
}
