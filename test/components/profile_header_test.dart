import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/exceptions.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/profile_header.dart';
import 'package:progetto/main.dart';
import 'package:progetto/model/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

@GenerateNiceMocks([MockSpec<Database>(), MockSpec<Auth>(), MockSpec<Storage>(), MockSpec<auth.User>()])
import 'profile_header_test.mocks.dart';

main() {
  late Database database;
  late Auth auth;
  late Storage storage;
  late User currentUser;
  late User friend;
  final MockUser mockAuthUser = MockUser();

  setUp(() {
    database = MockDatabase();
    auth = MockAuth();
    storage = MockStorage();
    currentUser = User.fromJson({
      'name': 'Mario',
      'surname': 'Rossi',
      'uid': 'mario_rossi',
    });
    friend = User.fromJson({
      'name': 'Luigi',
      'surname': 'Verdi',
      'uid': 'luigi_verdi',
      'birthday': '1999-04-03',
    });
    when(auth.currentUser).thenReturn(mockAuthUser);
    when(auth.authStateChanges).thenAnswer((realInvocation) => Stream.fromIterable([mockAuthUser]));
    when(mockAuthUser.uid).thenReturn(currentUser.uid);
  });

  Widget widgetUnderTest(User user) {
    return CustomApp(
      onLogged: Scaffold(
        body: ProfileHeader(
          user: user,
          storage: storage,
          database: database,
          auth: auth,
        ),
      ),
      onNotLogged: Container(),
      auth: auth,
      storage: storage,
      database: database,
    );
  }

  group('current user', () {
    testWidgets('standard case current user', (WidgetTester tester) async {
      await tester.pumpWidget(widgetUnderTest(currentUser));
      await tester.pumpAndSettle();
      verifyNever(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid));
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsNothing);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsNothing);
    });
  });

  group('other user', () {
    testWidgets('other user is already a friend of the current one', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenAnswer((realInvocation) => Future.value(true));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsNothing);
    });

    testWidgets('other user is yet a friend of the current one', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenAnswer((realInvocation) => Future.value(false));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsNothing);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsOneWidget);
    });

    testWidgets('exception is thrown when checking friendship', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenThrow(DatabaseException('friendship cannot be defined'));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsNothing);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsNothing);
    });
  });

  group('friend addition and removal', () {
    testWidgets('add friend', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenAnswer((realInvocation) => Future.value(false));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      await tester.tap(find.byKey(const Key('ButtonToAddFriend')));
      await tester.pumpAndSettle();
      verify(database.addFriend(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      verifyNever(database.removeFriend(currentUserUid: currentUser.uid, friendUid: friend.uid));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Added friend!'), findsOneWidget);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsNothing);
    });

    testWidgets('exception when adding friend', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenAnswer((realInvocation) => Future.value(false));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      when(database.addFriend(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenThrow(DatabaseException("couldn't add friend"));
      await tester.tap(find.byKey(const Key('ButtonToAddFriend')));
      await tester.pumpAndSettle();
      verify(database.addFriend(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      verifyNever(database.removeFriend(currentUserUid: currentUser.uid, friendUid: friend.uid));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Added friend!'), findsNothing);
      expect(find.text("Something went wrong. Please try again."), findsOneWidget);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsNothing);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsOneWidget);
    });
    testWidgets('remove friend', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenAnswer((realInvocation) => Future.value(true));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      await tester.tap(find.byKey(const Key('ButtonToRemoveFriend')));
      await tester.pumpAndSettle();
      verify(database.removeFriend(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      verifyNever(database.addFriend(currentUserUid: currentUser.uid, friendUid: friend.uid));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Removed friend.'), findsOneWidget);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsNothing);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsOneWidget);
    });

    testWidgets('exception when removing friend', (WidgetTester tester) async {
      when(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenAnswer((realInvocation) => Future.value(true));
      await tester.pumpWidget(widgetUnderTest(friend));
      await tester.pumpAndSettle();
      verify(database.isFriendOf(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      when(database.removeFriend(currentUserUid: currentUser.uid, friendUid: friend.uid))
          .thenThrow(DatabaseException("couldn't remove friend"));
      await tester.tap(find.byKey(const Key('ButtonToRemoveFriend')));
      await tester.pumpAndSettle();
      verify(database.removeFriend(currentUserUid: currentUser.uid, friendUid: friend.uid)).called(1);
      verifyNever(database.addFriend(currentUserUid: currentUser.uid, friendUid: friend.uid));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Removed friend'), findsNothing);
      expect(find.text("Something went wrong. Please try again."), findsOneWidget);
      expect(find.byKey(const Key('ProfilePictureInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('NameInProfileHeader')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToRemoveFriend')), findsOneWidget);
      expect(find.byKey(const Key('ButtonToAddFriend')), findsNothing);
    });
  });
}
