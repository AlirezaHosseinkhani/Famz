import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_widget.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPhoneNumber() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushNamed(
        RouteNames.otpVerification,
        arguments: {
          'phoneNumber': _phoneController.text,
          'isNewUser': false,
        },
      );
    }
  }

  void _navigateToRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushNamed(
        RouteNames.registerOtpVerification,
        arguments: {
          'phoneNumber': _phoneController.text,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Phone Verification'),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthVerificationCodeSent) {
            Navigator.of(context).pushNamed(
              RouteNames.otpVerification,
              arguments: {
                'phoneNumber': state.phoneNumber,
                'isNewUser': false,
              },
            );
          } else if (state is AuthLogin) {
            Navigator.of(context).pushNamed(RouteNames.main);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Add Email or Phone Number',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Link your phone number to connect with your friends who also use this app',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Email or Phone Number',
                    hint: 'Enter a valid Email / Phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.text,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // You can add a flag icon here
                          const Icon(Icons.flag),
                          // const SizedBox(width: 8),
                          // const Text('+1650'),
                        ],
                      ),
                    ),
                    validator: Validators.validateEmailOrPhone,
                    onSubmitted: (_) => _submitPhoneNumber(),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthError || state is AuthNetworkError) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomErrorWidget(
                            message: state is AuthError
                                ? state.message
                                : (state as AuthNetworkError).message,
                            onRetry: _submitPhoneNumber,
                            retryText: 'Retry',
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          // Login/Next Button
                          CustomButton(
                            text: 'Login',
                            onPressed: _submitPhoneNumber,
                            isLoading: state is AuthLoading,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Register',
                            onPressed: _navigateToRegister,
                            isLoading: state is AuthLoading,
                          ),
                          const SizedBox(height: 16),
                          // Register Button
                          // SizedBox(
                          //   width: double.infinity,
                          //   height: 50,
                          //   child: OutlinedButton(
                          //     onPressed: _navigateToRegister,
                          //     style: OutlinedButton.styleFrom(
                          //       side: BorderSide(color: theme.primaryColor),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //     child: Text(
                          //       'Register',
                          //       style: TextStyle(
                          //         color: theme.primaryColor,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
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
}
