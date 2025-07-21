import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  StreamSubscription? _userSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUser>(_onGetCurrentUser);

    // Start listening to user stream
    add(const AuthEvent.getCurrentUser());
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    // Implement register logic similar to login
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    // Implement logout logic
    emit(const AuthState.unauthenticated());
  }

  void _onGetCurrentUser(
    GetCurrentUser event,
    Emitter<AuthState> emit,
  ) {
    _userSubscription?.cancel();
    _userSubscription = getCurrentUserUseCase(const NoParams()).listen(
      (result) {
        result.fold(
          (failure) => emit(AuthState.error(message: failure.message)),
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

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}