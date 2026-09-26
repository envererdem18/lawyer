import 'package:lawyer/lawyer.dart';
import 'package:test/test.dart';

void main() {
  group('products', () {
    final lawyer = Lawyer(rules: [
      Rule.from(RuleAction.deny, [
        ['t-shirt', 'hat'],
        ['S', 'M'],
        'blue',
      ]),
      Rule.from(RuleAction.allow, ['t-shirt', '*', '*']),
      Rule.from(RuleAction.allow, ['jacket', 'L', 'black']),
      Rule.from(RuleAction.allow, ['shoe', '46', 'white']),
      Rule.from(RuleAction.deny, ['shoe', '46']),
      Rule.from(RuleAction.allow, ['shoe', '*', '*']),
    ]);

    test('an L size jacket is producible', () {
      expect(lawyer.check(['jacket', 'L']), isTrue);
      expect(lawyer.check(['jacket', 'L', 'black']), isTrue);
    });

    test('an S size blue t-shirt is not producible', () {
      expect(lawyer.check(['t-shirt', 'S', 'blue']), isFalse);
      expect(lawyer.check(['t-shirt', 'S', 'red']), isTrue);
    });

    test('the first matching rule wins', () {
      expect(lawyer.check(['shoe', '46', 'white']), isTrue);
      expect(lawyer.check(['shoe', '46', 'black']), isFalse);
      expect(lawyer.check(['shoe', '42', 'black']), isTrue);
    });

    test('values are not matched as substrings', () {
      expect(lawyer.check(['jack', 'L']), isFalse);
      expect(lawyer.check(['shoe', '4', 'black']), isTrue);
      expect(lawyer.check(['', '']), isFalse);
    });

    test('values are case-sensitive', () {
      expect(lawyer.check(['Jacket', 'L']), isFalse);
    });

    test('unknown items are denied by default', () {
      expect(lawyer.check(['sock']), isFalse);
    });

    test('matchingRule explains the result', () {
      expect(
        lawyer.matchingRule(['shoe', '46', 'black']),
        Rule.from(RuleAction.deny, ['shoe', '46']),
      );
      expect(lawyer.matchingRule(['sock']), isNull);
    });
  });

  test('an empty rule list denies everything', () {
    expect(Lawyer(rules: []).check(['anything']), isFalse);
  });

  test('empty conditions throw', () {
    expect(() => Lawyer(rules: []).check([]), throwsArgumentError);
  });

  test('instances are independent', () {
    final allowAll = Lawyer(rules: [
      Rule.allow([const Criterion.any()])
    ]);
    final denyAll = Lawyer(rules: [
      Rule.deny([const Criterion.any()])
    ]);
    expect(allowAll.check(['x']), isTrue);
    expect(denyAll.check(['x']), isFalse);
  });

  test('rules cannot be modified', () {
    final source = [Rule.allow([])];
    final lawyer = Lawyer(rules: source);
    source.clear();
    expect(lawyer.rules, hasLength(1));
    expect(() => lawyer.rules.clear(), throwsA(anything));
  });

  group('gym with dimensions', () {
    final memberships = Dimension(
      ['Gold member', 'Regular member', 'Guest'],
      name: 'membership',
    );
    final days = Dimension(['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], name: 'day');
    final facilities = Dimension(
      ['Swimming pool', 'Gym', 'Sauna'],
      name: 'facility',
    );
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
    final lawyer = Lawyer(
      rules: rules,
      dimensions: [memberships, days, facilities],
    );

    test('a guest is allowed on Saturday without dimensions', () {
      expect(Lawyer(rules: rules).check(['Guest', 'Sat']), isTrue);
    });

    test('a guest is not allowed on Saturday with dimensions', () {
      expect(lawyer.check(['Guest', 'Sat']), isFalse);
    });

    test('each wildcard is checked against its own dimension', () {
      expect(lawyer.check(['Guest', 'Wed', 'Sauna']), isTrue);
      expect(lawyer.check(['Guest', 'Mon', 'Casino']), isFalse);
    });

    test('explicit values are checked against dimensions', () {
      expect(lawyer.check(['Gold member', 'Mon', 'Gym']), isTrue);
      expect(lawyer.check(['Platinum', 'Mon', 'Gym']), isFalse);
    });

    test('deny rules apply', () {
      expect(lawyer.check(['Guest', 'Mon', 'Gym']), isFalse);
      expect(lawyer.check(['Guest', 'Mon', 'Swimming pool']), isTrue);
    });

    test('more conditions than dimensions throw', () {
      expect(
        () => lawyer.check(['Guest', 'Mon', 'Gym', 'extra']),
        throwsArgumentError,
      );
    });

    test('rules with unknown values throw', () {
      expect(
        () => Lawyer(
          rules: [
            Rule.from(RuleAction.allow, ['Guest', 'Sat']),
          ],
          dimensions: [memberships, days],
        ),
        throwsA(
          isArgumentError.having(
            (e) => e.message,
            'message',
            contains("'Sat', which is not in dimension day"),
          ),
        ),
      );
    });

    test('rules longer than dimensions throw', () {
      expect(
        () => Lawyer(
          rules: [
            Rule.from(RuleAction.allow, ['Guest', '*']),
          ],
          dimensions: [memberships],
        ),
        throwsArgumentError,
      );
    });
  });

  test('Dimension throws on empty values', () {
    expect(() => Dimension([]), throwsArgumentError);
  });
}
