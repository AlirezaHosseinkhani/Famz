import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.isNewUser,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _verifyOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      // if (widget.isNewUser) {
      //   Navigator.of(context).pushNamed(
      //     RouteNames.nameInput,
      //     arguments: {
      //       'phoneNumber': widget.phoneNumber,
      //       'otpCode': _otpController.text,
      //     },
      //   );
      // } else {
      context.read<AuthBloc>().add(
            AuthLoginEvent(
              phoneNumber: widget.phoneNumber,
              password: _otpController.text,
            ),
          );
      // }
    }
  }

  void _resendCode() {
    if (_canResend) {
      context.read<AuthBloc>().add(
            AuthSendVerificationCodeEvent(phoneNumber: widget.phoneNumber),
          );
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Verification'),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.notificationPermission,
              (route) => false,
            );
          } else if (state is AuthVerificationCodeSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification code sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
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
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter verification',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                      children: [
                        const TextSpan(
                          text: 'We sent a 6-digit code to ',
                        ),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter password',
                    controller: _otpController,
                    keyboardType: TextInputType.text,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    // maxLength: 6,
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.digitsOnly,
                    //   LengthLimitingTextInputFormatter(6),
                    // ],
                    // validator: Validators.validateOtp,
                    onChanged: (value) {
                      // if (value.length == 6) {
                      //   _verifyOtp();
                      // }
                    },
                    onSubmitted: (_) => _verifyOtp(),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: _canResend ? _resendCode : null,
                      child: Text(
                        _canResend
                            ? 'Resend Code'
                            : 'Resend in ${_resendCountdown}s',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _canResend
                              ? theme.primaryColor
                              : theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5),
                        ),
                      ),
                    ),
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
                            onRetry: _verifyOtp,
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
                        text: 'Verify',
                        onPressed: _verifyOtp,
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
