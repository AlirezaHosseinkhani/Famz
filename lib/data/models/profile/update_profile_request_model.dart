class UpdateProfileRequestModel {
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;

  UpdateProfileRequestModel({
    this.phoneNumber,
    this.bio,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
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
