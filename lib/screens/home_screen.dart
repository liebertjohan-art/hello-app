import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/ai_difficulty.dart';
import '../widgets/heart_footer_widget.dart';
import '../widgets/history_sheet_widget.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final GameState _sharedGameState = GameState();
  AIDifficulty _selectedDifficulty = AIDifficulty.hard;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame(GameMode mode) {
    _sharedGameState.setAIDifficulty(_selectedDifficulty);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          mode: mode,
          gameState: _sharedGameState,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with History Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151928),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.gamepad_outlined, color: Color(0xFF00F2FE), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'v2.0 CYBER',
                          style: TextStyle(
                            color: Color(0xFF00F2FE),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History Button
                  ListenableBuilder(
                    listenable: _sharedGameState,
                    builder: (context, _) {
                      final historyCount = _sharedGameState.totalGames;
                      return OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: const Color(0xFF151928),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          HistorySheetWidget.show(context, _sharedGameState);
                        },
                        icon: const Icon(Icons.history, size: 18, color: Color(0xFFFFD700)),
                        label: Text(
                          historyCount > 0 ? 'History ($historyCount)' : 'History',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main Hero Badge
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF151928),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00F2FE).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00F2FE).withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_3x3_rounded,
                                size: 56,
                                color: Color(0xFF00F2FE),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Gradient Title
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF00F2FE), Color(0xFFFF007A)],
                              ).createShader(bounds),
                              child: const Text(
                                'TIC TAC TOE',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Modern Playful Edition',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Game Mode Cards
                            _buildModeCard(
                              title: '2 Players Mode',
                              subtitle: 'Play pass-and-play with a friend',
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF00F2FE),
                              onTap: () => _startGame(GameMode.twoPlayer),
                            ),
                            const SizedBox(height: 16),

                            _buildModeCard(
                              title: 'Play vs AI Bot',
                              subtitle: 'Test your tactical skills vs AI',
                              icon: Icons.smart_toy_rounded,
                              color: const Color(0xFFFF007A),
                              onTap: () => _startGame(GameMode.vsAI),
                              extraContent: _buildDifficultySelector(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer Signature
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0, top: 8.0),
              child: HeartFooterWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? extraContent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151928),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 28, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
                if (extraContent != null) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  const SizedBox(height: 14),
                  extraContent,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AI DIFFICULTY',
              style: TextStyle(
                color: Color(0xFF8E9AAF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              _selectedDifficulty.description,
              style: TextStyle(
                color: _selectedDifficulty.color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: AIDifficulty.values.map((diff) {
            final isSelected = _selectedDifficulty == diff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = diff;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? diff.color.withOpacity(0.2)
                          : const Color(0xFF0B0E17),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? diff.color : Colors.white.withOpacity(0.08),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(diff.icon, size: 14, color: diff.color),
                        const SizedBox(width: 6),
                        Text(
                          diff.label,
                          style: TextStyle(
                            color: isSelected ? diff.color : const Color(0xFF8E9AAF),
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
