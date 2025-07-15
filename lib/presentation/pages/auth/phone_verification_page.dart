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
      final phoneNumber = Validators.validateEmail(_phoneController.text);
      Navigator.of(context).pushNamed(
        RouteNames.otpVerification,
        arguments: {
          'phoneNumber': _phoneController.text,
          'isNewUser': false,
        },
      );
      // context.read<AuthBloc>().add(AuthLoginEvent(phoneNumber: phoneNumber,pa));
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
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your phone number',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll send you a verification code to confirm your number',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.text,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.phone),
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.digitsOnly,
                    //   LengthLimitingTextInputFormatter(11),
                    // ],
                    validator: Validators.validateEmail,
                    onSubmitted: (_) => _submitPhoneNumber(),
                  ),
                  const SizedBox(height: 24),
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
                      return CustomButton(
                        text: 'Send Code',
                        onPressed: _submitPhoneNumber,
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
}
