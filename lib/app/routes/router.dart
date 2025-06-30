import 'package:auto_route/auto_route.dart';
import 'package:auto_route/annotations.dart'; // NECESARIO
import 'package:flutter/foundation.dart';
import 'package:learning_english_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/chat_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/home_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig() // USAR ESTO EN LUGAR DE @AutoRouter si usas injectable
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: ChatRoute.page),
      ];
}
