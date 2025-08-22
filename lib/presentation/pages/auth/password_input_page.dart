// lib/presentation/pages/auth/password_input_page.dart
import 'package:flutter/material.dart';
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
import '../../widgets/common/custom_text_field.dart';

class PasswordInputPage extends StatefulWidget {
  final String emailOrPhone;
  final bool isExistingUser;

  const PasswordInputPage({
    Key? key,
    required this.emailOrPhone,
    required this.isExistingUser,
  }) : super(key: key);

  @override
  State<PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.isExistingUser) {
        // Login existing user
        context.read<AuthBloc>().add(
              AuthLoginEvent(
                emailOrPhone: widget.emailOrPhone,
                password: _passwordController.text,
              ),
            );
      } else {
        // Navigate to name input for new user registration
        Navigator.of(context).pushNamed(
          RouteNames.nameInput,
          arguments: {
            'email': widget.emailOrPhone,
            'password': _passwordController.text,
          },
        );
      }
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
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.notificationPermission,
              (route) => false,
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
                    widget.isExistingUser ? 'Welcome back!' : 'Create password',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isExistingUser
                        ? 'Enter your password to continue'
                        : 'Create a secure password for your account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: widget.isExistingUser
                        ? Validators.validatePassword
                        : Validators.validateNewPassword,
                    onSubmitted: (_) => _submitPassword(),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthError || state is AuthNetworkError) {
                        // return Padding(
                        //   padding: const EdgeInsets.only(bottom: 16),
                        //   child: CustomErrorWidget(
                        //     message: state is AuthError
                        //         ? state.message
                        //         : (state as AuthNetworkError).message,
                        //     onRetry: _submitPassword,
                        //     retryText: 'Retry',
                        //   ),
                        // );
                        return Text('Try again');
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: widget.isExistingUser ? 'Login' : 'Continue',
                        backgroundColor: Colors.white,
                        fontSize: 16,
                        textColor: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _submitPassword,
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
