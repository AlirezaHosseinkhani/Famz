import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final bool isEditable;

  const ProfileAvatarWidget({
    Key? key,
    this.imageUrl,
    this.size = 80,
    this.onTap,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              image: imageUrl != null
                  ? DecorationImage(
                      image: _getImageProvider(),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    size: size * 0.6,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
          ),
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: size * 0.15,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (imageUrl!.startsWith('http')) {
      return NetworkImage(imageUrl!);
    } else if (imageUrl!.startsWith('/')) {
      return FileImage(File(imageUrl!));
    } else {
      // Base64 image
      return MemoryImage(
        Uri.parse(imageUrl!).data!.contentAsBytes(),
      );
    }
  }
}
