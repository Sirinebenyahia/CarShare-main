import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:carshare_tunisie/main.dart';
import 'package:carshare_tunisie/providers/auth_provider.dart';
import 'package:carshare_tunisie/providers/user_provider.dart';
import 'package:carshare_tunisie/models/user.dart';

void main() {
  testWidgets('Navigate to edit profile and delete profile image', (WidgetTester tester) async {
    final auth = AuthProvider();
    final userProvider = UserProvider();

    // Setup mock user
    final mockUser = User(
      id: 'u1',
      email: 'test@example.com',
      fullName: 'Test User',
      phoneNumber: '+21600000000',
      profileImageUrl: 'https://example.com/image.jpg',
      role: UserRole.driver,
      dateOfBirth: DateTime(1990, 1, 1),
      city: 'Tunis',
      bio: 'Bio',
      isVerified: false,
      rating: 4.0,
      totalRides: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Make user authenticated in the auth provider
    await auth.register(
      email: mockUser.email,
      password: 'password',
      fullName: mockUser.fullName,
      phoneNumber: mockUser.phoneNumber ?? '',
      role: mockUser.role,
    );
    // Overwrite with our mock user data (profile image, etc.)
    auth.updateUser(mockUser);
    userProvider.setUser(mockUser);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ],
        child: const MaterialApp(
          home: CarShareTunisie(),
        ),
      ),
    );

    // Wait for initial frame
    await tester.pumpAndSettle();

    // Navigate to profile via the app's Navigator
    final navigator = tester.state(find.byType(Navigator).first) as NavigatorState;
    navigator.pushNamed('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Mon profil'), findsOneWidget);

    // Tap the delete profile image button
    final deleteButton = find.byKey(const Key('profile_image_delete_button'));
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // A confirmation dialog should appear
    expect(find.text('Supprimer la photo de profil'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    // User's profileImageUrl should now be null
    expect(auth.currentUser!.profileImageUrl, isNull);
    expect(userProvider.currentUser!.profileImageUrl, isNull);
  });
}
