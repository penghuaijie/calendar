import 'package:flutter/material.dart';
import 'package:flutter_calendar/toast_widget.dart';
import 'package:flutter_color_plugin/flutter_color_plugin.dart';

import 'calendar_page_viewModel.dart';
import 'calendar_widget.dart';

/*
* Location 标记当前选中日期和之前的日期相比，
* left： 是在之前日期之前
* mid：  和之前日期相等
* right：在之前日期之后
* */
enum Location{left,mid,right}

typedef void SelectDateOnTap(DayModel checkInTimeModel, DayModel leaveTimeModel);

class CalendarPage extends StatefulWidget {
  final DayModel startTimeModel;// 外部传入的之前选中的入住日期
  final DayModel endTimeModel;// 外部传入的之前选中的离开日期
  final SelectDateOnTap selectDateOnTap;// 确定按钮的callback 给外部传值
  CalendarPage({this.startTimeModel,this.endTimeModel,this.selectDateOnTap});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  String _selectCheckInTime = '选择入住时间';
  String _selectLeaveTime = '选择离开时间';
  bool _isSelectCheckInTime = false; // 是否选择入住日期
  bool _isSelectLeaveTime = false; // 是否选择离开日期
  int _checkInDays = 0; // 入住天数

  // 保存当前选中的入住日期和离开日期
  DayModel _selectCheckInTimeModel = null;
  DayModel _isSelectLeaveTimeModel = null;

  List<CalendarItemViewModel> _list = [];
  @override
  void initState() {
    super.initState();
    // 加载日历数据源
    _list = CalendarViewModel().getItemList();
    // 处理外部传入的选中日期
    if(widget.startTimeModel!=null && widget.endTimeModel!=null) {
      for(int i=0; i<_list.length; i++) {
        CalendarItemViewModel model = _list[i];
        if(model.month == widget.startTimeModel.month) {
          _updateDataSource(widget.startTimeModel.year, widget.startTimeModel.month, widget.startTimeModel.dayNum);
        }
        if (model.month == widget.endTimeModel.month) {
          _updateDataSource(widget.endTimeModel.year, widget.endTimeModel.month, widget.endTimeModel.dayNum);
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    // 屏幕宽高
    final screenHeight = data.size.height;
    final screenWidth = data.size.width;
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      height: screenHeight,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                height: 86,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  // 择入住时间的视图
                  _selectTimeItem(context, _selectCheckInTime,
                      Alignment.centerLeft, _isSelectCheckInTime),
                  // 入住天数的视图
                  _daysItem(_checkInDays),
                  // 选择离开时间的视图
                  _selectTimeItem(context, _selectLeaveTime,
                      Alignment.centerRight, _isSelectLeaveTime),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),

              // 月日期的视图
              Container(
                height: screenHeight - 64 - 80 - 83 - 30,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    CalendarItemViewModel itemModel = _list[index];
                    return CalendarItem(
                      (year, month, checkInTime) {
                        _updateCheckInLeaveTime(
                            year, month, checkInTime);
                      },
                      itemModel,
                    );
                  },
                  itemCount: _list.length,
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).padding.bottom,
            child: Container(),
          ),
          _bottonSureButton(screenWidth),
        ],
      ),
    );
  }

  /*
  * content 显示的日期
  * alignment 用来控制文本的对齐方式
  * isSelectTime 是否选择了日期
  * */
  _selectTimeItem(BuildContext context, String content, Alignment alignment,
      bool isSelectTime) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: (screenWidth - 40 - 30) / 2,
      height: 30,
      alignment: alignment,
      child: Text(
        content,
        style: TextStyle(
          fontFamily: isSelectTime ? 'Avenir-Heavy' : 'PingFangSC-Regular',
          fontSize: isSelectTime ? 22 : 18,
          color: isSelectTime
              ? ColorUtil.color('212121')
              : ColorUtil.color('BDBDBD'),
        ),
      ),
    );
  }

  /*
  * day 入住天数，默认不选择为0
  * */
  _daysItem(int day) {
    return Container(
      width: 30,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 0.5, color: ColorUtil.color('BDBDBD')),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      child: Text(
        '$day晚',
        style: TextStyle(
          color: ColorUtil.color('BDBDBD'),
          fontSize: 12,
        ),
      ),
    );
  }

  /*
  * 底部确定按钮
  * */
  _bottonSureButton(double screenWidth) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom,
      height: 80,
      child: Container(
        height: 80,
        width: double.maxFinite,
        color: Colors.white,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: _sureButtonTap,
          child: Container(
            height: 48,
            width: screenWidth - 30,
            decoration: BoxDecoration(
              color: ColorUtil.color('FED836'),
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
            ),
            child: Center(
              child: Text(
                '确定',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'PingFangSC-Light',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /*
  * 比较后面的日期是比model日期小（left） 还是相等(mid) 还是大 (right)
  * */
  _comparerTime(DayModel model, int year, int month, int day){
    if(year > model.year) {
      return Location.right;
    } else if(year == model.year) {
      if(model.month < month) {
        return Location.right;
      } else if(model.month == month){
        if(model.dayNum < day){
          return Location.right;
        } else if(model.dayNum == day){
          return Location.mid;
        } else {
          return Location.left;
        }
      } else {
        return Location.right;
      }
    } else {
      return Location.left;
    }
  }

  /*
  * 更新日历的数据源
  * */
  _updateDataSource(int year, int month, int checkInTime) {
    // 左右指针 用来记录选择的入住日期和离开日期
    DayModel firstModel = null ;
    DayModel lastModel = null;

    for(int i=0; i<_list.length; i++) {
      CalendarItemViewModel model = _list[i];
      if(model.firstSelectModel != null){
        firstModel = model.firstSelectModel;
      }
      if (model.lastSelectModel != null) {
        lastModel = model.lastSelectModel;
      }
    }

    if (firstModel != null && lastModel != null) {
      for(int i=0; i<_list.length; i++) {
        CalendarItemViewModel model = _list[i];
        model.firstSelectModel = null;
        model.lastSelectModel = null;
        firstModel = null;
        lastModel = null;
        for(int i=0; i<model.list.length; i++) {
          DayModel dayModel = model.list[i];
          dayModel.isSelect = false;
          if(_comparerTime(dayModel, year, month, checkInTime) == Location.mid){
            dayModel.isSelect = true;
            model.firstSelectModel = dayModel;
            _isSelectCheckInTime = true;
            _isSelectLeaveTime = false;
            _selectCheckInTime = '$year.$month.$checkInTime';
            _selectCheckInTimeModel = dayModel;
          }
        }
      }
      _checkInDays = 0;
      _isSelectLeaveTime = false;
      _selectLeaveTime = '选择离开时间';
      _isSelectLeaveTimeModel = null;
    } else if(firstModel != null && lastModel == null) {
      if(_comparerTime(firstModel, year, month, checkInTime) == Location.left){
        for(int i=0; i<_list.length; i++) {
          CalendarItemViewModel model = _list[i];
          model.firstSelectModel = null;
          model.lastSelectModel = null;
          firstModel = null;
          lastModel = null;
          for(int i=0; i<model.list.length; i++) {
            DayModel dayModel = model.list[i];
            dayModel.isSelect = false;
            if(_comparerTime(dayModel, year, month, checkInTime) == Location.mid){
              dayModel.isSelect = !dayModel.isSelect;
              model.firstSelectModel = dayModel;
              _isSelectCheckInTime = dayModel.isSelect ? true : false;
              _selectCheckInTime = '$year.$month.$checkInTime';
              _selectCheckInTimeModel = dayModel;
            }
          }
        }
        _checkInDays = 0;
        _isSelectLeaveTime = false;
        _selectLeaveTime = '选择离开时间';
        _isSelectLeaveTimeModel = null;
      } else if(_comparerTime(firstModel, year, month, checkInTime) == Location.mid){//点击了自己
        for(int i=0; i<_list.length; i++) {
          CalendarItemViewModel model = _list[i];
          model.lastSelectModel = null;
          if(model.month == month){
            for(int i=0; i<model.list.length; i++) {
              DayModel dayModel = model.list[i];
              if(_comparerTime(dayModel, year, month, checkInTime) == Location.mid){
                dayModel.isSelect = !dayModel.isSelect;
                model.firstSelectModel = dayModel.isSelect ? dayModel : null;
                _selectCheckInTimeModel = dayModel.isSelect ? dayModel : null;
                _isSelectCheckInTime = dayModel.isSelect ? true : false;
                _selectCheckInTime = dayModel.isSelect ? '$year.$month.$checkInTime' : '选择入住时间';
              }
            }
          }
        }
        _checkInDays = 0;
        _isSelectLeaveTime = false;
        _selectLeaveTime = '选择离开时间';
        _isSelectLeaveTimeModel = null;
      } else if (_comparerTime(firstModel, year, month, checkInTime) == Location.right){
        if(month == firstModel.month){
          // 统计入住天数
          int _calculaterDays = 1;
          for(int i=0; i<_list.length; i++) {
            CalendarItemViewModel model = _list[i];
            if(model.month == month){
              for(int i=0; i<model.list.length; i++) {
                DayModel dayModel = model.list[i];
                if(dayModel.dayNum == checkInTime) {
                  dayModel.isSelect = true;
                  model.lastSelectModel = dayModel;
                  _isSelectLeaveTimeModel = dayModel;
                  _isSelectLeaveTime = true;
                  _selectLeaveTime = '$year.$month.$checkInTime';
                }else if(dayModel.dayNum > firstModel.dayNum && dayModel.dayNum<checkInTime){
                  dayModel.isSelect = true;
                  _calculaterDays++;
                }
              }
            }
          }
          _checkInDays = _calculaterDays;
        } else {
          // 统计入住天数
          int _calculaterDays = 1;
          for(int i=0; i<_list.length; i++) {
            CalendarItemViewModel model = _list[i];
            if(model.month == firstModel.month){
              for(int i=0; i<model.list.length; i++) {
                DayModel dayModel = model.list[i];
                if (dayModel.dayNum > firstModel.dayNum){
                  dayModel.isSelect = true;
                  _calculaterDays++;
                }
              }
            } else if(model.month>firstModel.month && model.month<month){
              for(int i=0; i<model.list.length; i++) {
                DayModel dayModel = model.list[i];
                dayModel.isSelect = true;
                _calculaterDays++;
              }
            } else if(month == model.month){
              for(int i=0; i<model.list.length; i++) {
                DayModel dayModel = model.list[i];
                if(dayModel.dayNum < checkInTime){
                  dayModel.isSelect = true;
                  _calculaterDays++;
                } else if (dayModel.dayNum == checkInTime) {
                  dayModel.isSelect = true;
                  model.lastSelectModel = dayModel;
                  _isSelectLeaveTimeModel = dayModel;
                  _isSelectLeaveTime = true;
                  _selectLeaveTime = '$year.$month.$checkInTime';
                }
              }
            }
          }
          _checkInDays = _calculaterDays;
        }
      }
    } else if(firstModel == null && lastModel == null){
      for(int i=0; i<_list.length; i++) {
        CalendarItemViewModel model = _list[i];
        model.firstSelectModel = null;
        model.lastSelectModel = null;
        firstModel = null;
        lastModel = null;
        for(int i=0; i<model.list.length; i++) {
          DayModel dayModel = model.list[i];
          dayModel.isSelect = false;
          if(_comparerTime(dayModel, year, month, checkInTime) == Location.mid){
            dayModel.isSelect = true;
            model.firstSelectModel = dayModel;
            _isSelectCheckInTime = true;
            _selectCheckInTimeModel = dayModel;
            _isSelectLeaveTime = false;
            _selectCheckInTime = '$year.$month.$checkInTime';
          }
        }
      }
    }
  }

  /*
  * 点击日期的回调事件
  * */
  _updateCheckInLeaveTime(int year, int month, int checkInTime) {
    // 更新数据源
    _updateDataSource(year, month, checkInTime);
    // 刷新UI
    setState(() {});
  }

  /*
  * 底部确定按钮的点击事件
  * */
  _sureButtonTap() {
    if(!_isSelectCheckInTime){
      ShowToast().showToast('请选择入住时间');
      return;
    } else if (!_isSelectLeaveTime){
      ShowToast().showToast('请选择离开时间');
      return;
    }
    print('${_selectCheckInTimeModel.year},${_selectCheckInTimeModel.month},${_selectCheckInTimeModel.dayNum}');
    print('${_isSelectLeaveTimeModel.year},${_isSelectLeaveTimeModel.month},${_isSelectLeaveTimeModel.dayNum}');
    print('入住日期：$_selectCheckInTime, 离开时间：$_selectLeaveTime, 共$_checkInDays晚');
    // 把日期回调给外部
    widget.selectDateOnTap(_selectCheckInTimeModel,_isSelectLeaveTimeModel);
    Navigator.pop(context);
  }
}
