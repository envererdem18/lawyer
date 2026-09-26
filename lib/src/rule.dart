import 'criterion.dart';
import 'rule_action.dart';

/// An ordered list of [criteria] and the [action] taken when they match.
final class Rule {
  /// Creates a rule that applies [action] when [criteria] match.
  Rule(this.action, Iterable<Criterion> criteria)
      : criteria = List.unmodifiable(criteria);

  /// Creates a rule that allows the conditions matching [criteria].
  Rule.allow(Iterable<Criterion> criteria) : this(RuleAction.allow, criteria);

  /// Creates a rule that denies the conditions matching [criteria].
  Rule.deny(Iterable<Criterion> criteria) : this(RuleAction.deny, criteria);

  /// Creates a rule from the untyped shorthand, e.g. data loaded from JSON:
  ///
  /// * `'*'` becomes [Criterion.any],
  /// * any other [String] becomes [Criterion.exact],
  /// * an [Iterable] of strings becomes [Criterion.oneOf],
  /// * a [Criterion] is used as is.
  ///
  /// ```dart
  /// Rule.from(RuleAction.allow, ['t-shirt', ['S', 'M'], '*']);
  /// ```
  ///
  /// Throws an [ArgumentError] for any other element.
  factory Rule.from(RuleAction action, Iterable<Object?> elements) =>
      Rule(action, elements.map(_parse));

  /// The outcome when this rule matches.
  final RuleAction action;

  /// One criterion per position of the checked conditions.
  final List<Criterion> criteria;

  static Criterion _parse(Object? element) => switch (element) {
        Criterion() => element,
        '*' => const Criterion.any(),
        String() => Criterion.exact(element),
        Iterable<Object?>() when element.every((e) => e is String) =>
          Criterion.oneOf(element.cast<String>()),
        _ => throw ArgumentError.value(
            element,
            'elements',
            'must be a String, an Iterable<String> or a Criterion',
          ),
      };

  /// Whether this rule applies to [conditions].
  ///
  /// Each condition is compared to the criterion at the same position.
  /// Conditions beyond the last criterion are ignored. When there are fewer
  /// conditions than criteria, the missing ones count as matching for an
  /// allow rule and as not matching for a deny rule, so a partial query asks
  /// "could this be allowed?".
  bool matches(List<String> conditions) {
    for (var i = 0; i < criteria.length; i++) {
      if (i >= conditions.length) return action == RuleAction.allow;
      if (!criteria[i].matches(conditions[i])) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Rule ||
        other.action != action ||
        other.criteria.length != criteria.length) {
      return false;
    }
    for (var i = 0; i < criteria.length; i++) {
      if (other.criteria[i] != criteria[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(action, Object.hashAll(criteria));

  @override
  String toString() => 'Rule.${action.name}(${criteria.join(', ')})';
}
