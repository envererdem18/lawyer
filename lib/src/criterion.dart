import 'rule.dart';

/// A single position of a [Rule], deciding which values it accepts.
///
/// Values are compared exactly and case-sensitively.
sealed class Criterion {
  const Criterion();

  /// Accepts any value (the wildcard, `'*'` in [Rule.from]).
  const factory Criterion.any() = AnyCriterion;

  /// Accepts only [value].
  const factory Criterion.exact(String value) = ExactCriterion;

  /// Accepts any of [values].
  ///
  /// Throws an [ArgumentError] if [values] is empty.
  factory Criterion.oneOf(Iterable<String> values) = OneOfCriterion;

  /// Whether this criterion accepts [value].
  bool matches(String value);
}

/// A [Criterion] that accepts any value.
final class AnyCriterion extends Criterion {
  /// Creates a wildcard criterion.
  const AnyCriterion();

  @override
  bool matches(String value) => true;

  @override
  bool operator ==(Object other) => other is AnyCriterion;

  @override
  int get hashCode => (AnyCriterion).hashCode;

  @override
  String toString() => '*';
}

/// A [Criterion] that accepts a single [value].
final class ExactCriterion extends Criterion {
  /// Creates a criterion that accepts only [value].
  const ExactCriterion(this.value);

  /// The only accepted value.
  final String value;

  @override
  bool matches(String value) => value == this.value;

  @override
  bool operator ==(Object other) =>
      other is ExactCriterion && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// A [Criterion] that accepts any of a set of [values].
final class OneOfCriterion extends Criterion {
  /// Creates a criterion that accepts any of [values].
  ///
  /// Throws an [ArgumentError] if [values] is empty.
  OneOfCriterion(Iterable<String> values) : values = Set.unmodifiable(values) {
    if (this.values.isEmpty) {
      throw ArgumentError.value(values, 'values', 'must not be empty');
    }
  }

  /// The accepted values.
  final Set<String> values;

  @override
  bool matches(String value) => values.contains(value);

  @override
  bool operator ==(Object other) =>
      other is OneOfCriterion &&
      other.values.length == values.length &&
      other.values.containsAll(values);

  @override
  int get hashCode => Object.hashAllUnordered(values);

  @override
  String toString() => '[${values.join(', ')}]';
}
