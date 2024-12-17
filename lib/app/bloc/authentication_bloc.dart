import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';
import '../../services/authentication.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthService authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<AuthenticationEvent>((event, emit) {});

    // Handle user sign up
    on<SignUpUser>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {
        final UserModel? user = await authService.signUpUser(
          event.userName,
          event.email,
          event.password,
        );
        if (user != null) {
          emit(AuthenticationSuccessState(user));
        } else {
          emit(const AuthenticationFailureState('Failed to create user'));
        }
      } catch (e) {
        emit(AuthenticationFailureState(e.toString()));
      } finally {
        emit(AuthenticationLoadingState(isLoading: false));
      }
    });

    // Handle user login
    on<LoginUser>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {
        final UserModel? user = await authService.loginUser(
          event.email,
          event.password,
        );
        if (user != null) {
          emit(AuthenticationSuccessState(user));
        } else {
          emit(const AuthenticationFailureState('Login failed'));
        }
      } catch (e) {
        emit(AuthenticationFailureState(e.toString()));
      } finally {
        emit(AuthenticationLoadingState(isLoading: false));
      }
    });

    // Handle profile update
    on<EditProfile>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {
        final User? firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          final bool success = await authService.editProfile(
            firebaseUser.uid,
            event.userName,
            event.email,
          );
          if (success) {
            final UserModel updatedUser = UserModel(
              id: firebaseUser.uid,
              email: event.email,
              userName: event.userName,
            );
            emit(AuthenticationSuccessState(updatedUser));
          } else {
            emit(const AuthenticationFailureState('Failed to update profile'));
          }
        } else {
          emit(const AuthenticationFailureState('No user is signed in'));
        }
      } catch (e) {
        emit(AuthenticationFailureState(e.toString()));
      } finally {
        emit(AuthenticationLoadingState(isLoading: false));
      }
    });

    // Handle user logout
    on<SignOut>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {
        await authService.signOutUser();
        emit(AuthenticationInitialState());
      } catch (e) {
        emit(AuthenticationFailureState(e.toString()));
      } finally {
        emit(AuthenticationLoadingState(isLoading: false));
      }
    });

    on<FetchUserProducts>((event, emit) async {
  emit(AuthenticationLoadingState(isLoading: true));
  try {
    final products = await authService.fetchUserProducts(event.userId);
    emit(UserProductsLoadedState(products));
  } catch (e) {
    emit(AuthenticationFailureState(e.toString()));
  } finally {
    emit(AuthenticationLoadingState(isLoading: false));
  }
});

on<FetchUserTransactions>((event, emit) async {
  emit(AuthenticationLoadingState(isLoading: true));
  try {
    final transactions = await authService.fetchUserTransactions(event.userId);
    emit(UserTransactionsLoadedState(transactions));
  } catch (e) {
    emit(AuthenticationFailureState(e.toString()));
  } finally {
    emit(AuthenticationLoadingState(isLoading: false));
  }
});

  }
}


