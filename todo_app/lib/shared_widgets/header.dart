import 'package:flutter/material.dart';
import 'package:todo_app/shared_widgets/avatar_widget.dart';

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
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // TODO: Implement notifications dialog window
            return;
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: AvatarWidget(
            size: 32.0,
            onTap: () => Navigator.pushNamed(context, '/user'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
