class AuthModel {
  final bool success;
  final String message;
  final UserData data;

  AuthModel({required this.success, required this.message, required this.data});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      success: json['success'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final User user;
  final String token;

  UserData({required this.user, required this.token});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(user: User.fromJson(json['user']), token: json['token']);
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String title;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.title,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      title: json['title'],
      avatar: json['avatar'],
    );
  }
}
