import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BeforeAfterTrailGame extends StatefulWidget {
  const BeforeAfterTrailGame({
    super.key,
    required this.learnerName,
    required this.onWin,
  });

  final String learnerName;
  final VoidCallback onWin;

  @override
  State<BeforeAfterTrailGame> createState() => _BeforeAfterTrailGameState();
}

class _PictureItem {
  const _PictureItem(this.name, this.path);
  final String name;
  final String path;
}

class _BeforeAfterTrailGameState extends State<BeforeAfterTrailGame> {
  static const _animals = [
    _PictureItem('cat', 'assets/before_after/animals/cat.png'),
    _PictureItem('dog', 'assets/before_after/animals/dog.png'),
    _PictureItem('lion', 'assets/before_after/animals/lion.png'),
    _PictureItem('elephant', 'assets/before_after/animals/elephant.png'),
    _PictureItem('panda', 'assets/before_after/animals/panda.png'),
    _PictureItem('giraffe', 'assets/before_after/animals/giraffe.png'),
    _PictureItem('zebra', 'assets/before_after/animals/zebra.png'),
    _PictureItem('monkey', 'assets/before_after/animals/monkey.png'),
    _PictureItem('koala', 'assets/before_after/animals/koala.png'),
    _PictureItem('tiger', 'assets/before_after/animals/tiger.png'),
    _PictureItem('bear', 'assets/before_after/animals/bear.png'),
    _PictureItem('pig', 'assets/before_after/animals/pig.png'),
    _PictureItem('sheep', 'assets/before_after/animals/sheep.png'),
    _PictureItem('horse', 'assets/before_after/animals/horse.png'),
    _PictureItem('penguin', 'assets/before_after/animals/penguin.png'),
    _PictureItem('dolphin', 'assets/before_after/animals/dolphin.png'),
    _PictureItem('turtle', 'assets/before_after/animals/turtle.png'),
    _PictureItem('frog', 'assets/before_after/animals/frog.png'),
    _PictureItem('parrot', 'assets/before_after/animals/parrot.png'),
    _PictureItem('whale', 'assets/before_after/animals/whale.png'),
    _PictureItem('shark', 'assets/before_after/animals/shark.png'),
  ];
  static const _shapes = [
    _PictureItem('circle', 'assets/before_after/shapes/circle.png'),
    _PictureItem('square', 'assets/before_after/shapes/square.png'),
    _PictureItem('triangle', 'assets/before_after/shapes/triangle.png'),
    _PictureItem('star', 'assets/before_after/shapes/star.png'),
    _PictureItem('heart', 'assets/before_after/shapes/heart.png'),
    _PictureItem('diamond', 'assets/before_after/shapes/diamond.png'),
    _PictureItem('rectangle', 'assets/before_after/shapes/rectangle.png'),
    _PictureItem('oval', 'assets/before_after/shapes/oval.png'),
  ];

  final _random = Random();
  late List<_PictureItem> _row;
  bool _animalsMode = true;
  bool _askBefore = true;
  bool _waiting = false;
  int _score = 0;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _makeRow();
  }

  void _makeRow() {
    final pool = [...(_animalsMode ? _animals : _shapes)]..shuffle(_random);
    _row = pool.take(3).toList();
    _askBefore = _random.nextBool();
    _waiting = false;
    _feedback = '';
  }

  void _setMode(bool animals) {
    setState(() {
      _animalsMode = animals;
      _score = 0;
      _makeRow();
    });
  }

  Future<void> _choose(int index) async {
    if (_waiting || _score >= 10) return;
    final correctIndex = _askBefore ? 0 : 2;
    if (index != correctIndex) {
      HapticFeedback.mediumImpact();
      setState(() {
        _feedback = _askBefore
            ? 'BEFORE means go LEFT ← from ${_row[1].name}. Try again!'
            : 'AFTER means go RIGHT → from ${_row[1].name}. Try again!';
      });
      return;
    }
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _waiting = true;
      _score++;
      _feedback = _askBefore
          ? 'Yes! ${_row[0].name} is BEFORE ${_row[1].name}. ←'
          : 'Yes! ${_row[2].name} is AFTER ${_row[1].name}. →';
    });
    if (_score == 10) {
      widget.onWin();
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() => _makeRow());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8ED),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFF8ED),
      title: const Text('Before & After Trail'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Chip(
            avatar: const Icon(Icons.star_rounded, color: Colors.orange),
            label: Text('$_score / 10'),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.pets_rounded),
                      label: Text('Animals'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.category_rounded),
                      label: Text('Shapes'),
                    ),
                  ],
                  selected: {_animalsMode},
                  onSelectionChanged: (value) => _setMode(value.first),
                ),
                const SizedBox(height: 18),
                if (_score < 10)
                  _QuestionPanel(
                    askBefore: _askBefore,
                    referenceName: _row[1].name,
                  )
                else
                  _WinPanel(
                    name: widget.learnerName,
                    onAgain: () => _setMode(_animalsMode),
                  ),
                if (_score < 10) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        for (var i = 0; i < _row.length; i++) ...[
                          Expanded(
                            child: _PictureChoice(
                              key: Key('before-after-choice-$i'),
                              item: _row[i],
                              position: i,
                              enabled: !_waiting,
                              onTap: () => _choose(i),
                            ),
                          ),
                          if (i < 2) const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ),
                  if (_feedback.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _feedback,
                        key: ValueKey(_feedback),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF514963),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.askBefore, required this.referenceName});
  final bool askBefore;
  final String referenceName;
  @override
  Widget build(BuildContext context) {
    final color = askBefore ? const Color(0xFF2563C9) : const Color(0xFFE5484D);
    return Container(
      key: const Key('before-after-question'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            askBefore ? 'BEFORE' : 'AFTER',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${askBefore ? '←' : '→'}  Click the picture ${askBefore ? 'before' : 'after'} ${referenceName.toUpperCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            askBefore ? 'Go LEFT ←' : 'Go RIGHT →',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PictureChoice extends StatelessWidget {
  const _PictureChoice({
    super.key,
    required this.item,
    required this.position,
    required this.enabled,
    required this.onTap,
  });
  final _PictureItem item;
  final int position;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: enabled,
    label: '${item.name}, position ${position + 1}',
    child: Card(
      elevation: position == 1 ? 7 : 2,
      color: position == 1 ? const Color(0xFFFFF2BE) : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onTap: enabled ? onTap : null,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                item.path,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Text(
                position == 1
                    ? 'START: ${item.name.toUpperCase()}'
                    : item.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: position == 1
                      ? const Color(0xFF7A5800)
                      : const Color(0xFF29213F),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Banner extends StatelessWidget {
  const _Banner({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.detail,
    this.buttonLabel,
    this.onPressed,
  });
  final Color color;
  final IconData icon;
  final String title, detail;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 48),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(detail, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        if (onPressed != null) ...[
          const SizedBox(width: 12),
          FilledButton.tonal(
            key: const Key('lesson-next'),
            onPressed: onPressed,
            child: Text(buttonLabel!),
          ),
        ],
      ],
    ),
  );
}

class _WinPanel extends StatelessWidget {
  const _WinPanel({required this.name, required this.onAgain});
  final String name;
  final VoidCallback onAgain;
  @override
  Widget build(BuildContext context) => _Banner(
    key: const Key('before-after-complete'),
    color: const Color(0xFF00A884),
    icon: Icons.emoji_events_rounded,
    title: 'You understand before and after, $name!',
    detail: 'BEFORE is left. AFTER is right. Wonderful work!',
    buttonLabel: 'Play again',
    onPressed: onAgain,
  );
}
