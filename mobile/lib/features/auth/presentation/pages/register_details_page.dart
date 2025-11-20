import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_header.dart';

class RegisterDetailsPage extends StatefulWidget {
  final String phone;

  const RegisterDetailsPage({super.key, required this.phone});

  @override
  State<RegisterDetailsPage> createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          phone: widget.phone,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/images/branding/Logo.png',
          height: 28,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.onSurface),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.onError),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is AuthRegistrationSuccess) {
            // ثبت‌نام موفق - انتقال به داشبورد (OTP قبلاً تایید شده)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('ثبت‌نام با موفقیت انجام شد')),
                  ],
                ),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
            // انتقال به داشبورد
            Future.delayed(const Duration(milliseconds: 500), () {
              context.go('/dashboard');
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header
                const AuthHeader(
                  title: 'ثبت‌نام',
                  subtitle: 'لطفا اطلاعات خود را وارد کنید',
                ),

                const SizedBox(height: 16),

                // Phone Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.phone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Register Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      CustomTextField(
                        controller: _fullNameController,
                        label: 'نام و نام خانوادگی',
                        hint: 'نام کامل خود را وارد کنید',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'نام و نام خانوادگی الزامی است';
                          }
                          if (value.trim().length < 3) {
                            return 'نام و نام خانوادگی باید حداقل ۳ کاراکتر باشد';
                          }
                          return null;
                        },
                        prefixIcon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      // Email (optional)
                      CustomTextField(
                        controller: _emailController,
                        label: 'ایمیل (اختیاری)',
                        hint: 'ایمیل خود را وارد کنید',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            return Validators.validateEmail(value);
                          }
                          return null;
                        },
                        prefixIcon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        label: 'رمز عبور',
                        hint: 'رمز عبور خود را وارد کنید',
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'تکرار رمز عبور',
                        hint: 'رمز عبور خود را مجدداً وارد کنید',
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'رمز عبور و تکرار آن یکسان نیست';
                          }
                          return null;
                        },
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: 'ثبت‌نام',
                            onPressed: _register,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
