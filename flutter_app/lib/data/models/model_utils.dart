class ModelUtils {
  ModelUtils._();

  static int boolToInt(bool value) => value ? 1 : 0;

  static bool intToBool(int value) => value == 1;

  static String dateToText(DateTime value) => value.toUtc().toIso8601String();

  static DateTime textToDate(String value) => DateTime.parse(value).toUtc();
}
