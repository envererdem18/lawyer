import 'package:lawyer/lawyer.dart';
import 'package:test/test.dart';

void main() {
  group('Rule.from', () {
    test('parses the shorthand', () {
      final rule = Rule.from(RuleAction.allow, [
        't-shirt',
        ['S', 'M'],
        '*',
        const Criterion.exact('*'),
      ]);
      expect(rule.action, RuleAction.allow);
      expect(rule.criteria, [
        const Criterion.exact('t-shirt'),
        Criterion.oneOf(['S', 'M']),
        const Criterion.any(),
        const Criterion.exact('*'),
      ]);
    });

    test('throws on unsupported elements', () {
      expect(() => Rule.from(RuleAction.allow, [46]), throwsArgumentError);
      expect(() => Rule.from(RuleAction.allow, [null]), throwsArgumentError);
      expect(
        () => Rule.from(RuleAction.allow, [
          ['S', 46],
        ]),
        throwsArgumentError,
      );
      expect(
        () => Rule.from(RuleAction.allow, [<String>[]]),
        throwsArgumentError,
      );
    });
  });

  test('Rule.allow and Rule.deny set the action', () {
    expect(Rule.allow([]).action, RuleAction.allow);
    expect(Rule.deny([]).action, RuleAction.deny);
  });

  test('criteria cannot be modified', () {
    final source = [const Criterion.exact('a')];
    final rule = Rule.allow(source);
    source.add(const Criterion.any());
    expect(rule.criteria, hasLength(1));
    expect(() => rule.criteria.add(const Criterion.any()), throwsA(anything));
  });

  group('matches', () {
    test('compares each position, even with repeated criteria', () {
      final rule = Rule.from(RuleAction.allow, ['a', 'a']);
      expect(rule.matches(['a', 'a']), isTrue);
      expect(rule.matches(['a', 'b']), isFalse);
    });

    test('ignores conditions beyond the last criterion', () {
      final rule = Rule.from(RuleAction.deny, ['shoe', '46']);
      expect(rule.matches(['shoe', '46', 'black']), isTrue);
    });

    test('missing conditions match an allow rule', () {
      final rule = Rule.from(RuleAction.allow, ['jacket', 'L', 'black']);
      expect(rule.matches(['jacket', 'L']), isTrue);
      expect(rule.matches(['jacket', 'M']), isFalse);
    });

    test('missing conditions do not match a deny rule', () {
      final rule = Rule.from(RuleAction.deny, ['shoe', '46', 'white']);
      expect(rule.matches(['shoe', '46']), isFalse);
      expect(rule.matches(['shoe', '46', 'white']), isTrue);
    });

    test('a rule without criteria matches everything', () {
      expect(Rule.allow([]).matches(['x']), isTrue);
      expect(Rule.deny([]).matches(['x']), isTrue);
    });
  });

  test('equality, hashCode and toString', () {
    final a = Rule.from(RuleAction.deny, [
      'Guest',
      ['Mon', 'Tue'],
      '*',
    ]);
    final b = Rule.deny([
      const Criterion.exact('Guest'),
      Criterion.oneOf(['Tue', 'Mon']),
      const Criterion.any(),
    ]);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(Rule.from(RuleAction.allow, ['Guest'])));
    expect(a.toString(), 'Rule.deny(Guest, [Mon, Tue], *)');
  });
}
