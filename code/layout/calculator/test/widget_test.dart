import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/main.dart';

void main() async {
  testWidgets('5 press test', (WidgetTester tester) async {// (1)
    await tester.pumpWidget(new MyApp()); // (2)

    expect(find.text('5'), findsOneWidget);// (3)

    await tester.tap(find.text('5'));// (4)
    await tester.pump();// (5)

    expect(find.text('5'), findsNWidgets(2));// (6)
  });
  testWidgets('grid existence test', (WidgetTester tester) async {
  	await tester.pumpWidget(new MyApp());

    expect(find.text('0'), findsNWidgets(2));// (7)

  	for(int i = 1; i < 10; i++) { // (8)
  		expect(find.text('$i'), findsOneWidget);
  	}

  	['+', '-', 'x', '<-', 'C'].forEach(
      (str) => expect(find.text(str), findsOneWidget)
    ); // (9)

    expect(find.byElementPredicate((element) {// (10)
      if(!(element.widget is Image))
        return false;
      else if(
        (element.widget as Image).image
        ==
        AssetImage("icons/divide.png")
      )
        return true;
      else return false;
    }), findsOneWidget);

  });

}
