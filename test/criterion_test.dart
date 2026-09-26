import 'package:lawyer/lawyer.dart';
import 'package:test/test.dart';

void main() {
  group('Criterion.any', () {
    test('matches every value', () {
      const criterion = Criterion.any();
      expect(criterion.matches('anything'), isTrue);
      expect(criterion.matches(''), isTrue);
    });
  });

  group('Criterion.exact', () {
    test('matches only the equal value', () {
      const criterion = Criterion.exact('Gold member');
      expect(criterion.matches('Gold member'), isTrue);
      expect(criterion.matches('Gold'), isFalse);
      expect(criterion.matches(''), isFalse);
    });

    test('is case-sensitive', () {
      expect(const Criterion.exact('blue').matches('Blue'), isFalse);
    });

    test('can match a literal star', () {
      const criterion = Criterion.exact('*');
      expect(criterion.matches('*'), isTrue);
      expect(criterion.matches('x'), isFalse);
    });
  });

  group('Criterion.oneOf', () {
    test('matches only listed values', () {
      final criterion = Criterion.oneOf(['S', 'M']);
      expect(criterion.matches('S'), isTrue);
      expect(criterion.matches('M'), isTrue);
      expect(criterion.matches('L'), isFalse);
    });

    test('throws on empty values', () {
      expect(() => Criterion.oneOf([]), throwsArgumentError);
    });

    test('is not affected by later changes to the source list', () {
      final values = ['S'];
      final criterion = Criterion.oneOf(values);
      values.add('M');
      expect(criterion.matches('M'), isFalse);
    });
  });

  test('equality and hashCode', () {
    expect(const Criterion.any(), const Criterion.any());
    expect(const Criterion.exact('a'), const Criterion.exact('a'));
    expect(const Criterion.exact('a'), isNot(const Criterion.exact('b')));
    expect(Criterion.oneOf(['a', 'b']), Criterion.oneOf(['b', 'a']));
    expect(
      Criterion.oneOf(['a', 'b']).hashCode,
      Criterion.oneOf(['b', 'a']).hashCode,
    );
    expect(Criterion.oneOf(['a']), isNot(const Criterion.exact('a')));
  });
}
