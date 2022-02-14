/*
This file is part of Whedcapp - standalone.

Whedcapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Whedcapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
*/

import 'data.dart';

class DataSpec {
  final int dataIndex;
  final DataList data;
  const DataSpec({required this.dataIndex, required this.data});
}

class SeriesDataSpec {
  final DataSpec dataSpec;
  final Series series;
  const SeriesDataSpec({required this.dataSpec,required this.series});
}