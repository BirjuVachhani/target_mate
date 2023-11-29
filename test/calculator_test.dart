import 'package:flutter_test/flutter_test.dart';
import 'package:target_mate/utils/calculator.dart';

void main() {
  group('calculateDaysRemainingFor tests', () {
    // generate tests
    List<int> effectiveDays = [];

    void resetEffectiveDays() =>
        effectiveDays = List.generate(30, (index) => index + 1);

    setUp(() {
      resetEffectiveDays();
    });

    int calculateFor(int day, {bool include = true}) =>
        Calculator.calculateDaysRemainingFor(
          getDateForDay(day),
          effectiveDays.map((day) => getDateForDay(day)),
          includeTargetDate: include,
        );

    test('when target is in effective days', () {
      expect(calculateFor(15), 16);
      expect(calculateFor(15, include: false), 15);

      expect(calculateFor(28), 3);
      expect(calculateFor(28, include: false), 2);
    });

    test('when target is not in effective days', () {
      effectiveDays.remove(15);
      expect(calculateFor(15), 15);
      expect(calculateFor(15, include: false), 15);

      resetEffectiveDays();
      effectiveDays.remove(28);
      expect(calculateFor(28), 2);
      expect(calculateFor(28, include: false), 2);
    });

    test('when effective days do not have some days', () {
      effectiveDays.remove(20);
      expect(calculateFor(10), 20);
      expect(calculateFor(10, include: false), 19);
    });

    tearDown(() => effectiveDays.clear());
  });
}

DateTime getDateForDay(int day) => DateTime(2023, 11, day);
