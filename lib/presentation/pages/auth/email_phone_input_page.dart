// lib/presentation/pages/auth/email_phone_input_page.dart
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/validators.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';

class EmailPhoneInputPage extends StatefulWidget {
  const EmailPhoneInputPage({Key? key}) : super(key: key);

  @override
  State<EmailPhoneInputPage> createState() => _EmailPhoneInputPageState();
}

class _EmailPhoneInputPageState extends State<EmailPhoneInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();

  // Default country code
  String _selectedCountryCode = '+1';
  String _selectedCountryDialCode = '+1';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber =>
      '$_selectedCountryDialCode${_phoneController.text.trim()}';

  void _checkExistence() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthCheckExistenceEvent(
              emailOrPhone: _fullPhoneNumber,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(
        title: '',
        backgroundColor: Colors.black,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthExistenceChecked) {
            Navigator.of(context).pushNamed(
              RouteNames.passwordInput,
              arguments: {
                'phone_number': _fullPhoneNumber,
                'isExistingUser': state.result.exists,
              },
            );
          } else if (state is AuthError) {
            SnackbarUtils.showOverlaySnackbar(
              context,
              state.message,
              SnackbarType.error,
            );
          } else if (state is AuthNetworkError) {
            SnackbarUtils.showOverlaySnackbar(
              context,
              state.message,
              SnackbarType.error,
            );
          }
        },
        child: SafeArea(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    height: 60,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Add Your Phone Number',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Link your phone number to connect with your friends who also use this app',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Phone Number Input with Country Picker
                  _buildPhoneInputField(theme),

                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthError || state is AuthNetworkError) {
                        return Text('Try again');
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Next',
                        backgroundColor: Colors.white,
                        fontSize: 16,
                        textColor: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _checkExistence,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Country Code Picker
          CountryCodePicker(
            onChanged: (CountryCode countryCode) {
              setState(() {
                _selectedCountryCode = countryCode.code!;
                _selectedCountryDialCode = countryCode.dialCode!;
              });
            },
            initialSelection: 'US',
            flagWidth: 24,
            favorite: const ['+1', 'US', '+98', 'IR'],
            showCountryOnly: true,
            showOnlyCountryWhenClosed: false,
            showFlagMain: false,
            alignLeft: false,
            textStyle: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 14,
            ),
            dialogTextStyle: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
            ),
            searchStyle: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
            ),
            dialogBackgroundColor: theme.scaffoldBackgroundColor,
            barrierColor: Colors.black54,
            backgroundColor: theme.scaffoldBackgroundColor,
            boxDecoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Vertical Divider
          // Container(
          //   height: 30,
          //   width: 1,
          //   color: theme.dividerColor.withOpacity(0.3),
          // ),

          // Phone Number Input
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15), // Max phone number length
              ],
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) => Validators.validatePhoneNumber(value),
              onFieldSubmitted: (_) => _checkExistence(),
            ),
          ),
        ],
      ),
    );
  }
}
