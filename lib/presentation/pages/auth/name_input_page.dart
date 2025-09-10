// lib/presentation/pages/auth/name_input_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/permission_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/custom_text_field.dart';

class NameInputPage extends StatefulWidget {
  final String emailOrPhone;
  final String password;

  const NameInputPage({
    Key? key,
    required this.emailOrPhone,
    required this.password,
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
      context.read<AuthBloc>().add(
            AuthRegisterEvent(
              emailOrPhone: widget.emailOrPhone,
              password: widget.password,
              username: _nameController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: '', backgroundColor: Colors.black),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthRegistrationSuccess) {
            try {
              final navigationType =
                  await PermissionUtils.getRequiredPermissionNavigation();

              final arguments = {
                'name': _nameController.text.trim(),
                'phone_number': widget.emailOrPhone,
              };

              switch (navigationType) {
                case PermissionNavigationType.mainScreen:
                  Navigator.of(context).pushReplacementNamed(
                    RouteNames.main, // Replace with your main screen route
                    arguments: arguments,
                  );
                  break;
                case PermissionNavigationType.systemAlertWindow:
                  Navigator.of(context).pushNamed(
                    RouteNames.systemAlertWindowPermission,
                    arguments: arguments,
                  );
                  break;
                case PermissionNavigationType.notification:
                  Navigator.of(context).pushReplacementNamed(
                    RouteNames.notificationPermission,
                    arguments: arguments,
                  );
                  break;
              }
            } catch (e) {
              Navigator.of(context).pushNamed(
                RouteNames.systemAlertWindowPermission,
                arguments: {
                  'name': _nameController.text.trim(),
                  'phone_number': widget.emailOrPhone,
                },
              );
            }
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
                    'Enter your name',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    textAlign: TextAlign.center,
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
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Icon(Icons.alternate_email),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // BlocBuilder<AuthBloc, AuthState>(
                  //   builder: (context, state) {
                  //     if (state is AuthError) {
                  //       SnackbarUtils.showOverlaySnackbar(
                  //         context,
                  //         state.message,
                  //         SnackbarType.error,
                  //       );
                  //     }
                  //     return const SizedBox.shrink();
                  //   },
                  // ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Next',
                        backgroundColor: Colors.white,
                        fontSize: 16,
                        textColor: Colors.black,
                        borderRadius: BorderRadius.circular(12),
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
