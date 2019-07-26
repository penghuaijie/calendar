
import 'package:flutter_calendar/time_utils.dart';

class YearMonthModel {
  int year;
  int month;

  YearMonthModel(this.year, this.month);
}

class DayModel {
  int year;
  int month;
  int dayNum; // 数字类型的几号
  String day; // 字符类型的几号
  bool isSelect; // 是否选中
  bool isOverdue; // 是否过期
  DayModel(this.year, this.month, this.dayNum, this.day, this.isSelect, this.isOverdue);
}

class CalendarItemViewModel {
  final List<DayModel> list;
  final int year;
  final int month;
  DayModel firstSelectModel;
  DayModel lastSelectModel;
  CalendarItemViewModel({this.list, this.year, this.month, this.firstSelectModel, this.lastSelectModel});
}

class CalendarViewModel {

  List<YearMonthModel> yearMonthList = CalendarViewModel.getYearMonthList();

  List<CalendarItemViewModel> getItemList() {
    List<CalendarItemViewModel> _list = [];
    yearMonthList.forEach((model){
      List<DayModel> dayModelList = getDayModelList(model.year, model.month);
      _list.add(CalendarItemViewModel(list:dayModelList,year: model.year, month:model.month));
    });
    return _list;
  }

  static List<DayModel> getDayModelList(int year, int month) {
    List<DayModel> _listModel = [];
    // 今天几号
    int  _currentDay = DateTime.now().day;
    // 今天在几月
    int _currentMonth = DateTime.now().month;
    // 当前月的天数
    int _days = TimeUtil.getDaysInMonth(year, month);

    String _day = '';
    bool _isSelect = false;
    bool isOverdue = false;
    int _dayNum = 0;
    for (int i = 1; i <= _days; i++) {
      _dayNum = i;
      if (_currentMonth == month) {
        //在当前月
        if (i < _currentDay) {
          isOverdue = true;
          _day = '$i';
        } else if (i == _currentDay) {
          _day = '今';
          isOverdue = false;
        } else {
          _day = '$i';
          isOverdue = false;
        }
      } else {
        _day = '$i';
        isOverdue = false;
      }
      DayModel dayModel = DayModel(year, month, _dayNum, _day, _isSelect, isOverdue);
      _listModel.add(dayModel);
    }
    return _listModel;
  }

  /*
  * 根据当前年月份计算 下面6个月的年月
  * */
  static List<YearMonthModel> getYearMonthList() {
    int _month = DateTime.now().month;
    int _year = DateTime.now().year;

    List<YearMonthModel> _yearMonthList = <YearMonthModel>[];
    for(int i=0; i<6; i++) {
      YearMonthModel model = YearMonthModel(_year, _month);
      _yearMonthList.add(model);
      if(_month == 12) {
        _month = 1;
        _year ++;

      } else {
        _month ++;
      }
    }
    return _yearMonthList;
  }

}