# lawyer

[![pub package](https://img.shields.io/pub/v/lawyer.svg)](https://pub.dev/packages/lawyer)
[![CI](https://github.com/envererdem18/lawyer/actions/workflows/ci.yml/badge.svg)](https://github.com/envererdem18/lawyer/actions/workflows/ci.yml)

A lightweight, dependency-free rule engine for Dart and Flutter. Define
ordered allow/deny business rules, then check conditions against them,
without a database or expensive queries.

- Ordered **allow / deny** rules, first match wins
- **Wildcards** and **one-of** lists per position
- Optional **dimensions** that restrict the valid values of each position
- `matchingRule` to explain which rule made the decision
- Pure Dart: works in Flutter, on the server and on the CLI

## Installation

```sh
dart pub add lawyer
# or
flutter pub add lawyer
```

## Usage

```dart
import 'package:lawyer/lawyer.dart';

final lawyer = Lawyer(rules: [
  Rule.from(RuleAction.allow, ['t-shirt', ['S', 'M'], 'blue']),
  Rule.from(RuleAction.allow, ['jacket', 'L', 'black']),
  Rule.from(RuleAction.allow, ['shoe', '46', 'white']),
  Rule.from(RuleAction.deny, ['shoe', '46']),
  Rule.from(RuleAction.allow, ['shoe', '*', '*']),
]);

lawyer.check(['jacket', 'L']);           // true
lawyer.check(['shoe', '46', 'white']);   // true
lawyer.check(['shoe', '46', 'black']);   // false
lawyer.check(['sock']);                  // false, no rule matches

lawyer.matchingRule(['shoe', '46', 'black']); // Rule.deny(shoe, 46)
```

`Lawyer` is immutable. Create as many instances as you need, or hold one in
your dependency-injection / state-management solution. To change the rules,
create a new instance.

### Typed rules

`Rule.from` accepts a shorthand that is convenient for literals and data
loaded from JSON: `'*'` is a wildcard, a `String` is an exact value and a list
of strings means "one of". The same rules can be written with typed
criteria, checked by the compiler:

```dart
Rule.allow([
  const Criterion.exact('t-shirt'),
  Criterion.oneOf(['S', 'M']),
  const Criterion.any(),
]);
Rule.deny([const Criterion.exact('shoe'), const Criterion.exact('46')]);
```

Use `Criterion.exact('*')` to match a literal `*`.

### Dimensions

Dimensions list the valid values of each position. With dimensions:

- a condition that is not in its dimension is never allowed,
- wildcards only accept values of their dimension,
- rules are validated when the `Lawyer` is created: a rule that uses an
  unknown value, or has more positions than there are dimensions, throws an
  `ArgumentError`, which catches typos early.

```dart
final rules = [
  Rule.from(RuleAction.allow, [
    'Gold member',
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    ['Swimming pool', 'Gym', 'Sauna'],
  ]),
  Rule.from(RuleAction.deny, ['Guest', ['Mon', 'Tue'], ['Sauna', 'Gym']]),
  Rule.from(RuleAction.allow, [['Guest', 'Regular member'], '*', '*']),
];

// Without dimensions the wildcard accepts Saturday.
Lawyer(rules: rules).check(['Guest', 'Sat']); // true

final gym = Lawyer(
  rules: rules,
  dimensions: [
    Dimension(['Gold member', 'Regular member', 'Guest'], name: 'membership'),
    Dimension(['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], name: 'day'),
    Dimension(['Swimming pool', 'Gym', 'Sauna'], name: 'facility'),
  ],
);

gym.check(['Guest', 'Sat']);            // false, Saturday is not a valid day
gym.check(['Guest', 'Mon', 'Gym']);     // false, denied by the second rule
gym.check(['Guest', 'Wed', 'Sauna']);   // true
```

## How rules are evaluated

1. Rules are tried **in order**; the **first** matching rule decides. Put
   specific rules before general ones.
2. If **no rule matches**, the result is `false` (deny by default). An empty
   rule list denies everything.
3. Each condition is compared with the criterion at the **same position**.
   Comparison is **exact and case-sensitive**: `'Gold'` does not match
   `'Gold member'`, and `'Blue'` does not match `'blue'`. Normalize values
   yourself (e.g. `toLowerCase()`) if you need case-insensitive rules.
4. **Extra conditions** beyond a rule's length are ignored, so
   `Rule.from(RuleAction.deny, ['shoe', '46'])` denies every colour of size
   46 shoes.
5. **Partial queries** (fewer conditions than a rule has positions) ask
   "could this be allowed?": missing positions count as matching for allow
   rules and as not matching for deny rules. `check(['jacket', 'L'])` is
   `true` because an L jacket exists in some colour.
6. `check` and `matchingRule` throw an `ArgumentError` for empty conditions,
   or for more conditions than there are dimensions.

## Migration

### From 0.1.x to 0.2.0

0.2.0 fixes several matching bugs and redesigns the API. All of these are
breaking changes.

**`Action` was renamed to `RuleAction`.** `Action` clashed with Flutter's
`Action` widget class, so importing both `package:flutter/material.dart` and
`package:lawyer/lawyer.dart` did not compile.

```dart
// Before
Rule(Action.allow, ['jacket', 'L', 'black'])
// After
Rule.from(RuleAction.allow, ['jacket', 'L', 'black'])
```

**The singleton was replaced with instances.** `Lawyer.instance`,
`setRules` and `setDimensions` were removed. Every `Lawyer.instance` shared
the same rules, so a second rule set silently replaced the first one.

```dart
// Before
final lawyer = Lawyer.instance;
lawyer.setRules([...]);
lawyer.setDimensions([memberships, days, facilities]);

// After
final lawyer = Lawyer(
  rules: [...],
  dimensions: [Dimension(memberships), Dimension(days), Dimension(facilities)],
);
```

To change the rules at runtime, create a new `Lawyer`. The `rules` and
`dimensions` lists are now unmodifiable.

**`Rule` takes typed criteria.** `Rule(action, List<dynamic>)` became
`Rule(action, List<Criterion>)`. Use `Rule.from(action, elements)` for the old
untyped syntax; it now throws an `ArgumentError` for unsupported elements
(such as numbers) when the rule is created, instead of crashing during
`check`.

**`Dimension` describes a single position.** The old `Dimension` held all
dimensions in one list; now pass one `Dimension` per position:

```dart
// Before
lawyer.setDimensions([memberships, days, facilities]);
// After
dimensions: [Dimension(memberships), Dimension(days), Dimension(facilities)]
```

**Values are matched exactly.** Strings used to be matched as substrings, so
a rule for `'Gold member'` also allowed `'Gold'`, `'member'` and even `''`.
If you relied on this, list the accepted values explicitly with a one-of
list.

**Repeated wildcards are checked correctly.** In a rule such as
`['Guest', '*', '*']` the second wildcard was checked against the first
wildcard's dimension, so `['Guest', 'Mon', 'Casino']` was wrongly allowed.
Such checks may now return `false`.

**Dimensions are enforced more strictly.**

- Every condition is checked against its dimension, not only the ones under
  a wildcard. Conditions outside their dimension return `false`.
- Rules that use a value outside its dimension, or have more positions than
  there are dimensions, throw an `ArgumentError` when the `Lawyer` is created.
- Conditions longer than the number of dimensions throw an `ArgumentError`
  (they used to throw a `RangeError` in some cases).

**Error handling changed.**

- An empty rule list now makes `check` return `false` instead of throwing.
- Empty conditions throw an `ArgumentError` instead of a generic `Exception`.

**The package no longer depends on Flutter.** It works unchanged in Flutter
apps and can now also be used in pure Dart projects.

## License

[MIT](LICENSE)
