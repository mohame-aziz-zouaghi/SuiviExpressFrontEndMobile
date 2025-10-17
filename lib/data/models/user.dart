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
  DateTime createdAt; // read-only
  DateTime updatedAt; // read-only
  DateTime? lastLogin; // read-only
  String? deviceToken; // read-only
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
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.deviceToken,
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
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        lastLogin:
            json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
        deviceToken: json['deviceToken'],
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
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "lastLogin": lastLogin?.toIso8601String(),
        "deviceToken": deviceToken,
        "password": password,
      };
}
