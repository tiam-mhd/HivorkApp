import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyPhoneUseCase verifyPhoneUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyPhoneUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.isLoggedInUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyPhoneEvent>(_onVerifyPhone);
    on<LogoutEvent>(_onLogout);
    on<GetProfileEvent>(_onGetProfile);
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await sendOtpUseCase(event.phone);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) {
        emit(AuthOtpSent(
          phone: event.phone,
          exists: data['exists'] as bool,
        ));
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {    
    final result = await isLoggedInUseCase();
    
    await result.fold(
      (failure) async {
        emit(AuthUnauthenticated());
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final profileResult = await getProfileUseCase();
          profileResult.fold(
            (failure) {
              emit(AuthUnauthenticated());
            },
            (user) {
              emit(AuthAuthenticated(user));
            },
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      phone: event.phone,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) {
        if (authResponse.user.phoneVerified) {
          emit(AuthAuthenticated(authResponse.user));
        } else {
          emit(AuthPhoneVerificationRequired(
            phone: authResponse.user.phone,
            user: authResponse.user,
          ));
        }
      },
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await registerUseCase(
      fullName: event.fullName,
      phone: event.phone,
      password: event.password,
      email: event.email,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) => emit(AuthRegistrationSuccess(authResponse.user)),
    );
  }

  Future<void> _onVerifyPhone(
    VerifyPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await verifyPhoneUseCase(
      phone: event.phone,
      verificationCode: event.verificationCode,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) {
        final user = data['user'] as User;
        final exists = data['exists'] as bool;
        
        if (exists) {
          // کاربر قبلاً ثبت‌نام کرده - باید رمز بزنه
          emit(AuthPhoneVerificationRequired(
            phone: event.phone,
            user: user,
          ));
        } else {
          // کاربر جدید - باید ثبت‌نام کنه
          emit(AuthPhoneVerified(
            phone: event.phone,
            user: user,
          ));
        }
      },
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await logoutUseCase();
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getProfileUseCase();
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}