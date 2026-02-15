import 'package:flutter/material.dart';
import 'dart:io';
import 'package:todo_app/services/user_cache_service.dart';
import 'package:todo_app/services/token_service.dart';
import 'package:todo_app/api/avatar.dart';

class AvatarWidget extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;

  const AvatarWidget({super.key, this.size = 40.0, this.onTap});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  String? _avatarUrl;
  File? _cachedAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    // First try to get from UserCacheService (now with file caching)
    final avatarUrl = await UserCacheService.getAvatarUrl();
    if (avatarUrl != null) {
      setState(() {
        _avatarUrl = avatarUrl;
      });

      // Try to get cached file
      final cachedFile = await UserCacheService.getAvatarFile(avatarUrl);
      if (cachedFile != null && mounted) {
        setState(() {
          _cachedAvatarFile = cachedFile;
        });

        // DEBUG: Check if file actually exists
        print('DEBUG: Avatar file exists: ${cachedFile.existsSync()}');
        print('DEBUG: Avatar file path: ${cachedFile.path}');
      }
    }

    // If no cached avatar, fetch from API
    if (_avatarUrl == null) {
      print('DEBUG: No cached avatar, fetching from API');
      await _fetchAvatar();
    }
  }

  Future<void> _fetchAvatar() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final token = await TokenService.getToken();
      if (token != null) {
        // Try v2 first, fallback to v1
        final avatarUrl =
            await AvatarAPI.get_avatar_url_v2() ??
            await AvatarAPI.get_avatar_url_v1();

        if (avatarUrl != null && mounted) {
          setState(() {
            _avatarUrl = avatarUrl;
          });

          // Download and cache file
          final cachedFile = await UserCacheService.getAvatarFile(avatarUrl);
          if (cachedFile != null && mounted) {
            setState(() {
              _cachedAvatarFile = cachedFile;
            });
          }
        }
      }
    } catch (e) {
      // Handle error silently or show toast
      print('Error loading avatar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAvatar() {
    if (_isLoading) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey[300] ?? Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey[600] ?? Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    // Try cached file first (fastest)
    if (_cachedAvatarFile != null && _cachedAvatarFile!.existsSync()) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipOval(
          child: Image.file(
            _cachedAvatarFile!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
          ),
        ),
      );
    }

    // Fallback to network image
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            _avatarUrl!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.grey[300] ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[600] ?? Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.person, size: widget.size * 0.6, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: widget.onTap, child: _buildAvatar());
  }
}
