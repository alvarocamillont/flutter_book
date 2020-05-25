import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/calculator.dart';

var calc = Calculation();

void main() {
  setUp(() {
    calc = Calculation();
  });
  test('simple addition', () {
    calc.add("5");
    calc.add("+");
    calc.add("6");
    calc.add("5");
    expect(calc.getResult(), 70.0);
  });
  test('more sums', () {
    calc.add("5");
    calc.add("5");
    calc.add("-");
    calc.add("5");
    calc.add("+");
    calc.add("50");
    expect(calc.getResult(), 100.0);
  });
  test('simple multiplication', () {
    calc.add("5");
    calc.add("x");
    calc.add("6");
    expect(calc.getResult(), 30.0);
  });
  test('division', () {
    calc.add("5");
    calc.add("÷");
    calc.add("2");
    expect(calc.getResult(), 2.5);
  });
  test('precedence', () {
    calc.add("5");
    calc.add("+");
    calc.add("6");
    calc.add("x");
    calc.add("5");
    expect(calc.getResult(), 35.0);
  });
  test('string', () {
    calc.add("5");
    calc.add("x");
    calc.add("6");
    calc.add("+");
    calc.add("7");
    expect(calc.getString().toString(), "5x6+7");
  });
}
