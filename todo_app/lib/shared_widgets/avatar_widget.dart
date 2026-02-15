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

  @override
  void didUpdateWidget(AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload avatar when widget updates (e.g., after login/logout)
    _loadAvatar();
  }

  // Public method to refresh avatar
  void refreshAvatar() {
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
      }
    }

    // If no cached avatar, fetch from API
    if (_avatarUrl == null) {
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
        final avatarUrl = await AvatarAPI.get_avatar_url_v2();

        if (avatarUrl != null && mounted) {
          setState(() {
            _avatarUrl = avatarUrl;
          });

          // Save URL to cache for future use
          await UserCacheService.saveAvatarUrl(avatarUrl);

          // Fix URL by adding /avatars/ path if missing
          String fixedUrl = avatarUrl;
          if (!fixedUrl.contains('/avatars/')) {
            // Extract UUID from URL and reconstruct with /avatars/ path
            final uri = Uri.parse(fixedUrl);
            final pathSegments = uri.pathSegments;
            if (pathSegments.isNotEmpty) {
              final uuid = pathSegments.last;
              fixedUrl =
                  '${uri.scheme}://${uri.host}:${uri.port}/avatars/$uuid.png';
            }
          }

          // Download and cache file
          final cachedFile = await UserCacheService.getAvatarFile(fixedUrl);
          if (cachedFile != null && mounted) {
            setState(() {
              _cachedAvatarFile = cachedFile;
            });
          } else {
            throw Exception('Failed to download avatar file');
          }
        }
      }
    } catch (e) {
      // Handle error silently or show toast
      throw Exception('Error loading avatar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Widget> _buildAvatar() async {
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
      return _buildNetworkImage();
    }

    return _buildDefaultAvatar();
  }

  Future<Widget> _buildNetworkImage() async {
    // Fix URL by adding /avatars/ path if missing
    String networkUrl = _avatarUrl!;
    if (!networkUrl.contains('/avatars/')) {
      // Extract UUID from URL and reconstruct with /avatars/ path
      final uri = Uri.parse(networkUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final uuid = pathSegments.last;
        networkUrl =
            '${uri.scheme}://${uri.host}:${uri.port}/avatars/$uuid.png';
      }
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          networkUrl,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; Flutter)',
            'Accept': 'image/*',
          },
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
    return GestureDetector(
      onTap: widget.onTap ?? () => Navigator.pushNamed(context, '/user'),
      child: FutureBuilder(
        future: _buildAvatar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          if (snapshot.hasError) {
            return _buildDefaultAvatar();
          }

          return snapshot.data ?? _buildDefaultAvatar();
        },
      ),
    );
  }
}
