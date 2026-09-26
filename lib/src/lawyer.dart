import 'criterion.dart';
import 'dimension.dart';
import 'rule.dart';
import 'rule_action.dart';

/// Checks conditions against an ordered list of [rules].
///
/// The first rule that matches decides; when no rule matches, the conditions
/// are denied. Values are compared exactly and case-sensitively, so normalize
/// them (e.g. with `toLowerCase()`) before building rules and checking.
///
/// ```dart
/// final lawyer = Lawyer(rules: [
///   Rule.from(RuleAction.deny, ['shoe', '46']),
///   Rule.from(RuleAction.allow, ['shoe', '*', '*']),
/// ]);
/// lawyer.check(['shoe', '42', 'black']); // true
/// lawyer.check(['shoe', '46', 'black']); // false
/// ```
final class Lawyer {
  /// Creates a lawyer that applies [rules] in order.
  ///
  /// If [dimensions] are given, each one lists the valid values of the
  /// condition at the same position. In that case every rule is validated
  /// against them, and an [ArgumentError] is thrown when a rule has more
  /// criteria than there are dimensions or references an unknown value.
  Lawyer({
    required Iterable<Rule> rules,
    Iterable<Dimension>? dimensions,
  })  : rules = List.unmodifiable(rules),
        dimensions = dimensions == null ? null : List.unmodifiable(dimensions) {
    final dimensions = this.dimensions;
    if (dimensions != null) {
      for (final rule in this.rules) {
        _validateRule(rule, dimensions);
      }
    }
  }

  /// The rules, in the order they are applied.
  final List<Rule> rules;

  /// The valid values of each condition position, if restricted.
  final List<Dimension>? dimensions;

  /// Whether [conditions] are allowed.
  ///
  /// Returns `false` when no rule matches or, if [dimensions] are set, when
  /// a condition is not a value of its dimension.
  ///
  /// Throws an [ArgumentError] if [conditions] is empty or, if [dimensions]
  /// are set, has more elements than there are dimensions.
  bool check(List<String> conditions) =>
      matchingRule(conditions)?.action == RuleAction.allow;

  /// The rule that decides [conditions], or `null` if none matches.
  ///
  /// Useful to explain why [check] returned a result. Throws like [check].
  Rule? matchingRule(List<String> conditions) {
    if (conditions.isEmpty) {
      throw ArgumentError.value(conditions, 'conditions', 'must not be empty');
    }
    final dimensions = this.dimensions;
    if (dimensions != null) {
      if (conditions.length > dimensions.length) {
        throw ArgumentError.value(
          conditions,
          'conditions',
          'has ${conditions.length} elements but there are only '
              '${dimensions.length} dimensions',
        );
      }
      for (var i = 0; i < conditions.length; i++) {
        if (!dimensions[i].contains(conditions[i])) return null;
      }
    }
    for (final rule in rules) {
      if (rule.matches(conditions)) return rule;
    }
    return null;
  }

  static void _validateRule(Rule rule, List<Dimension> dimensions) {
    if (rule.criteria.length > dimensions.length) {
      throw ArgumentError.value(
        rule,
        'rules',
        'has ${rule.criteria.length} criteria but there are only '
            '${dimensions.length} dimensions',
      );
    }
    for (var i = 0; i < rule.criteria.length; i++) {
      final dimension = dimensions[i];
      final values = switch (rule.criteria[i]) {
        AnyCriterion() => const <String>{},
        ExactCriterion(:final value) => {value},
        OneOfCriterion(:final values) => values,
      };
      for (final value in values) {
        if (!dimension.contains(value)) {
          throw ArgumentError.value(
            rule,
            'rules',
            "uses '$value', which is not in dimension "
                '${dimension.name ?? i}',
          );
        }
      }
    }
  }
}
