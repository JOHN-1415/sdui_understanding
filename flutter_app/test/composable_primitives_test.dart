import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_mobile_app/models/sdui_models.dart';
import 'package:sdui_mobile_app/widgets/sdui_parser.dart';

void main() {
  testWidgets('Approach 1: Composable Restaurant Card (Le Smash) builds and displays all elements', (WidgetTester tester) async {
    final componentJson = {
      'id': 'test_le_smash',
      'type': 'container',
      'styles': {
        'backgroundColor': '#FFFFFF',
        'borderRadius': 20.0,
      },
      'children': [
        {
          'id': 'le_smash_stack',
          'type': 'stack',
          'children': [
            {
              'id': 'le_smash_title_row',
              'type': 'row',
              'children': [
                {
                  'id': 'le_smash_name',
                  'type': 'text',
                  'props': {'text': 'Le Smash', 'fontSize': 22.0, 'color': '#FFFFFF'},
                },
                {
                  'id': 'le_smash_rating',
                  'type': 'badge',
                  'props': {'text': '4.7', 'icon': 'star', 'backgroundColor': '#0B6B38', 'textColor': '#FFFFFF'},
                }
              ]
            }
          ]
        },
        {
          'id': 'le_smash_details',
          'type': 'column',
          'children': [
            {
              'id': 'le_smash_cuisine',
              'type': 'text',
              'props': {'text': 'Asian • Italian', 'color': '#64748B'},
            },
            {
              'id': 'pill1_text',
              'type': 'text',
              'props': {'text': 'Flat 10% off on walk-in', 'color': '#FFFFFF'},
            },
            {
              'id': 'promo_text',
              'type': 'text',
              'props': {'text': 'Get extra ₹125 off using PAYTMNEW', 'color': '#4F46E5'},
            }
          ]
        }
      ]
    };

    final comp = SDUIComponent.fromJson(componentJson);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => SDUIParser.buildWidget(context, comp),
          ),
        ),
      ),
    );

    expect(find.text('Le Smash'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('Asian • Italian'), findsOneWidget);
    expect(find.text('Flat 10% off on walk-in'), findsOneWidget);
    expect(find.text('Get extra ₹125 off using PAYTMNEW'), findsOneWidget);
  });

  testWidgets('Approach 1: Composable Grocery Card (Go Zero) builds with dashed divider and price', (WidgetTester tester) async {
    final componentJson = {
      'id': 'test_go_zero',
      'type': 'container',
      'children': [
        {
          'id': 'grocery_delivery_time',
          'type': 'text',
          'props': {'text': '26 MINS', 'color': '#71717A'},
        },
        {
          'id': 'grocery_title',
          'type': 'text',
          'props': {'text': 'Go Zero Only Vanilla Guilt Free...', 'color': '#18181B'},
        },
        {
          'id': 'grocery_unit',
          'type': 'text',
          'props': {'text': '1 ltr', 'color': '#52525B'},
        },
        {
          'id': 'grocery_discount_row',
          'type': 'row',
          'children': [
            {
              'id': 'discount_text',
              'type': 'text',
              'props': {'text': '14% OFF', 'color': '#059669'},
            },
            {
              'id': 'dashed_line',
              'type': 'divider',
              'props': {'dashed': true, 'expanded': true},
            }
          ]
        },
        {
          'id': 'grocery_price_row',
          'type': 'row',
          'children': [
            {
              'id': 'price',
              'type': 'text',
              'props': {'text': '₹212', 'color': '#18181B'},
            },
            {
              'id': 'orig_price',
              'type': 'text',
              'props': {'text': '₹249', 'color': '#94A3B8', 'decoration': 'lineThrough'},
            }
          ]
        }
      ]
    };

    final comp = SDUIComponent.fromJson(componentJson);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => SDUIParser.buildWidget(context, comp),
          ),
        ),
      ),
    );

    expect(find.text('26 MINS'), findsOneWidget);
    expect(find.text('Go Zero Only Vanilla Guilt Free...'), findsOneWidget);
    expect(find.text('1 ltr'), findsOneWidget);
    expect(find.text('14% OFF'), findsOneWidget);
    expect(find.byType(DashedDivider), findsOneWidget);
    expect(find.text('₹212'), findsOneWidget);
    expect(find.text('₹249'), findsOneWidget);
  });
}
