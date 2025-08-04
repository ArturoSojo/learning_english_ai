import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/app/routes/router.dart';
import 'package:learning_english_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto_route/annotations.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/chat_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/ai_call_screen.dart';

import 'package:flutter/animation.dart';
import 'package:lottie/lottie.dart'; // Añade este import

@RoutePage()
class HomeScreen extends StatefulWidget {
  // Cambia de Stateless a StatefulWidget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final double _targetProgress = 0.68;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _progressAnimation = Tween<double>(begin: 0, end: _targetProgress).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hello,David Jhon',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Progress',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  AnimatedBuilder(
                    // Widget que reconstruye con cada animación
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: _progressAnimation.value,
                              strokeWidth: 8,
                              backgroundColor: Colors.white24,
                              valueColor:
                                  AlwaysStoppedAnimation(colorScheme.primary),
                            ),
                          ),
                          Text(
                            '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                  // ... (resto del código)
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Your English Tools",
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                      context, 'Practice Speaking', Icons.record_voice_over),
                  _buildCard(context, 'Grammar Lessons', Icons.menu_book),
                  _buildCard(context, 'Vocabulary Builder', Icons.translate),
                  _buildCard(context, 'Conversation Chat', Icons.chat),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorScheme.background,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 80, // Ajusta el tamaño según necesites
        height: 80,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AiCallScreen(),
              ),
            );
          },
          child: Lottie.asset(
            'assets/images/Siri.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            frameRate: FrameRate.max,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 🔧 Eliminado Expanded para evitar overflow
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Improve your English by chatting with your AI tutor.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.arrow_forward, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
