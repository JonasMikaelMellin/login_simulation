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