import 'package:firebase_auth/firebase_auth.dart' as auth_firebase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/storage.dart';
import 'package:progetto/components/forms/create_goal_form.dart';
import 'package:progetto/main.dart';
import 'package:progetto/model/goal.dart';
import 'package:progetto/model/user.dart';

@GenerateNiceMocks([
  MockSpec<Database>(),
  MockSpec<Auth>(),
  MockSpec<Storage>(),
  MockSpec<auth_firebase.User>()
])
import 'create_goal_form_test.mocks.dart';

main() {
  late MockDatabase database;
  late Auth auth;
  late Storage storage;
  late Goal testGoal;
  late auth_firebase.User curUser;
  late User user;

  setUp(() {
    database = MockDatabase();
    auth = MockAuth();
    storage = MockStorage();
    curUser = MockUser();
    user = User.fromJson({
      'name': 'Mario',
      'surname': 'Rossi',
      'uid': 'mario_rossi',
    });
    when(database.createGoal(any, any)).thenAnswer((realInvocation) async {
      testGoal = realInvocation.positionalArguments[1];
      testGoal.owner = user;
    });
    when(auth.currentUser).thenReturn(curUser);
    // when(database.getGoals)
    //     .thenReturn((uid, {required inProgressOnly}) => Stream.fromIterable([
    //           [testGoal]
    //         ]));
  });

  testWidgets('Goal form - goal creation', (tester) async {
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Builder(
            builder: (BuildContext context) => CustomApp(
                onLogged: Scaffold(
                  body: CreateGoalForm(
                    width: MediaQuery.of(context).size.width,
                    database: database,
                    auth: auth,
                  ),
                ),
                onNotLogged: Scaffold(
                  body: CreateGoalForm(
                    width: MediaQuery.of(context).size.width,
                    database: database,
                    auth: auth,
                  ),
                ),
                auth: auth,
                storage: storage,
                database: database))));
    await tester.pumpAndSettle();
    final radiusGoalType = find.byKey(const Key('GoalType_Distance'));
    final targetValue = find.byKey(const Key('GoalTargetValue'));
    final sendButton = find.byKey(const Key('GoalSave'));
    await tester.tap(radiusGoalType);
    await tester.enterText(targetValue, "20");
    await tester.tap(sendButton);

    expect(testGoal.type, "distanceGoal");
    expect(testGoal.targetValue, 20.0);
    expect(testGoal.currentValue, 0.0);
    expect(testGoal.completed, false);
    expect(testGoal.owner, user);
  });
}
