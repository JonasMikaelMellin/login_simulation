/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

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