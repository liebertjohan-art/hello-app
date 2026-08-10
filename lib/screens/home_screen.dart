import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/ai_difficulty.dart';
import '../widgets/heart_footer_widget.dart';
import '../widgets/history_sheet_widget.dart';
import '../widgets/tactile_button.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GameState _sharedGameState = GameState();
  AIDifficulty _selectedDifficulty = AIDifficulty.hard;
  
  late final AnimationController _staggerController;
  late final List<Animation<double>> _scaleAnimations;
  late final List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimations = [];
    _opacityAnimations = [];

    for (int i = 0; i < 4; i++) {
      final double start = i * 0.15;
      final double end = (start + 0.55).clamp(0.0, 1.0);
      
      _scaleAnimations.add(
        Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: const Cubic(0.23, 1.0, 0.32, 1.0)),
          ),
        ),
      );
      
      _opacityAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _startGame(GameMode mode) {
    _sharedGameState.setAIDifficulty(_selectedDifficulty);
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
          mode: mode,
          gameState: _sharedGameState,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    ).then((_) {
      setState(() {});
    });
  }

  Widget _buildStaggeredItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: Opacity(
            opacity: _opacityAnimations[index].value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _buildStaggeredItem(0, _buildTopBar()),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5, 
                          child: _buildStaggeredItem(1, _buildPrimaryCard()),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          flex: 3, 
                          child: _buildStaggeredItem(2, _buildSecondaryCard()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildStaggeredItem(3, const HeartFooterWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CYBERTAE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'SYS.VER.2.0',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF00F2FE),
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        ListenableBuilder(
          listenable: _sharedGameState,
          builder: (context, _) {
            final historyCount = _sharedGameState.totalGames;
            return TactileButton(
              onTap: () => HistorySheetWidget.show(context, _sharedGameState),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      historyCount > 0 ? 'HISTORY ($historyCount)' : 'HISTORY',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrimaryCard() {
    return TactileButton(
      onTap: () => _startGame(GameMode.vsAI),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0C10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F2FE).withOpacity(0.05),
                blurRadius: 40,
                offset: const Offset(0, 10),
              )
            ]
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF00F2FE)),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white30, size: 20),
                ],
              ),
              const Spacer(),
              const Text(
                'NEURAL NET AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'TEST TACTICS AGAINST THE MACHINE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildDifficultySelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCard() {
    return TactileButton(
      onTap: () => _startGame(GameMode.twoPlayer),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0C10),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LOCAL PVP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PASS & PLAY MODULE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_alt_rounded, color: Colors.white70),
              ),
            ],
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
              'DIFFICULTY THRESHOLD',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                _selectedDifficulty.description,
                key: ValueKey(_selectedDifficulty),
                style: TextStyle(
                  color: _selectedDifficulty.color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: AIDifficulty.values.map((diff) {
            final isSelected = _selectedDifficulty == diff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: TactileButton(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = diff;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? diff.color.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? diff.color.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        diff.label,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isSelected ? diff.color : Colors.white54,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
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
