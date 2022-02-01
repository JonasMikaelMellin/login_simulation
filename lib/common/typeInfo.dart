enum TypeInfo {BOOL, INT, DOUBLE, STRING}

class FormEntryInfo {
  final int order;
  final String name;
  final TypeInfo type;
  final bool hidden;
  final String label;
  final String helpText;
  FormEntryInfo({required this.order,required this.name,required this.type,required this.hidden, required this.label, required this.helpText});
}