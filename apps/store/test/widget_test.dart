import 'package:bloc_test/bloc_test.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/features/auth/domain/entities/user.dart';
import 'package:store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:store/features/auth/presentation/bloc/auth_event.dart';
import 'package:store/features/auth/presentation/bloc/auth_state.dart';
import 'package:store/flavors.dart';
import 'package:store/pages/my_home_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  // F.appFlavor is `late final`, so it can only be assigned once per test file.
  setUpAll(() => F.appFlavor = Flavor.dev);

  testWidgets('home page shows the flavor title', (tester) async {
    final mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(
      const Authenticated(
        User(id: 'usr_1', email: 'shopper@aura.example', name: 'Tester'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AuraTheme.light(),
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const MyHomePage(),
        ),
      ),
    );

    expect(find.text('Hello (DEV) Aura'), findsOneWidget);
    expect(find.text('Welcome back, Tester!'), findsOneWidget);
  });
}
