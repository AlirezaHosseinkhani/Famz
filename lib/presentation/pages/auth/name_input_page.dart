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

class NameInputPage extends StatefulWidget {
  final String phoneNumber;
  final String otpCode;

  const NameInputPage({
    Key? key,
    required this.phoneNumber,
    required this.otpCode,
  }) : super(key: key);

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitName() {
    if (_formKey.currentState?.validate() ?? false) {
      // Trigger registration with API
      context.read<AuthBloc>().add(
            AuthRegisterEvent(
              phoneNumber: widget.phoneNumber,
              name: _nameController.text.trim(),
              otpCode: widget.otpCode,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            // Registration successful, navigate to welcome page
            Navigator.of(context).pushNamed(
              RouteNames.welcome,
              arguments: {
                'name': _nameController.text.trim(),
                'phoneNumber': widget.phoneNumber,
              },
            );
          } else if (state is AuthAuthenticated) {
            // Move navigation logic here from BlocBuilder
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.main,
                (route) => false,
              );
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is AuthNetworkError) {
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
                    'Enter your name',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The name you choose is what others see when you send or receive recording requests.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: '',
                    hint: 'Enter your name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Names cannot include numbers, symbols (e.g., @, #) or special characters';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      // Check for numbers and special characters
                      if (RegExp(r'[0-9@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return 'Names cannot include numbers, symbols (e.g., @, #) or special characters';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _submitName(),
                  ),
                  const SizedBox(height: 24),
                  // Wrap error widget in Flexible to prevent overflow
                  Flexible(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthError || state is AuthNetworkError) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CustomErrorWidget(
                              message: state is AuthError
                                  ? state.message
                                  : (state as AuthNetworkError).message,
                              onRetry: _submitName,
                              retryText: 'Retry',
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Next',
                        onPressed: _submitName,
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
