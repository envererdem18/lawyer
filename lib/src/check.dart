import 'models.dart';

bool check(List<Rule> rules, Dimension? dimensions, List<String> conditions) {
  if (rules.isEmpty) {
    throw Exception(
        "Please provide a rules array in order to use the check method.");
  }
  if (conditions.isEmpty) {
    throw Exception(
        "Please provide conditions as arguments to the check call.");
  }

  for (var ruleIndex = 0; ruleIndex < rules.length; ruleIndex++) {
    final ruleElements = rules[ruleIndex].elements;

    final action = rules[ruleIndex].action;

    bool rv = ruleElements.every((r) {
      int index = ruleElements.indexOf(r);
      if (conditions.length <= index) return action == Action.allow;

      if (r == "*") {
        if (dimensions != null && dimensions.elements.isNotEmpty) {
          return dimensions.elements[index].contains(conditions[index]);
        }
        return true;
      }

      return r.contains(conditions[index]);
    });

    if (rv) return action == Action.allow;
  }

  return false;
}
