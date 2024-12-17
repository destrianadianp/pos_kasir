import '../../models/user.dart';

abstract class AuthenticationState {
  const AuthenticationState();

  List<Object> get props => [];
}

class AuthenticationInitialState extends AuthenticationState {}

class AuthenticationLoadingState extends AuthenticationState {
  final bool isLoading;

  AuthenticationLoadingState({required this.isLoading});
}

class AuthenticationSuccessState extends AuthenticationState {
  final UserModel user;

  const AuthenticationSuccessState(this.user);

  @override
  List<Object> get props => [user];
}

class AuthenticationFailureState extends AuthenticationState {
  final String errorMessage;

  const AuthenticationFailureState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class UserProductsLoadedState extends AuthenticationState {
  final List<Map<String, dynamic>> products;

  const UserProductsLoadedState(this.products);

  @override
  List<Object> get props => [products];
}

class UserTransactionsLoadedState extends AuthenticationState {
  final List<Map<String, dynamic>> transactions;

  const UserTransactionsLoadedState(this.transactions);

  @override
  List<Object> get props => [transactions];
}

