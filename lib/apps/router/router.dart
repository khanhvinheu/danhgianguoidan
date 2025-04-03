import 'package:evaluate_app/pages/chart/chart_page.dart';
import 'package:evaluate_app/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:evaluate_app/pages/home/home_page.dart';
import 'package:evaluate_app/pages/chart/table_page.dart';


class RouterCustorm {
  /// The route configuration.
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouterName.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'home',
            name: RouterName.home,
            builder: (BuildContext context, GoRouterState state) {
              return HomePage();
            },
          ),
          GoRoute(
            path: 'chart',
            name: RouterName.chart,
            builder: (BuildContext context, GoRouterState state) {
              return ChartPage();
            },
          ),
          GoRoute(
            path: 'table',
            name: RouterName.table,
            builder: (BuildContext context, GoRouterState state) {
              return TablePage();
            },
          ),
        ],
      ),
     
    ],
  );
}
