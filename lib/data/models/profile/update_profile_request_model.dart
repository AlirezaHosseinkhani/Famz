class UpdateProfileRequestModel {
  final String? phoneNumber;
  final String? username;
  final String? bio;
  final String? profilePicture;

  UpdateProfileRequestModel({
    this.phoneNumber,
    this.username,
    this.bio,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
    }

    if (username != null) {
      data['username'] = username;
    }
    if (bio != null) {
      data['bio'] = bio;
    }
    if (profilePicture != null) {
      data['profile_picture'] = profilePicture;
    }

    return data;
  }
}
