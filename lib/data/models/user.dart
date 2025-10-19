class User {
  final int id;
  String username;
  String firstName;
  String lastName;
  String email;
  String? phone;
  String? address;
  String? profileImageUrl;
  String role; // usually read-only for the user
  bool enabled; // read-only
  bool locked; // read-only
// read-only
  String? password; // optional, only used for updates if user wants to change it

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.profileImageUrl,
    required this.role,
    required this.enabled,
    required this.locked,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        profileImageUrl: json['profileImageUrl'],
        role: json['role'],
        enabled: json['enabled'],
        locked: json['locked'],
        password: json['password'], // optional
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "address": address,
        "profileImageUrl": profileImageUrl,
        "role": role,
        "enabled": enabled,
        "locked": locked,
        "password": password,
      };
}
