import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../flavors.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(F.title),
        actions: [
          IconButton(
            key: const Key('home_logout_button'),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final userName = state is Authenticated ? state.user.name : '';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello ${F.title}'),
                if (userName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back, $userName!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
