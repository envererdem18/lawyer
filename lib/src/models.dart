class Rule {
  final Action action;
  final List<dynamic> elements;

  Rule(this.action, this.elements);
}

class Dimension {
  final List<dynamic> elements;

  Dimension(this.elements);
}

enum Action {
  allow,
  deny,
}
