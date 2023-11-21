import 'package:flutter_test/flutter_test.dart';
import 'package:lawyer/lawyer.dart';

void main() {
  test('L size jacket is producable', () {
    final lawyer = Lawyer.instance;
    lawyer.setRules(
      [
        Rule(Action.allow, [
          "t-shirt",
          ["S", "M"],
          "blue"
        ]),
        Rule(Action.allow, ["jacket", "L", "black"]),
        Rule(Action.allow, ["shoe", "46", "white"]),
        Rule(Action.deny, ["shoe", "46"]),
        Rule(Action.allow, ["shoe", "*", "*"]),
      ],
    );
    expect(lawyer.check(["jacket", "L"]), true);
  });

  test('S size and blue t-shirt is not producable', () {
    final lawyer = Lawyer.instance;
    lawyer.setRules([
      Rule(Action.deny, [
        ["t-shirt", "hat"],
        ["S", "M"],
        "blue"
      ]),
      Rule(Action.allow, ["t-shirt", "*", "*"]),
      Rule(Action.allow, ["jacket", "L", "black"]),
      Rule(Action.allow, ["shoe", "46", "white"]),
      Rule(Action.deny, ["shoe", "46"]),
      Rule(Action.allow, ["shoe", "*", "*"]),
    ]);
    expect(lawyer.check(["t-shirt", "S", "blue"]), false);
  });

  test('Guest user does not allowed for saturday', () {
    final lawyer = Lawyer.instance;
    lawyer.setRules([
      Rule(Action.allow, [
        'Gold member',
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        ['Swimming pool', 'Gym', 'Sauna']
      ]),
      Rule(Action.deny, [
        'Guest',
        ['Mon', 'Tue'],
        ['Sauna', 'Gym']
      ]),
      Rule(Action.allow, [
        ['Guest', 'Regular member'],
        '*',
        '*'
      ])
    ]);
    const memberships = ['Gold member', 'Regular member', 'Guest'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    const facilities = ['Swimming pool', 'Gym', 'Sauna'];

    // expect(lawyer.check(['Guest', 'Sat']), true);
    lawyer.setDimensions([memberships, days, facilities]);
    expect(lawyer.check(['Guest', 'Sat']), false);
  });
}
