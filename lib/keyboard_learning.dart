import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _purple = Color(0xFF6750D8);
const _ink = Color(0xFF29213F);
const _muted = Color(0xFF756E88);

class KeyboardLearningScreen extends StatefulWidget {
  const KeyboardLearningScreen({super.key, required this.learnerName});

  final String learnerName;

  @override
  State<KeyboardLearningScreen> createState() => _KeyboardLearningScreenState();
}

class _KeyboardLearningScreenState extends State<KeyboardLearningScreen> {
  int _stars = 0;
  final Set<int> _finishedGames = {};

  Future<void> _open(Widget game, int gameNumber) async {
    final won = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => game),
    );
    if (won == true && _finishedGames.add(gameNumber)) {
      setState(() => _stars += 3);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Keyboard Adventure'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Chip(
            avatar: const Icon(Icons.star_rounded, color: Colors.amber),
            label: Text('$_stars stars', key: const Key('keyboard-stars')),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, size) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.maxWidth < 650 ? 20 : 40,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeBanner(name: widget.learnerName),
                  const SizedBox(height: 30),
                  const Text(
                    'Choose your keyboard game',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start with letter keys, then type your first words!',
                    style: TextStyle(fontSize: 17, color: _muted),
                  ),
                  const SizedBox(height: 22),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: size.maxWidth < 900 ? 1 : 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: size.maxWidth < 900 ? 2.25 : 1.45,
                    children: [
                      _GameCard(
                        gameKey: const Key('key-explorer-game'),
                        number: '1',
                        icon: Icons.touch_app_rounded,
                        color: _purple,
                        title: 'Key Explorer',
                        description: 'Press keys and discover every letter.',
                        skill: 'Learn the keyboard',
                        completed: _finishedGames.contains(1),
                        onTap: () => _open(
                          KeyExplorerGame(learnerName: widget.learnerName),
                          1,
                        ),
                      ),
                      _GameCard(
                        gameKey: const Key('letter-hunt-game'),
                        number: '2',
                        icon: Icons.travel_explore_rounded,
                        color: const Color(0xFFEF5B83),
                        title: 'Letter Hunt',
                        description:
                            'Find the right letter before the rocket flies.',
                        skill: 'Accuracy game',
                        completed: _finishedGames.contains(2),
                        onTap: () => _open(
                          LetterHuntGame(learnerName: widget.learnerName),
                          2,
                        ),
                      ),
                      _GameCard(
                        gameKey: const Key('word-builder-game'),
                        number: '3',
                        icon: Icons.auto_stories_rounded,
                        color: const Color(0xFF00A884),
                        title: 'Word Builder',
                        description:
                            'Type cheerful words one letter at a time.',
                        skill: 'First words',
                        completed: _finishedGames.contains(3),
                        onTap: () => _open(
                          WordBuilderGame(learnerName: widget.learnerName),
                          3,
                        ),
                      ),
                      _GameCard(
                        gameKey: const Key('sequence-neighbor-game'),
                        number: '4',
                        icon: Icons.swap_horiz_rounded,
                        color: const Color(0xFF318CE7),
                        title: 'Before & After',
                        description:
                            'Find what comes before or after in ABC, 123 and Urdu.',
                        skill: 'Sequences',
                        completed: _finishedGames.contains(4),
                        onTap: () => _open(
                          SequenceNeighborGame(learnerName: widget.learnerName),
                          4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _ParentTip(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6750D8), Color(0xFF9B72EF)],
      ),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white24,
          child: Icon(Icons.keyboard_rounded, size: 38, color: Colors.white),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready, $name?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Your keyboard is a treasure map. Every key opens a new idea!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        const Text('🚀', style: TextStyle(fontSize: 50)),
      ],
    ),
  );
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.gameKey,
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.skill,
    required this.completed,
    required this.onTap,
  });
  final Key gameKey;
  final String number, title, description, skill;
  final IconData icon;
  final Color color;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    elevation: 3,
    child: InkWell(
      key: gameKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withValues(alpha: .14),
                  child: Icon(icon, color: color, size: 30),
                ),
                const Spacer(),
                if (completed)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00A884),
                  )
                else
                  Text(
                    number,
                    style: TextStyle(
                      color: color.withValues(alpha: .35),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              description,
              style: const TextStyle(color: _muted, height: 1.35),
            ),
            const SizedBox(height: 15),
            Chip(
              backgroundColor: color.withValues(alpha: .1),
              side: BorderSide.none,
              label: Text(
                skill,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ParentTip extends StatelessWidget {
  const _ParentTip();
  @override
  Widget build(BuildContext context) => const Card(
    color: Color(0xFFFFF4D8),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: Color(0xFFE49800)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Let your child use one finger first. Celebrate accuracy before speed!',
            ),
          ),
        ],
      ),
    ),
  );
}

class KeyExplorerGame extends StatefulWidget {
  const KeyExplorerGame({super.key, required this.learnerName});
  final String learnerName;
  @override
  State<KeyExplorerGame> createState() => _KeyExplorerGameState();
}

class _KeyExplorerGameState extends State<KeyExplorerGame> {
  final _focus = FocusNode();
  final Set<String> _found = {};
  String _letter = '?';

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _press(String value) {
    final letter = value.toUpperCase();
    if (!RegExp(r'^[A-Z]$').hasMatch(letter)) return;
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _letter = letter;
      _found.add(letter);
    });
  }

  @override
  Widget build(BuildContext context) => _GameScaffold(
    title: 'Key Explorer',
    child: KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.character != null) {
          _press(event.character!);
        }
      },
      child: Column(
        children: [
          _ProgressHeader(
            instruction: _letter == '?'
                ? 'Press any letter!'
                : 'Amazing! You found $_letter',
            progress: _found.length / 10,
            label: '${min(_found.length, 10)} / 10 discoveries',
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 150,
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _letter == '?'
                  ? const Color(0xFFEAE6FA)
                  : const Color(0xFFFFE37D),
              borderRadius: BorderRadius.circular(34),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Text(
              _letter,
              key: const Key('explorer-letter'),
              style: const TextStyle(
                fontSize: 82,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _found.length >= 10
                ? 'You are a keyboard explorer, ${widget.learnerName}! 🎉'
                : 'Use your keyboard or tap a key below.',
            style: const TextStyle(fontSize: 17, color: _muted),
          ),
          const SizedBox(height: 22),
          OnScreenKeyboard(onLetter: _press, highlighted: _letter),
          if (_found.length >= 10) ...[
            const SizedBox(height: 18),
            _FinishButton(onPressed: () => Navigator.pop(context, true)),
          ],
        ],
      ),
    ),
  );
}

class LetterHuntGame extends StatefulWidget {
  const LetterHuntGame({super.key, required this.learnerName});
  final String learnerName;
  @override
  State<LetterHuntGame> createState() => _LetterHuntGameState();
}

class _LetterHuntGameState extends State<LetterHuntGame> {
  final _focus = FocusNode();
  final _random = Random();
  int _round = 0;
  int _mistakes = 0;
  String _target = 'A';
  String _message = 'Find the letter A';

  @override
  void initState() {
    super.initState();
    _target = _nextLetter();
    _message = 'Find the letter $_target';
  }

  String _nextLetter() => String.fromCharCode(65 + _random.nextInt(26));

  void _press(String value) {
    if (_round >= 8) return;
    final letter = value.toUpperCase();
    if (!RegExp(r'^[A-Z]$').hasMatch(letter)) return;
    setState(() {
      if (letter == _target) {
        SystemSound.play(SystemSoundType.click);
        _round++;
        if (_round < 8) {
          _target = _nextLetter();
          _message = 'Great! Now find $_target';
        } else {
          _message = 'Letter hunt complete!';
        }
      } else {
        _mistakes++;
        _message = 'Good try! Look for $_target';
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _GameScaffold(
    title: 'Letter Hunt',
    child: KeyboardListener(
      autofocus: true,
      focusNode: _focus,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.character != null) {
          _press(event.character!);
        }
      },
      child: Column(
        children: [
          _ProgressHeader(
            instruction: _message,
            progress: _round / 8,
            label: '$_round / 8 letters',
          ),
          const SizedBox(height: 18),
          if (_round < 8)
            Container(
              key: const Key('letter-hunt-target'),
              width: 132,
              height: 132,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDCE6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF5B83), width: 5),
              ),
              child: Text(
                _target,
                style: const TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB62954),
                ),
              ),
            )
          else
            _Celebration(
              name: widget.learnerName,
              detail: 'You found every letter with $_mistakes little tries.',
            ),
          const SizedBox(height: 22),
          if (_round < 8)
            OnScreenKeyboard(onLetter: _press, highlighted: _target),
          if (_round >= 8) ...[
            const SizedBox(height: 18),
            _FinishButton(onPressed: () => Navigator.pop(context, true)),
          ],
        ],
      ),
    ),
  );
}

class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({super.key, required this.learnerName});
  final String learnerName;
  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

enum SequenceKind { english, numbers, urdu }

class SequenceNeighborGame extends StatefulWidget {
  const SequenceNeighborGame({super.key, required this.learnerName});

  final String learnerName;

  @override
  State<SequenceNeighborGame> createState() => _SequenceNeighborGameState();
}

class _SequenceNeighborGameState extends State<SequenceNeighborGame> {
  static const _english = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _urdu = [
    'ا',
    'ب',
    'پ',
    'ت',
    'ٹ',
    'ث',
    'ج',
    'چ',
    'ح',
    'خ',
    'د',
    'ڈ',
    'ذ',
    'ر',
    'ڑ',
    'ز',
    'ژ',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ک',
    'گ',
    'ل',
    'م',
    'ن',
    'ں',
    'و',
    'ہ',
    'ھ',
    'ء',
    'ی',
    'ے',
  ];
  static final _numbers = [for (var i = 0; i <= 9; i++) '$i'];

  final _answer = TextEditingController();
  final _answerFocus = FocusNode();
  final _random = Random();
  Timer? _answerTimer;
  int _score = 0;
  SequenceKind _kind = SequenceKind.english;
  late int _index;
  bool _askBefore = true;
  String _message = 'Type your answer below';
  bool _wrong = false;
  bool _checking = false;

  List<String> get _sequence => switch (_kind) {
    SequenceKind.english => _english.characters.toList(),
    SequenceKind.numbers => _numbers,
    SequenceKind.urdu => _urdu,
  };
  String get _shown => _sequence[_index];
  String get _expected => _sequence[_index + (_askBefore ? -1 : 1)];
  bool get _complete => _score >= 9;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    _answer.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  void _newQuestion() {
    final sequence = _sequence;
    _index = 1 + _random.nextInt(sequence.length - 2);
    _askBefore = _score.isEven;
    _answer.clear();
    _wrong = false;
  }

  void _changeKind(SequenceKind kind) {
    _answerTimer?.cancel();
    setState(() {
      _kind = kind;
      _score = 0;
      _message = 'Type your answer below';
      _newQuestion();
    });
  }

  bool _isCorrect(String raw) {
    final value = raw.trim();
    if (_kind != SequenceKind.english) return value == _expected;
    if (value.isEmpty) return false;
    // A, a, AA and Aa all demonstrate that the child knows the same letter.
    return value.characters.every(
      (character) => character.toUpperCase() == _expected,
    );
  }

  void _answerChanged(String value) {
    _answerTimer?.cancel();
    if (value.trim().isEmpty || _checking || _complete) return;
    _answerTimer = Timer(const Duration(milliseconds: 650), _checkAnswer);
  }

  void _selectReferenceValue(String value) {
    if (_checking || _complete) return;
    _answer.text = value;
    _answer.selection = TextSelection.collapsed(offset: value.length);
    _answerChanged(value);
  }

  Future<void> _checkAnswer() async {
    _answerTimer?.cancel();
    if (_complete || _checking || _answer.text.trim().isEmpty) return;
    _checking = true;
    final correct = _isCorrect(_answer.text);
    final expected = _expected;
    final shown = _shown;
    final relation = _askBefore ? 'before' : 'after';
    if (correct) {
      SystemSound.play(SystemSoundType.click);
      setState(() {
        _score = min(9, _score + 1);
        _message = 'Correct! $expected is $relation $shown.';
      });
      await _showAnswerPopup(
        correct: true,
        title: 'That is correct! 🎉',
        detail: '$expected comes $relation $shown.',
      );
      if (mounted && !_complete) {
        setState(() => _newQuestion());
      }
    } else {
      setState(() {
        _wrong = true;
        _message =
            'Good try! Look one place ${_askBefore ? 'back' : 'forward'}.';
      });
      await _showAnswerPopup(
        correct: false,
        title: 'Not quite yet',
        detail: 'The correct answer is $expected. Give it another try!',
      );
      if (mounted) {
        _answer.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _answer.text.length,
        );
      }
    }
    _checking = false;
  }

  Future<void> _showAnswerPopup({
    required bool correct,
    required String title,
    required String detail,
  }) async {
    BuildContext? popupContext;
    if (correct) {
      Timer(const Duration(milliseconds: 2200), () {
        if (popupContext?.mounted ?? false) Navigator.pop(popupContext!);
      });
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        popupContext = dialogContext;
        return PopScope(
          canPop: !correct,
          child: AlertDialog(
            key: Key(correct ? 'answer-correct-popup' : 'answer-wrong-popup'),
            icon: Icon(
              correct ? Icons.celebration_rounded : Icons.lightbulb_rounded,
              size: 52,
              color: correct
                  ? const Color(0xFF00A884)
                  : const Color(0xFFE49800),
            ),
            title: Text(title, textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                if (correct) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Next question will appear automatically…',
                    style: TextStyle(color: _muted),
                  ),
                ],
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: correct
                ? null
                : [
                    FilledButton.icon(
                      key: const Key('close-answer-popup'),
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
          ),
        );
      },
    );
  }

  String _kindLabel(SequenceKind kind) => switch (kind) {
    SequenceKind.english => 'ABC',
    SequenceKind.numbers => '123',
    SequenceKind.urdu => 'اردو',
  };

  @override
  Widget build(BuildContext context) => _GameScaffold(
    title: 'Before & After',
    child: Column(
      children: [
        Wrap(
          spacing: 10,
          children: [
            for (final kind in SequenceKind.values)
              ChoiceChip(
                key: Key('sequence-${kind.name}'),
                selected: _kind == kind,
                onSelected: _complete ? null : (_) => _changeKind(kind),
                label: Text(_kindLabel(kind)),
              ),
          ],
        ),
        if (!_complete) ...[
          const SizedBox(height: 14),
          _SequenceGuide(
            sequence: _sequence,
            isUrdu: _kind == SequenceKind.urdu,
            kind: _kind,
            onSelected: _selectReferenceValue,
          ),
        ],
        const SizedBox(height: 18),
        if (_complete)
          _ProgressHeader(
            instruction: '${_kindLabel(_kind)} exam complete!',
            progress: 1,
            label: '9 / 9 answers',
          )
        else
          _SequenceQuestionHeader(
            askBefore: _askBefore,
            shown: _shown,
            progress: _score / 9,
            label: '$_score / 9 answers',
            isUrdu: _kind == SequenceKind.urdu,
          ),
        const SizedBox(height: 22),
        if (!_complete) ...[
          Text(
            _message,
            key: const Key('sequence-feedback'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _wrong ? const Color(0xFFC23B5A) : _muted,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 330,
            child: TextField(
              key: const Key('sequence-answer'),
              controller: _answer,
              focusNode: _answerFocus,
              textAlign: TextAlign.center,
              textDirection: _kind == SequenceKind.urdu
                  ? TextDirection.rtl
                  : null,
              keyboardType: _kind == SequenceKind.numbers
                  ? TextInputType.number
                  : TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onChanged: _answerChanged,
              onSubmitted: (_) => _checkAnswer(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                hintText: _kind == SequenceKind.english
                    ? 'Type A, a or Aa'
                    : 'Type your answer',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ] else ...[
          _Celebration(
            name: widget.learnerName,
            detail:
                'You know what comes before and after in ABC, 123 and Urdu!',
          ),
          const SizedBox(height: 18),
          _FinishButton(onPressed: () => Navigator.pop(context, true)),
        ],
      ],
    ),
  );
}

class _SequenceQuestionHeader extends StatelessWidget {
  const _SequenceQuestionHeader({
    required this.askBefore,
    required this.shown,
    required this.progress,
    required this.label,
    required this.isUrdu,
  });

  final bool askBefore, isUrdu;
  final String shown, label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = askBefore ? const Color(0xFF2563C9) : const Color(0xFFE54870);
    final sequence = askBefore ? ['?', '←', shown] : [shown, '→', '?'];
    return Container(
      key: const Key('sequence-question-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  askBefore ? 'BEFORE' : 'AFTER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            'What comes ${askBefore ? 'BEFORE' : 'AFTER'} $shown?',
            textDirection: isUrdu ? TextDirection.rtl : null,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < sequence.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Container(
                  key: sequence[i] == shown
                      ? const Key('sequence-shown-key')
                      : null,
                  width: sequence[i] == '←' || sequence[i] == '→' ? 64 : 82,
                  height: 82,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sequence[i] == '?' ? color : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    sequence[i],
                    textDirection: isUrdu ? TextDirection.rtl : null,
                    style: TextStyle(
                      color: sequence[i] == '?' ? Colors.white : color,
                      fontSize: sequence[i] == '←' || sequence[i] == '→'
                          ? 46
                          : 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            askBefore
                ? 'Find the key on the LEFT ←'
                : 'Find the key on the RIGHT →',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
        ],
      ),
    );
  }
}

class _SequenceGuide extends StatelessWidget {
  const _SequenceGuide({
    required this.sequence,
    required this.isUrdu,
    required this.kind,
    required this.onSelected,
  });

  final List<String> sequence;
  final bool isUrdu;
  final SequenceKind kind;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          switch (kind) {
            SequenceKind.english => 'Complete A to Z reference',
            SequenceKind.numbers => 'Complete 0 to 9 reference',
            SequenceKind.urdu => 'Complete Urdu alphabet reference',
          },
          style: const TextStyle(
            color: _muted,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          spacing: 7,
          runSpacing: 7,
          children: [
            for (var i = 0; i < sequence.length; i++)
              Material(
                key: Key('sequence-reference-${kind.name}-$i'),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelected(sequence[i]),
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD8D3E3)),
                    ),
                    child: Text(
                      sequence[i],
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  static const _words = [
    ('CAT', '🐱'),
    ('SUN', '☀️'),
    ('FISH', '🐟'),
    ('STAR', '⭐'),
    ('APPLE', '🍎'),
  ];
  final _focus = FocusNode();
  int _wordIndex = 0;
  int _letterIndex = 0;
  String _message = 'Type the glowing letter';

  String get _word => _words[_wordIndex].$1;
  bool get _done => _wordIndex == _words.length;

  void _press(String value) {
    if (_done) return;
    final letter = value.toUpperCase();
    if (!RegExp(r'^[A-Z]$').hasMatch(letter)) return;
    setState(() {
      if (letter == _word[_letterIndex]) {
        SystemSound.play(SystemSoundType.click);
        _letterIndex++;
        _message = 'Yes! Keep going!';
        if (_letterIndex == _word.length) {
          _wordIndex++;
          _letterIndex = 0;
          _message = _done
              ? 'You built every word!'
              : 'Wonderful! Try the next word.';
        }
      } else {
        _message = 'Almost! Find ${_word[_letterIndex]}';
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _GameScaffold(
    title: 'Word Builder',
    child: KeyboardListener(
      autofocus: true,
      focusNode: _focus,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.character != null) {
          _press(event.character!);
        }
      },
      child: Column(
        children: [
          _ProgressHeader(
            instruction: _message,
            progress: _wordIndex / _words.length,
            label: '$_wordIndex / ${_words.length} words',
          ),
          const SizedBox(height: 24),
          if (!_done) ...[
            Text(_words[_wordIndex].$2, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 10),
            Wrap(
              key: const Key('word-builder-word'),
              spacing: 9,
              children: [
                for (var i = 0; i < _word.length; i++)
                  Container(
                    width: 58,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i < _letterIndex
                          ? const Color(0xFFD7F8EC)
                          : i == _letterIndex
                          ? const Color(0xFFFFE37D)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: i <= _letterIndex
                            ? const Color(0xFF00A884)
                            : const Color(0xFFD8D3E3),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      i < _letterIndex
                          ? _word[i]
                          : i == _letterIndex
                          ? _word[i]
                          : '',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            OnScreenKeyboard(
              onLetter: _press,
              highlighted: _word[_letterIndex],
            ),
          ] else ...[
            _Celebration(
              name: widget.learnerName,
              detail: 'You typed ${_words.length} happy words all by yourself!',
            ),
            const SizedBox(height: 18),
            _FinishButton(onPressed: () => Navigator.pop(context, true)),
          ],
        ],
      ),
    ),
  );
}

class _GameScaffold extends StatelessWidget {
  const _GameScaffold({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.instruction,
    required this.progress,
    required this.label,
  });
  final String instruction, label;
  final double progress;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    ),
  );
}

class OnScreenKeyboard extends StatelessWidget {
  const OnScreenKeyboard({super.key, required this.onLetter, this.highlighted});
  final ValueChanged<String> onLetter;
  final String? highlighted;
  static const _rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'On-screen alphabet keyboard',
    child: Column(
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final letter in row.characters)
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: FilledButton(
                      key: Key('keyboard-key-$letter'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: highlighted == letter
                            ? const Color(0xFFFFC928)
                            : _purple,
                        foregroundColor: highlighted == letter
                            ? _ink
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () => onLetter(letter),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _Celebration extends StatelessWidget {
  const _Celebration({required this.name, required this.detail});
  final String name, detail;
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('keyboard-celebration'),
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: const Color(0xFFDFF8EE),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      children: [
        const Text('🎉 ⭐ 🎉', style: TextStyle(fontSize: 54)),
        Text(
          'Fantastic, $name!',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF007C62),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17),
        ),
      ],
    ),
  );
}

class _FinishButton extends StatelessWidget {
  const _FinishButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const Key('finish-keyboard-game'),
    onPressed: onPressed,
    icon: const Icon(Icons.star_rounded),
    label: const Text(
      'Collect 3 stars',
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    ),
  );
}
