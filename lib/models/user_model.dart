class User {
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String email;
  final String token;

  User({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return User(
      firstName: data['first_name']?.toString() ?? '',
      lastName: data['last_name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      token: data['token']?.toString() ??
          data['access_token']?.toString() ??
          json['token']?.toString() ??
          json['access_token']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'email': email,
      'token': token,
    };
  }
}