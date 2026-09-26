import 'rule.dart';

/// The outcome of a matching [Rule].
///
/// Named `RuleAction` (not `Action`) so it does not clash with Flutter's
/// `Action` class from `package:flutter/widgets.dart`.
enum RuleAction {
  /// The conditions are allowed.
  allow,

  /// The conditions are denied.
  deny,
}
