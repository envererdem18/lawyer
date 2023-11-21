
_A lightweight Flutter package to set business rules and obey_
_Without in need of a database or expensive queries_
## Getting Started
The Lawyer creates lazy singleton class for storing rules and dimensions.
##### How to use:

```dart
// Usage without dimensions array
final lawyer = Lawyer.instance;

lawyer.setRules(
  [
    Rule(Action.allow, [
    "t-shirt",
    ["S", "M"],
    "blue"
  ]),
    Rule(Action.allow, ["jacket", "L", "black"]),
    Rule(Action.allow, ["shoe", "46", "white"]),
    Rule(Action.deny, ["shoe", "46"]),
    Rule(Action.allow, ["shoe", "*", "*"]),
  ],
);

// This will return true
lawyer.check(["jacket", "L"]);

  

// Usage with dimension array
final lawyer2 = Lawyer.instance;
lawyer2.setRules([
  Rule(Action.allow, [
    'Gold member',
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    ['Swimming pool', 'Gym', 'Sauna']
  ]),
  Rule(Action.deny, [
    'Guest',
    ['Mon', 'Tue'],
    ['Sauna', 'Gym']
  ]),
  Rule(Action.allow, [
    ['Guest', 'Regular member'],
    '*',
    '*'
  ])
]);

const memberships = ['Gold member', 'Regular member', 'Guest'];
const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
const facilities = ['Swimming pool', 'Gym', 'Sauna'];

/// This will return true, because Guest is allowed for Saturday
lawyer2.check(['Guest', 'Sat']);

/// Set dimension arrays
lawyer2.setDimensions([memberships, days, facilities]);

/// After setting dimensions, this will return false,
/// Because we don't have any option for Saturday any more
/// Days dimension does not have Saturday!!
lawyer2.check(['Guest', 'Sat']);
```