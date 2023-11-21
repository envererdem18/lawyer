import 'package:lawyer/src/models.dart';

import 'check.dart' as ch;

class Lawyer {
  Lawyer._();
  static final instance = Lawyer._();

  List<Rule> _rules = [];
  Dimension? _dimensions;

  List<Rule> get rules => _rules;
  Dimension? get dimensions => _dimensions;

  setRules(List<Rule> rules) {
    _rules = rules.map((e) => Rule(e.action, e.elements)).toList();
  }

  setDimensions(List<dynamic> dimensions) {
    _dimensions = Dimension(dimensions);
  }

  bool check(List<String> conditions) {
    return ch.check(_rules, _dimensions, conditions);
  }
}
