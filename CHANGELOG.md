## 0.2.0

**Breaking changes**, see the [migration guide](README.md#from-01x-to-020).

- Renamed `Action` to `RuleAction`, which no longer clashes with Flutter's
  `Action` class.
- Replaced the `Lawyer.instance` singleton, `setRules` and `setDimensions`
  with an immutable `Lawyer(rules: ..., dimensions: ...)`.
- `Rule` now takes typed `Criterion`s (`Criterion.any`, `Criterion.exact`,
  `Criterion.oneOf`); `Rule.from` keeps the untyped shorthand. Added
  `Rule.allow` and `Rule.deny`.
- `Dimension` now describes a single position; pass one per position.
- Every condition is validated against its dimension, and rules are validated
  against the dimensions when the `Lawyer` is created.
- An empty rule list denies everything instead of throwing; empty conditions
  throw an `ArgumentError`.
- Removed the Flutter dependency; this is now a pure Dart package.

**Fixes**

- Strings were matched as substrings (`'Gold'` matched `'Gold member'`, and
  `''` matched anything).
- Repeated elements in a rule, such as two wildcards, were checked at the
  wrong position.
- Rules longer than the dimensions threw a `RangeError`, and unsupported rule
  elements threw a `NoSuchMethodError` during `check`.

**Other**

- Added `Lawyer.matchingRule` to explain a decision, and `Rule.matches`.
- Added `==`, `hashCode` and `toString` to `Rule`, `Criterion` and
  `Dimension`.
- Added API documentation, a complete README and many more tests.
- Added CI.

## 0.1.2

- Version bump only.

## 0.1.1

- Updated the package description and README.

## 0.1.0

- Added the repository link.

## 0.0.1

- Initial release.
