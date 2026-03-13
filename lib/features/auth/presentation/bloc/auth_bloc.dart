import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../../subscription/data/revenuecat_subscription_service.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignInWithAppleUseCase signInWithApple;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;

  StreamSubscription? _authSubscription;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(const AuthState.initial()) {
    on<AuthStartedEvent>(_onStarted);
    on<GoogleSignInRequestedEvent>(_onGoogleSignIn);
    on<AppleSignInRequestedEvent>(_onAppleSignIn);
    on<SignOutRequestedEvent>(_onSignOut);

    add(const AuthEvent.started());
  }

  void _onStarted(AuthStartedEvent event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = getCurrentUser(const NoParams()).listen(
      (result) {
        result.fold(
          (_) => emit(const AuthState.unauthenticated()),
          (user) {
            if (user != null) {
              emit(AuthState.authenticated(user: user));
            } else {
              emit(const AuthState.unauthenticated());
            }
          },
        );
      },
    );
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (user) {
        RevenueCatSubscriptionService.logIn(user.id).ignore();
        emit(AuthState.authenticated(user: user));
      },
    );
  }

  Future<void> _onAppleSignIn(
    AppleSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await signInWithApple(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (user) {
        RevenueCatSubscriptionService.logIn(user.id).ignore();
        emit(AuthState.authenticated(user: user));
      },
    );
  }

  Future<void> _onSignOut(
    SignOutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await signOut(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (_) {
        RevenueCatSubscriptionService.logOut().ignore();
        emit(const AuthState.unauthenticated());
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
