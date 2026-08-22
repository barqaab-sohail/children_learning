import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef GameBuilder = Widget Function(BuildContext);

class MouseAdventureScreen extends StatefulWidget {
  const MouseAdventureScreen({
    super.key,
    required this.learnerName,
    required this.clickGarden,
    required this.balloonPark,
    required this.starSpace,
    required this.coloringStudio,
  });
  final String learnerName;
  final GameBuilder clickGarden, balloonPark, starSpace, coloringStudio;
  @override
  State<MouseAdventureScreen> createState() => _HubState();
}

class _HubState extends State<MouseAdventureScreen> {
  int stars = 0;
  Set<String> badges = {};
  bool large = false,
      contrast = false,
      noTimer = false,
      reduced = false,
      sounds = true,
      urdu = false,
      focus = false;
  String get pre => 'mouse_${widget.learnerName}_';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      stars = p.getInt('${pre}s') ?? 0;
      badges = (p.getStringList('${pre}b') ?? []).toSet();
      large = p.getBool('${pre}large') ?? false;
      contrast = p.getBool('${pre}contrast') ?? false;
      noTimer = p.getBool('${pre}timer') ?? false;
      reduced = p.getBool('${pre}motion') ?? false;
      sounds = p.getBool('${pre}sound') ?? true;
      urdu = p.getBool('${pre}urdu') ?? false;
    });
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('${pre}large', large);
    await p.setBool('${pre}contrast', contrast);
    await p.setBool('${pre}timer', noTimer);
    await p.setBool('${pre}motion', reduced);
    await p.setBool('${pre}sound', sounds);
    await p.setBool('${pre}urdu', urdu);
  }

  Future<void> award(String b, int n) async {
    if (sounds) SystemSound.play(SystemSoundType.click);
    final p = await SharedPreferences.getInstance();
    final bs = (p.getStringList('${pre}b') ?? []).toSet();
    if (bs.add(b)) {
      await p.setInt('${pre}s', (p.getInt('${pre}s') ?? 0) + n);
      await p.setStringList('${pre}b', bs.toList());
    }
  }

  Future<void> open(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    await load();
  }

  void settings() => showDialog<void>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (c, d) => AlertDialog(
        title: const Text('Comfort & accessibility'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: [
              _sw(
                'Large targets',
                'Easier to point at',
                large,
                (v) => large = v,
                d,
              ),
              _sw(
                'High contrast',
                'Clearer colors',
                contrast,
                (v) => contrast = v,
                d,
              ),
              _sw(
                'Practice without timers',
                'Play at your own pace',
                noTimer,
                (v) => noTimer = v,
                d,
              ),
              _sw(
                'Reduce motion',
                'Fewer animations',
                reduced,
                (v) => reduced = v,
                d,
              ),
              _sw(
                'Feedback sounds',
                'Hear successful actions',
                sounds,
                (v) => sounds = v,
                d,
              ),
              _sw(
                'Urdu guidance',
                'Roman Urdu instructions',
                urdu,
                (v) => urdu = v,
                d,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Done'),
          ),
        ],
      ),
    ),
  );
  Widget _sw(
    String t,
    String sub,
    bool value,
    ValueChanged<bool> change,
    StateSetter d,
  ) => SwitchListTile(
    title: Text(t),
    subtitle: Text(sub),
    value: value,
    onChanged: (v) {
      setState(() => change(v));
      d(() {});
      save();
    },
  );
  @override
  Widget build(BuildContext context) {
    final fg = contrast ? Colors.white : const Color(0xFF29213F);
    final games = [
      _Card(
        key: const Key('adventure-click'),
        Icons.ads_click,
        const Color(0xFF6C5CE7),
        'Click Garden',
        'Move and single-click',
        'Start',
        () => open(widget.clickGarden(context)),
      ),
      _Card(
        Icons.air,
        const Color(0xFFFF5D8F),
        'Balloon Park',
        'Speed and accuracy',
        'Level 2',
        () => open(widget.balloonPark(context)),
      ),
      _Card(
        Icons.stars,
        const Color(0xFF433D8B),
        'Star Space',
        'Moving targets',
        'Level 3',
        () => open(widget.starSpace(context)),
      ),
      _Card(
        Icons.palette,
        const Color(0xFFFF9F1C),
        'Coloring Studio',
        'Precise clicking',
        'Creative',
        () => open(widget.coloringStudio(context)),
      ),
      _Card(
        key: const Key('adventure-drag'),
        Icons.back_hand,
        const Color(0xFF00A884),
        'Drag-and-Drop Farm',
        'Hold, drag and release',
        'Level 2',
        () => open(
          DragDropFarmGame(
            large: large,
            urdu: urdu,
            onWin: () => award('farm', 3),
          ),
        ),
      ),
      _Card(
        key: const Key('adventure-double'),
        Icons.inventory_2,
        const Color(0xFFE76F51),
        'Double-Click Treasure',
        'Double-click',
        'Level 2',
        () => open(
          DoubleClickTreasureGame(
            large: large,
            urdu: urdu,
            onWin: () => award('treasure', 2),
          ),
        ),
      ),
      _Card(
        key: const Key('adventure-maze'),
        Icons.route,
        const Color(0xFF318CE7),
        'Maze Island',
        'Pointer path control',
        'Level 3',
        () => open(
          MazeIslandGame(
            large: large,
            urdu: urdu,
            onWin: () => award('maze', 4),
          ),
        ),
      ),
      _Card(
        key: const Key('adventure-scroll'),
        Icons.swipe_vertical,
        const Color(0xFF8E44AD),
        'Scroll Safari',
        'Scroll and find',
        'Level 2',
        () => open(
          ScrollSafariGame(
            large: large,
            urdu: urdu,
            onWin: () => award('safari', 3),
          ),
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: contrast
          ? const Color(0xFF111827)
          : const Color(0xFFF5F1FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              if (!focus)
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mouse Adventure',
                            style: TextStyle(
                              color: fg,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            urdu
                                ? 'Apna game chunein aur mouse seekhein'
                                : 'Choose a destination and grow your mouse skills!',
                            style: TextStyle(color: fg.withValues(alpha: .7)),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.star, color: Colors.orange),
                      label: Text('$stars stars'),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(
                        Icons.military_tech,
                        color: Colors.green,
                      ),
                      label: Text('${badges.length} badges'),
                    ),
                    IconButton(
                      onPressed: settings,
                      tooltip: 'Accessibility',
                      icon: Icon(Icons.accessibility_new, color: fg),
                    ),
                    IconButton(
                      onPressed: () => setState(() => focus = true),
                      tooltip: 'Focus mode',
                      icon: Icon(Icons.fullscreen, color: fg),
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filled(
                    onPressed: () => setState(() => focus = false),
                    icon: const Icon(Icons.fullscreen_exit),
                  ),
                ),
              if (!focus) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  minHeight: 10,
                  value: badges.length / 8,
                ),
                const SizedBox(height: 14),
              ],
              Expanded(
                child: GridView.extent(
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.48,
                  children: games,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  const _Card(
    this.icon,
    this.color,
    this.title,
    this.skill,
    this.level,
    this.tap, {
    super.key,
  });
  final IconData icon;
  final Color color;
  final String title, skill, level;
  final VoidCallback tap;
  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  bool h = false;
  @override
  Widget build(BuildContext c) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => h = true),
    onExit: (_) => setState(() => h = false),
    child: AnimatedScale(
      scale: h ? 1.03 : 1,
      duration: const Duration(milliseconds: 140),
      child: Card(
        elevation: h ? 10 : 3,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.tap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 39),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        widget.skill,
                        style: const TextStyle(color: Color(0xFF6B6680)),
                      ),
                      const SizedBox(height: 5),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(widget.level),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class Shell extends StatelessWidget {
  const Shell({
    super.key,
    required this.title,
    required this.help,
    required this.child,
  });
  final String title, help;
  final Widget child;
  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: const Color(0xFFF8F6FF),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(c),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  help,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF625B78),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class Win extends StatelessWidget {
  const Win(this.title, this.again, {super.key});
  final String title;
  final VoidCallback again;
  @override
  Widget build(BuildContext c) => Center(
    child: Card(
      color: const Color(0xFFE8FFF3),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 70, color: Colors.orange),
            Text(
              title,
              key: const Key('adventure-win'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00875F),
              ),
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: again,
              icon: const Icon(Icons.replay),
              label: const Text('Play again'),
            ),
          ],
        ),
      ),
    ),
  );
}

class DoubleClickTreasureGame extends StatefulWidget {
  const DoubleClickTreasureGame({
    super.key,
    required this.large,
    required this.urdu,
    required this.onWin,
  });
  final bool large, urdu;
  final Future<void> Function() onWin;
  @override
  State<DoubleClickTreasureGame> createState() => _DoubleState();
}

class _DoubleState extends State<DoubleClickTreasureGame> {
  final open = <int>{};
  Set<int> treasures = {};
  String msg = 'Double-click a chest to look for treasure!';
  bool lastWasTreasure = false;

  int get found => open.where(treasures.contains).length;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final places = List.generate(6, (i) => i)..shuffle(Random());
    treasures = places.take(3).toSet();
    open.clear();
    lastWasTreasure = false;
    msg = 'Double-click a chest to look for treasure!';
  }

  void hit(int i) {
    if (!open.add(i)) return;
    final success = treasures.contains(i);
    setState(() {
      lastWasTreasure = success;
      msg = success
          ? 'Amazing! You found a sparkling treasure!'
          : 'This chest is empty. Good try—choose another one!';
    });
    if (success) SystemSound.play(SystemSoundType.click);
    if (found == treasures.length) widget.onWin();
  }

  void replay() => setState(_newRound);

  @override
  Widget build(BuildContext c) => Shell(
    title: 'Double-Click Treasure',
    help: widget.urdu ? 'Har box par do click' : 'Treasures  $found / 3',
    child: found == treasures.length
        ? Win('All treasures found!', replay)
        : Column(
            children: [
              AnimatedContainer(
                key: const Key('treasure-feedback'),
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.fromLTRB(28, 4, 28, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: lastWasTreasure
                      ? const Color(0xFFD9FBE8)
                      : open.isEmpty
                      ? const Color(0xFFEDE7FF)
                      : const Color(0xFFFFECEF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: lastWasTreasure
                        ? const Color(0xFF00A884)
                        : open.isEmpty
                        ? const Color(0xFF6C5CE7)
                        : const Color(0xFFE76F51),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      lastWasTreasure
                          ? Icons.auto_awesome
                          : open.isEmpty
                          ? Icons.touch_app
                          : Icons.sentiment_satisfied_alt,
                      color: lastWasTreasure
                          ? const Color(0xFF00A884)
                          : const Color(0xFFE76F51),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        msg,
                        key: const Key('treasure-message'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(28),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, i) {
                    final isOpen = open.contains(i);
                    final hasTreasure = treasures.contains(i);
                    return GestureDetector(
                      key: Key('treasure-$i'),
                      onDoubleTap: () => hit(i),
                      onTap: isOpen
                          ? null
                          : () => setState(
                              () => msg = 'Use two quick clicks to open it!',
                            ),
                      child: MouseRegion(
                        cursor: isOpen
                            ? SystemMouseCursors.basic
                            : SystemMouseCursors.click,
                        child: Card(
                          color: isOpen
                              ? hasTreasure
                                    ? const Color(0xFFD9FBE8)
                                    : const Color(0xFFFFECEF)
                              : const Color(0xFFFFE0B2),
                          elevation: isOpen && hasTreasure ? 12 : 4,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                            child: !isOpen
                                ? Icon(
                                    Icons.inventory_2,
                                    key: ValueKey('closed-$i'),
                                    size: widget.large ? 100 : 75,
                                    color: Colors.brown,
                                  )
                                : hasTreasure
                                ? Stack(
                                    key: ValueKey('found-$i'),
                                    alignment: Alignment.center,
                                    children: [
                                      const Positioned(
                                        left: 22,
                                        top: 18,
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      const Positioned(
                                        right: 22,
                                        bottom: 18,
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      Icon(
                                        Icons.diamond,
                                        key: Key('treasure-found-$i'),
                                        size: widget.large ? 100 : 76,
                                        color: Colors.cyan,
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: ValueKey('empty-$i'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        key: Key('treasure-empty-$i'),
                                        size: widget.large ? 82 : 62,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Empty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFD65365),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
  );
}

class DragDropFarmGame extends StatefulWidget {
  const DragDropFarmGame({
    super.key,
    required this.large,
    required this.urdu,
    required this.onWin,
  });
  final bool large, urdu;
  final Future<void> Function() onWin;
  @override
  State<DragDropFarmGame> createState() => _DragState();
}

class _DragState extends State<DragDropFarmGame> {
  final done = <int>{};
  static const data = [
    (Icons.apple, 'Basket', Colors.red),
    (Icons.egg, 'Nest', Colors.orange),
    (Icons.water_drop, 'Pond', Colors.blue),
    (Icons.local_florist, 'Garden', Colors.pink),
  ];
  void hit(int i) {
    if (done.add(i)) {
      setState(() {});
      if (done.length == 4) widget.onWin();
    }
  }

  @override
  Widget build(BuildContext c) => Shell(
    title: 'Drag-and-Drop Farm',
    help: widget.urdu
        ? 'Cheez ko sahi jagah le jayein'
        : 'Drag each item to its home',
    child: done.length == 4
        ? Win('Farm sorted!', () => setState(() => done.clear()))
        : Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < 4; i++)
                        if (!done.contains(i))
                          Draggable<int>(
                            data: i,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Icon(
                                data[i].$1,
                                size: 80,
                                color: data[i].$3,
                              ),
                            ),
                            child: Icon(
                              data[i].$1,
                              key: Key('drag-item-$i'),
                              size: widget.large ? 85 : 65,
                              color: data[i].$3,
                            ),
                          ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < 4; i++)
                        DragTarget<int>(
                          onWillAcceptWithDetails: (d) => d.data == i,
                          onAcceptWithDetails: (_) => hit(i),
                          builder: (_, a, _) => Container(
                            key: Key('drop-target-$i'),
                            height: widget.large ? 90 : 72,
                            decoration: BoxDecoration(
                              color: a.isNotEmpty
                                  ? Colors.yellow.shade100
                                  : Colors.white,
                              border: Border.all(color: data[i].$3, width: 3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                done.contains(i) ? 'Done!' : data[i].$2,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );
}

class MazeIslandGame extends StatefulWidget {
  const MazeIslandGame({
    super.key,
    required this.large,
    required this.urdu,
    required this.onWin,
  });
  final bool large, urdu;
  final Future<void> Function() onWin;
  @override
  State<MazeIslandGame> createState() => _MazeState();
}

class _MazeState extends State<MazeIslandGame> {
  int at = 0;
  bool won = false;
  String message = 'Start at the first star and follow the route';
  static const pts = [
    Offset(.08, .82),
    Offset(.23, .82),
    Offset(.23, .52),
    Offset(.43, .52),
    Offset(.43, .74),
    Offset(.63, .74),
    Offset(.63, .34),
    Offset(.82, .34),
    Offset(.82, .15),
    Offset(.94, .15),
  ];
  void hover(PointerHoverEvent e, Size s) {
    if (won) return;
    final radius = widget.large ? 70.0 : 50.0;

    // Returning to an older checkpoint removes all progress made after it.
    // The latest completed checkpoint stays safe during normal movement.
    for (var i = 0; i < at - 1; i++) {
      final previous = Offset(pts[i].dx * s.width, pts[i].dy * s.height);
      if ((e.localPosition - previous).distance < radius) {
        setState(() {
          at = i + 1;
          message =
              'You moved back to star ${i + 1}. Follow the route forward again!';
        });
        return;
      }
    }

    final next = Offset(pts[at].dx * s.width, pts[at].dy * s.height);
    if ((e.localPosition - next).distance < radius) {
      setState(() {
        at++;
        message = at == pts.length
            ? 'Wonderful! You followed the whole route!'
            : 'Great! Now move to star ${at + 1}.';
      });
      if (at == pts.length) {
        won = true;
        widget.onWin();
      }
    }
  }

  @override
  Widget build(BuildContext c) => Shell(
    title: 'Maze Island',
    help: widget.urdu
        ? 'Sitaaron ke raste par mouse chalayein'
        : 'Completed  $at / ${pts.length}',
    child: won
        ? Win(
            'Island reached!',
            () => setState(() {
              at = 0;
              won = false;
              message = 'Start at the first star and follow the route';
            }),
          )
        : Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Container(
                  key: ValueKey(message),
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.startsWith('You moved back')
                        ? const Color(0xFFFFECEF)
                        : const Color(0xFFE8F4FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message,
                    key: const Key('maze-message'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: message.startsWith('You moved back')
                          ? const Color(0xFFD65365)
                          : const Color(0xFF2869A8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, b) => MouseRegion(
                    key: const Key('maze-area'),
                    cursor: SystemMouseCursors.precise,
                    onHover: (e) => hover(e, Size(b.maxWidth, b.maxHeight)),
                    child: CustomPaint(
                      painter: MazePaint(pts, at, widget.large),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}

class MazePaint extends CustomPainter {
  const MazePaint(this.pts, this.at, this.large);
  final List<Offset> pts;
  final int at;
  final bool large;
  @override
  void paint(Canvas c, Size s) {
    final path = Path()..moveTo(pts[0].dx * s.width, pts[0].dy * s.height);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx * s.width, p.dy * s.height);
    }
    c.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBDE0FE)
        ..strokeWidth = large ? 70 : 54
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < pts.length; i++) {
      final p = Offset(pts[i].dx * s.width, pts[i].dy * s.height);
      c.drawCircle(
        p,
        large ? 19 : 14,
        Paint()..color = i < at ? Colors.green : Colors.amber,
      );
    }
  }

  @override
  bool shouldRepaint(MazePaint o) => o.at != at || o.large != large;
}

class ScrollSafariGame extends StatefulWidget {
  const ScrollSafariGame({
    super.key,
    required this.large,
    required this.urdu,
    required this.onWin,
  });
  final bool large, urdu;
  final Future<void> Function() onWin;
  @override
  State<ScrollSafariGame> createState() => _SafariState();
}

class _SafariState extends State<ScrollSafariGame> {
  final found = <int>{};
  static const icons = [
    Icons.pets,
    Icons.cruelty_free,
    Icons.flutter_dash,
    Icons.bug_report,
    Icons.emoji_nature,
    Icons.flight,
    Icons.set_meal,
    Icons.pest_control,
  ];
  void hit(int i) {
    if (found.add(i)) {
      setState(() {});
      if (found.length == 8) widget.onWin();
    }
  }

  @override
  Widget build(BuildContext c) => Shell(
    title: 'Scroll Safari',
    help: widget.urdu
        ? 'Neeche scroll kar ke janwar dhoondein'
        : 'Scroll and find all 8 animals',
    child: found.length == 8
        ? Win('Safari complete!', () => setState(() => found.clear()))
        : Stack(
            children: [
              ListView.builder(
                key: const Key('safari-scroll'),
                padding: const EdgeInsets.all(22),
                itemCount: 8,
                itemBuilder: (_, i) => Container(
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: i.isEven
                        ? Colors.green.shade200
                        : Colors.cyan.shade200,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Align(
                    alignment: Alignment(
                      (i % 3 - 1) * .7,
                      i.isEven ? .35 : -.3,
                    ),
                    child: IconButton.filled(
                      key: Key('safari-animal-$i'),
                      onPressed: () => hit(i),
                      iconSize: widget.large ? 65 : 48,
                      icon: Icon(icons[i]),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 24,
                top: 10,
                child: Chip(label: Text('${found.length} / 8 found')),
              ),
            ],
          ),
  );
}
