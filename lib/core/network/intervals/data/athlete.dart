class IntervalUser {
  final Athlete athlete;

  const IntervalUser({
    required this.athlete,
  });

  factory IntervalUser.fromJson(Map<String, dynamic> json) {
    return IntervalUser(athlete: Athlete.fromJson(json['athlete']));
  }

}

class Athlete {
  final String id;
  final String name;
  final String? profile_medium;
  final String? city;
  final String? state;
  final String? country;
  final String? timezone;
  final String? sex;
  final String? bio;
  final String? website;
  final String? email;

  Athlete({required this.id,
    required this.name,
    this.profile_medium,
    this.city,
    this.state,
    this.country,
    this.timezone,
    this.sex,
    this.bio,
    this.website,
    this.email});

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      name: json['name'],
      profile_medium: json['profile_medium'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      timezone: json['timezone'],
      sex: json['sex'],
      bio: json['bio'],
      website: json['website'],
      email: json['email'],
    );
  }
}
