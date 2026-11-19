import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:store/features/auth/presentation/bloc/auth_event.dart';
import 'package:store/features/auth/presentation/bloc/auth_state.dart';
import 'package:store/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const AuthCheckRequested());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AuraTheme.light(),
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all essential login elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome to Aura'), findsOneWidget);
      expect(find.byKey(const Key('login_email_input')), findsOneWidget);
      expect(find.byKey(const Key('login_password_input')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.byKey(const Key('login_to_register_button')), findsOneWidget);
    });

    testWidgets(
      'shows validation errors when fields are cleared and submitted',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Clear the default demo values
        await tester.enterText(find.byKey(const Key('login_email_input')), '');
        await tester.enterText(
          find.byKey(const Key('login_password_input')),
          '',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter your password'), findsOneWidget);
        verifyNever(() => mockAuthBloc.add(any()));
      },
    );

    testWidgets(
      'submits AuthLoginRequested when form is valid and button tapped',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(
          find.byKey(const Key('login_email_input')),
          'shopper@aura.example',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_input')),
          'secret123',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        verify(
          () => mockAuthBloc.add(
            const AuthLoginRequested(
              email: 'shopper@aura.example',
              password: 'secret123',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets('displays loading indicator when state is AuthLoading', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'shows SnackBar when state emits Unauthenticated with message',
      (tester) async {
        final controller = StreamController<AuthState>.broadcast();
        when(() => mockAuthBloc.stream).thenAnswer((_) => controller.stream);

        await tester.pumpWidget(createWidgetUnderTest());
        controller.add(
          const Unauthenticated(message: 'Invalid email or password'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Invalid email or password'), findsOneWidget);

        await controller.close();
      },
    );
  });
}
