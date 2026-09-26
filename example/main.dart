import 'package:lawyer/lawyer.dart';

void main() {
  // Rules without dimensions.
  final products = Lawyer(rules: [
    Rule.from(RuleAction.allow, [
      't-shirt',
      ['S', 'M'],
      'blue',
    ]),
    Rule.from(RuleAction.allow, ['jacket', 'L', 'black']),
    Rule.from(RuleAction.allow, ['shoe', '46', 'white']),
    Rule.from(RuleAction.deny, ['shoe', '46']),
    Rule.from(RuleAction.allow, ['shoe', '*', '*']),
  ]);

  print(products.check(['jacket', 'L'])); // true
  print(products.check(['shoe', '46', 'black'])); // false
  print(products.matchingRule(['shoe', '46', 'black'])); // Rule.deny(shoe, 46)

  // Rules with dimensions.
  final rules = [
    Rule.from(RuleAction.allow, [
      'Gold member',
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      ['Swimming pool', 'Gym', 'Sauna'],
    ]),
    Rule.from(RuleAction.deny, [
      'Guest',
      ['Mon', 'Tue'],
      ['Sauna', 'Gym'],
    ]),
    Rule.from(RuleAction.allow, [
      ['Guest', 'Regular member'],
      '*',
      '*',
    ]),
  ];

  // Without dimensions, the wildcard accepts Saturday.
  print(Lawyer(rules: rules).check(['Guest', 'Sat'])); // true

  // With dimensions, Saturday is not a valid day.
  final gym = Lawyer(
    rules: rules,
    dimensions: [
      Dimension(['Gold member', 'Regular member', 'Guest'], name: 'membership'),
      Dimension(['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], name: 'day'),
      Dimension(['Swimming pool', 'Gym', 'Sauna'], name: 'facility'),
    ],
  );
  print(gym.check(['Guest', 'Sat'])); // false
  print(gym.check(['Guest', 'Wed', 'Sauna'])); // true
}
