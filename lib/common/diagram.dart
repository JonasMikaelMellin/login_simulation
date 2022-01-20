
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../dataSpecification.dart';
import '../editDataNotes.dart';

class DiagramArgs {
  final List<Data> dataList;
  const DiagramArgs({required this.dataList});
}

class Diagram extends StatefulWidget {
  const Diagram({Key? key}) : super(key: key);

  @override
  _DiagramState createState() => _DiagramState();
}

class _DiagramState extends State<Diagram> {
  double zoomStart = 0.0;

  _DiagramState();
  @override
  void initState() {
    super.initState();
    this.setState(() {
    });
  }
  dynamic encode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DataList>(
        builder: (context,dataList,child) => Echarts(
        onMessage: (String msgStr) {
          Map<String,dynamic> msg = jsonDecode(msgStr);
          Navigator.pushNamed(context,EditDataNotesScreen.routeName,arguments: DataSpec(dataIndex: msg['dataIndex'], data: dataList)) ;
        },
        option: '''
        {
          dataset: {
            dimensions: [ 'Datum',
                          '${getSeriesName(context,Series.Wellbeing)}',
                          '${getSeriesName(context,Series.SenseOfHome)}',
                          '${getSeriesName(context,Series.Safety)}',
                          '${getSeriesName(context,Series.Loneliness)}',
                          'information'],
            source: ${jsonEncode(dataList.data.map((el) => el.toEchart(context)).toList(),toEncodable: encode)}
          },
          title: {
            text: 'Testgraf',
            textStyle: {
              fontSize: 24
            }
          },
          //tooltip: {
          //  trigger: 'axis'
          //},
          toolbox: {
            feature: {
              saveAsImage: {},
              dataZoom: {
                yAxisIndex: 'none'
              } 
            }
          },
          legend: {
            data: [ '${getSeriesName(context,Series.Wellbeing)}',
                    '${getSeriesName(context,Series.SenseOfHome)}',
                    '${getSeriesName(context,Series.Safety)}',
                    '${getSeriesName(context,Series.Loneliness)}'],
            textStyle: {
              fontSize: 18
            }
          },
          dataZoom: [
            {
              type: 'slider',
              xAxisIndex: 0,
              filterMode: 'filter',
              start: 93.0
            },
            {
              type: 'slider',
              show: false,
              yAxisIndex: 0,
              filterMode: 'none'
            }
          ],
          xAxis: {
            type: 'time',
            minInterval: 24*3600*1000,
            min: new Date(2021,0,1).getTime(),
            axisLabel: {
              fontSize: 18
            }
          },
          yAxis: {
            type: 'value',
            min: 0,
            max: 10,
            axisLabel: {
              fontSize: 18
            }
          },
          grid: {
            show: true
          },
          series: [{
            id: 'a',
            name: '${getSeriesName(context,Series.Wellbeing)}',
            dimensions: ['Datum', '${getSeriesName(context,Series.Wellbeing)}'],
            type: 'custom',
            z: 1,
            itemStyle: {
              color: '${getJavascriptSeriesColor(Series.Wellbeing)}'
            },
            renderItem: renderCircle
          }
          ,{
            id: 'b',
            name: '${getSeriesName(context,Series.Safety)}',
            dimensions: ['Datum','${getSeriesName(context,Series.Safety)}'],
            type: 'custom',
            itemStyle: {
              color: '${getJavascriptSeriesColor(Series.Safety)}'
            },
            renderItem: renderCircle            
          }
          ,{
            id: 'c',
            name: '${getSeriesName(context,Series.SenseOfHome)}',
            dimensions: ['Datum','${getSeriesName(context,Series.SenseOfHome)}'],
            type: 'custom',
            itemStyle: {
              color: '${getJavascriptSeriesColor(Series.SenseOfHome)}'
            },
            renderItem: renderCircle            
          }
          ,{
            id: 'd',
            name: '${getSeriesName(context,Series.Loneliness)}',
            dimensions: ['Datum','${getSeriesName(context,Series.Loneliness)}'],
            type: 'custom',
            itemStyle: {
              color: '${getJavascriptSeriesColor(Series.Loneliness)}'
            },
            renderItem: renderCircle            
          }
          ]
        }
        ''',
        extraScript:
        '''
          let renderCircle = function(param,api) {
            let timestamp = api.value(0);
            let c = api.coord([timestamp,api.value(1)]);
            let x = c[0];
            let y = c[1];
            let src = chart.getOption().dataset[0].source;
            let item = src[param.dataIndex];
            let circleObject = {
              type: 'circle',
              x: x,
              y: y,
              z: 9,
              style: api.style(),
              shape: {
                cx: 0,
                cy: 0,
                r: 10
              } 
            };
            let obj = circleObject;

            // add line, unless it is an end point
            if (param.dataIndexInside > 0 && param.dataIndexInside < param.dataInsideLength) {
              let style = api.style();
              let prevItem = src[param.dataIndex-1];
              let prevCoord = api.coord([prevItem.Datum,prevItem[param.seriesName]]);
              let lineObject = {
                type: 'line',
                x: x,
                y: y,
                z: 8,
                style: {
                  fill: style.fill,
                  stroke: style.fill,
                  lineWidth: 2
                },
                shape: {
                  x1: prevCoord[0]-x,
                  y1: prevCoord[1]-y,
                  x2: 0,
                  y2: 0
                }
              };
              obj = {
                type: 'group',
                children: [
                  obj,
                  lineObject
                ]
              };
            }
            // if no information, then return
            if (item.information.every((el) => el.length==0)) {
              return obj;
            } 
            
            // add information indicator
            let textObject = {
              type: 'text',
              x: x,
              y: y,
              z: 10,
              style: {
                text: 'i',
                textAlign: 'center',
                textVerticalAlign: 'middle',
                stroke: 'white',
                fill: 'white',
                font: '10px'
              }            
            };
            let groupObject = {
              type: 'group',
              children: [
                obj,
                textObject
               ]
            };
            return groupObject; 
          };

          // when data is loaded, show last 7 days!          
          let firstRenderingWithData = true;
          chart.on('rendered',function(e) { 

            if (firstRenderingWithData && chart.getOption().dataset[0].source.length>1) { 
              firstRenderingWithData = false; 
              let start = 100.0-7*100/chart.getOption().dataset[0].source.length;
              let start2 = 93;
              chart.setOption({
                dataZoom: {
                  start: start2
                }
              }); 
            }
          });
          chart.on('click',(params) => {
            if (params.componentType == 'series') {
              let msg = {
                type: 'select',
                seriesName: params.seriesName,
                seriesIndex: params.seriesIndex,
                dataIndex: params.dataIndex
              };
              let msgAsString = JSON.stringify(msg);
              console.log('msg = '+msgAsString); 
              Messager.postMessage(msgAsString);
            }
          });
          
          /*chart.on('datazoom',eh);*/
        '''

    ));
  }
}
