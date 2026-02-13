import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Zettelkasten'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          // TODO: Implement menu
        },
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.pushNamed(context, '/user'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
