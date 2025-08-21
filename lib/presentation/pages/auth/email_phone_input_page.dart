// lib/presentation/pages/auth/email_phone_input_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EmailPhoneInputPage extends StatefulWidget {
  const EmailPhoneInputPage({Key? key}) : super(key: key);

  @override
  State<EmailPhoneInputPage> createState() => _EmailPhoneInputPageState();
}

class _EmailPhoneInputPageState extends State<EmailPhoneInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkExistence() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthCheckExistenceEvent(
                emailOrPhone: _emailPhoneController.text.trim()),
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
                'email': state.emailOrPhone,
                'isExistingUser': state.result.exists,
              },
            );
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
                    'Add Email or Phone Number',
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
                  CustomTextField(
                    label: 'Email or Phone Number',
                    hint: 'Enter a valid Email / Phone number',
                    controller: _emailPhoneController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Icon(Icons.alternate_email),
                    ),
                    validator: Validators.validateEmailOrPhone,
                    onSubmitted: (_) => _checkExistence(),
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
                        //     onRetry: _checkExistence,
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
}
