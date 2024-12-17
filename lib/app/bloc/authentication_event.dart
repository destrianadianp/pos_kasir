abstract class AuthenticationEvent {
  const AuthenticationEvent();

  List<Object> get props => [];
}

class SignUpUser extends AuthenticationEvent {
  final String userName;
  final String email;
  final String password;

  const SignUpUser({
    required this.userName,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [userName, email, password];
}

class LoginUser extends AuthenticationEvent {
  final String email;
  final String password;

  const LoginUser({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class EditProfile extends AuthenticationEvent {
  final String userName;
  final String email;

  const EditProfile({
    required this.userName,
    required this.email,
  });

  @override
  List<Object> get props => [userName, email];
}

class SignOut extends AuthenticationEvent {}

class FetchUserProducts extends AuthenticationEvent {
  final String userId;

  const FetchUserProducts({required this.userId});

  @override
  List<Object> get props => [userId];
}

class FetchUserTransactions extends AuthenticationEvent {
  final String userId;

  const FetchUserTransactions({required this.userId});

  @override
  List<Object> get props => [userId];
}

