class AuthenticatedUser {
  final String token;

  final String athleteId;

  final String name;

  AuthenticatedUser(
      {required this.token,
      required this.athleteId,
      required this.name});
}
