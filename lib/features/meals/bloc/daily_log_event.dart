abstract class DailyLogEvent {
  const DailyLogEvent();
}

class LoadDailyLog extends DailyLogEvent {
  const LoadDailyLog(this.date);
  final DateTime date;
}

class DeleteMeal extends DailyLogEvent {
  const DeleteMeal(this.mealId, this.date);
  final String mealId;
  final DateTime date;
}
