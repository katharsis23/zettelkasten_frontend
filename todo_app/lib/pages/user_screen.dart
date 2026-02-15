import 'package:flutter/material.dart';
import 'package:todo_app/pages/login_screen.dart';
import 'package:todo_app/pages/signup_screen.dart';
import 'package:todo_app/pages/verification_screen.dart';
import 'package:todo_app/services/user_cache_service.dart';
import 'package:todo_app/services/token_service.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/shared_widgets/avatar_widget.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  User? _cachedUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning from verification
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final token = await TokenService.getToken();
      final hasCachedUser = await UserCacheService.hasCachedUser();
      final cachedUser = await UserCacheService.getCachedUser();

      if (mounted) {
        setState(() {
          _isLoggedIn = token != null && hasCachedUser;
          _cachedUser = cachedUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _cachedUser = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await TokenService.clearToken();
      await UserCacheService.clearCachedUser();
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _cachedUser = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // void _debugAvatarCache() {

  //   // Test UserCacheService
  //   UserCacheService.getAvatarUrl().then((url) {
  //     print('Cached URL: $url');
  //   });

  //   UserCacheService.getCachedUser().then((user) {
  //     print('Cached user avatar: ${user?.avatar_url}');
  //   });

  //   // Test file operations
  //   UserCacheService.getAvatarFile('test.jpg').then((file) {
  //     if (file != null) {
  //       print('File exists: ${file.existsSync()}');
  //       print('File path: ${file.path}');
  //     } else {
  //       print('No file found');
  //     }
  //   });

  // }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToVerification() {
    if (_cachedUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: _cachedUser!.email),
        ),
      ).then((_) {
        // Refresh user data after verification
        _checkLoginStatus();
      });
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    if (!_isLoggedIn || _cachedUser == null) {
      // Not logged in view
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.grey[800],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.account_circle_outlined,
                    size: screenWidth * 0.3,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Welcome message
                  Text(
                    'Welcome to Zettelkasten',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontSize: screenWidth * 0.06,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    'Please sign in or create an account to access your profile and manage your notes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.08),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: _navigateToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                        ),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // // Debug button (development only)
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: screenHeight * 0.06,
                  //   child: ElevatedButton(
                  //     onPressed: _debugAvatarCache,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.orange,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(
                  //           screenWidth * 0.03,
                  //         ),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       'Debug Avatar Cache',
                  //       style: TextStyle(
                  //         fontSize: screenWidth * 0.04,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: screenHeight * 0.02),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: OutlinedButton(
                      onPressed: _navigateToSignup,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Features preview
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      child: Column(
                        children: [
                          Text(
                            'With an account you can:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.045,
                                ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _buildFeatureItem(
                            context,
                            Icons.note_alt_outlined,
                            'Create and manage notes',
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          _buildFeatureItem(
                            context,
                            Icons.sync,
                            'Sync across devices',
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          _buildFeatureItem(
                            context,
                            Icons.share,
                            'Share your knowledge',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Logged in view
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                  children: [
                    // Avatar
                    AvatarWidget(size: screenWidth * 0.24),
                    SizedBox(height: screenHeight * 0.02),

                    // User Info
                    Text(
                      _cachedUser!.username,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: screenWidth * 0.05),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      _cachedUser!.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Chip(
                      label: Text(
                        _cachedUser!.is_verified ? 'Verified' : 'Not Verified',
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                      backgroundColor: _cachedUser!.is_verified
                          ? Colors.green[100]
                          : Colors.orange[100],
                      avatar: Icon(
                        _cachedUser!.is_verified
                            ? Icons.verified
                            : Icons.pending,
                        size: screenWidth * 0.04,
                        color: _cachedUser!.is_verified
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    if (!_cachedUser!.is_verified) ...[
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.05,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToVerification,
                          icon: Icon(
                            Icons.email_outlined,
                            size: screenWidth * 0.04,
                          ),
                          label: Text(
                            'Verify Email',
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Settings Options
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(context, Icons.edit, 'Edit Profile', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile coming soon!'),
                      ),
                    );
                  }),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildSettingsItem(
                    context,
                    Icons.notifications,
                    'Notifications',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications settings coming soon!'),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildSettingsItem(
                    context,
                    Icons.security,
                    'Privacy & Security',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings coming soon!'),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildSettingsItem(context, Icons.help, 'Help & Support', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help section coming soon!'),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: screenWidth * 0.05,
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: screenWidth * 0.06),
      title: Text(
        title,
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[800]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: screenWidth * 0.04,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
    );
  }
}
