import 'lawyer.dart';

/// The set of valid values for one position of the checked conditions.
///
/// When a [Lawyer] has dimensions, conditions outside their dimension are
/// never allowed, and rules must only reference values from the dimensions.
final class Dimension {
  /// Creates a dimension with the given valid [values].
  ///
  /// Throws an [ArgumentError] if [values] is empty.
  Dimension(Iterable<String> values, {this.name})
      : values = Set.unmodifiable(values) {
    if (this.values.isEmpty) {
      throw ArgumentError.value(values, 'values', 'must not be empty');
    }
  }

  /// An optional label, used in error messages.
  final String? name;

  /// The valid values of this dimension.
  final Set<String> values;

  /// Whether [value] is a valid value of this dimension.
  bool contains(String value) => values.contains(value);

  @override
  bool operator ==(Object other) =>
      other is Dimension &&
      other.name == name &&
      other.values.length == values.length &&
      other.values.containsAll(values);

  @override
  int get hashCode => Object.hash(name, Object.hashAllUnordered(values));

  @override
  String toString() => 'Dimension(${name ?? ''}[${values.join(', ')}])';
}
