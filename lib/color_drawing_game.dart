import 'package:flutter/material.dart';

enum ColoringPicture {
  flower,
  rocket,
  butterfly,
  house,
  fish,
  car,
  iceCream,
  turtle,
}

class ColorDrawingGame extends StatefulWidget {
  const ColorDrawingGame({super.key, required this.learnerName});
  final String learnerName;
  @override
  State<ColorDrawingGame> createState() => _ColorDrawingGameState();
}

class _ColorDrawingGameState extends State<ColorDrawingGame> {
  static const palette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];
  ColoringPicture picture = ColoringPicture.flower;
  Color color = palette.first;
  final Map<int, Color> filled = {};
  bool done = false;
  int get total => _areas(picture).length;
  void reset([ColoringPicture? p]) => setState(() {
    if (p != null) picture = p;
    filled.clear();
    done = false;
  });
  void fill(int i) => setState(() {
    filled[i] = color;
    done = filled.length == total;
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8E8),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Color Drawing',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(label: Text('${filled.length} / $total parts')),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  key: const Key('reset-coloring'),
                  onPressed: filled.isEmpty ? null : reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start over'),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            children: ColoringPicture.values
                .map(
                  (p) => ChoiceChip(
                    key: Key('picture-${p.name}'),
                    selected: p == picture,
                    onSelected: (_) => reset(p),
                    avatar: Icon(_pictureIcon(p)),
                    label: Text(_pictureLabel(p)),
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFE5DDF8),
                          width: 3,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _Drawing(
                            key: ValueKey(picture),
                            picture: picture,
                            colors: filled,
                            onFill: fill,
                          ),
                          if (done)
                            ColoredBox(
                              color: const Color(0xEEFFFFFF),
                              child: Center(
                                child: Card(
                                  color: const Color(0xFFE8FFF3),
                                  elevation: 12,
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.celebration,
                                          size: 70,
                                          color: Colors.orange,
                                        ),
                                        const Text(
                                          'PICTURE COMPLETE!',
                                          key: Key('coloring-complete'),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF00875F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Beautiful coloring, ${widget.learnerName}!',
                                        ),
                                        const SizedBox(height: 18),
                                        FilledButton.icon(
                                          key: const Key('color-another'),
                                          onPressed: reset,
                                          icon: const Icon(Icons.brush),
                                          label: const Text('Color it again'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    width: 110,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const Text(
                          'Pick a color',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < palette.length; i++)
                              GestureDetector(
                                key: Key('color-$i'),
                                onTap: () => setState(() => color = palette[i]),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    width: 43,
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color: palette[i],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: color == palette[i]
                                            ? const Color(0xFF29213F)
                                            : Colors.white,
                                        width: color == palette[i] ? 4 : 2,
                                      ),
                                    ),
                                    child: color == palette[i]
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Choose a color, then click a white part.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Drawing extends StatelessWidget {
  const _Drawing({
    super.key,
    required this.picture,
    required this.colors,
    required this.onFill,
  });
  final ColoringPicture picture;
  final Map<int, Color> colors;
  final ValueChanged<int> onFill;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, b) {
      final a = _areas(picture);
      return Stack(
        key: const Key('coloring-canvas'),
        children: [
          for (var i = 0; i < a.length; i++)
            Positioned(
              left: a[i].left * b.maxWidth,
              top: a[i].top * b.maxHeight,
              width: a[i].width * b.maxWidth,
              height: a[i].height * b.maxHeight,
              child: Semantics(
                button: true,
                label: 'Color part ${i + 1}',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    key: Key('color-part-$i'),
                    onTap: () => onFill(i),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors[i] ?? Colors.white,
                        shape: _round(picture, i)
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: _round(picture, i)
                            ? null
                            : BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFF302A3D),
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

String _pictureLabel(ColoringPicture picture) => switch (picture) {
  ColoringPicture.flower => 'Flower',
  ColoringPicture.rocket => 'Rocket',
  ColoringPicture.butterfly => 'Butterfly',
  ColoringPicture.house => 'House',
  ColoringPicture.fish => 'Fish',
  ColoringPicture.car => 'Car',
  ColoringPicture.iceCream => 'Ice Cream',
  ColoringPicture.turtle => 'Turtle',
};

IconData _pictureIcon(ColoringPicture picture) => switch (picture) {
  ColoringPicture.flower => Icons.local_florist,
  ColoringPicture.rocket => Icons.rocket_launch,
  ColoringPicture.butterfly => Icons.flutter_dash,
  ColoringPicture.house => Icons.home_rounded,
  ColoringPicture.fish => Icons.set_meal_rounded,
  ColoringPicture.car => Icons.directions_car_rounded,
  ColoringPicture.iceCream => Icons.icecream_rounded,
  ColoringPicture.turtle => Icons.pets_rounded,
};

bool _round(ColoringPicture p, int i) =>
    p == ColoringPicture.flower && i < 6 ||
    p == ColoringPicture.rocket && i == 1 ||
    p == ColoringPicture.butterfly && i > 4 ||
    p == ColoringPicture.fish && (i == 0 || i > 3) ||
    p == ColoringPicture.car && i > 4 ||
    p == ColoringPicture.iceCream && i < 4 ||
    p == ColoringPicture.turtle && (i == 0 || i > 3);
List<Rect> _areas(ColoringPicture p) => switch (p) {
  ColoringPicture.flower => const [
    Rect.fromLTWH(.41, .34, .18, .22),
    Rect.fromLTWH(.41, .08, .18, .28),
    Rect.fromLTWH(.58, .24, .22, .25),
    Rect.fromLTWH(.53, .52, .19, .27),
    Rect.fromLTWH(.28, .52, .19, .27),
    Rect.fromLTWH(.20, .24, .22, .25),
    Rect.fromLTWH(.46, .55, .08, .39),
  ],
  ColoringPicture.rocket => const [
    Rect.fromLTWH(.37, .08, .26, .65),
    Rect.fromLTWH(.43, .30, .14, .19),
    Rect.fromLTWH(.23, .53, .20, .28),
    Rect.fromLTWH(.57, .53, .20, .28),
    Rect.fromLTWH(.45, .70, .10, .25),
    Rect.fromLTWH(.42, .08, .16, .18),
  ],
  ColoringPicture.butterfly => const [
    Rect.fromLTWH(.46, .22, .08, .56),
    Rect.fromLTWH(.17, .15, .30, .32),
    Rect.fromLTWH(.53, .15, .30, .32),
    Rect.fromLTWH(.20, .48, .27, .34),
    Rect.fromLTWH(.53, .48, .27, .34),
    Rect.fromLTWH(.26, .25, .10, .13),
    Rect.fromLTWH(.64, .25, .10, .13),
    Rect.fromLTWH(.46, .10, .08, .14),
  ],
  ColoringPicture.house => const [
    Rect.fromLTWH(.25, .35, .50, .50),
    Rect.fromLTWH(.20, .17, .60, .30),
    Rect.fromLTWH(.43, .58, .14, .27),
    Rect.fromLTWH(.30, .48, .13, .17),
    Rect.fromLTWH(.57, .48, .13, .17),
    Rect.fromLTWH(.65, .10, .09, .22),
    Rect.fromLTWH(.12, .61, .15, .25),
    Rect.fromLTWH(.73, .61, .15, .25),
  ],
  ColoringPicture.fish => const [
    Rect.fromLTWH(.25, .25, .50, .50),
    Rect.fromLTWH(.08, .30, .24, .40),
    Rect.fromLTWH(.42, .15, .18, .18),
    Rect.fromLTWH(.42, .67, .18, .18),
    Rect.fromLTWH(.61, .37, .08, .11),
    Rect.fromLTWH(.29, .39, .13, .18),
    Rect.fromLTWH(.72, .40, .12, .20),
  ],
  ColoringPicture.car => const [
    Rect.fromLTWH(.18, .45, .64, .30),
    Rect.fromLTWH(.31, .25, .38, .27),
    Rect.fromLTWH(.35, .30, .13, .18),
    Rect.fromLTWH(.52, .30, .13, .18),
    Rect.fromLTWH(.78, .53, .10, .14),
    Rect.fromLTWH(.25, .68, .15, .20),
    Rect.fromLTWH(.61, .68, .15, .20),
  ],
  ColoringPicture.iceCream => const [
    Rect.fromLTWH(.28, .10, .25, .30),
    Rect.fromLTWH(.47, .10, .25, .30),
    Rect.fromLTWH(.35, .25, .30, .30),
    Rect.fromLTWH(.38, .04, .14, .19),
    Rect.fromLTWH(.36, .43, .28, .47),
    Rect.fromLTWH(.43, .53, .14, .12),
  ],
  ColoringPicture.turtle => const [
    Rect.fromLTWH(.25, .25, .50, .50),
    Rect.fromLTWH(.38, .34, .24, .16),
    Rect.fromLTWH(.34, .51, .16, .17),
    Rect.fromLTWH(.51, .51, .16, .17),
    Rect.fromLTWH(.72, .39, .17, .22),
    Rect.fromLTWH(.16, .25, .15, .20),
    Rect.fromLTWH(.16, .61, .15, .20),
    Rect.fromLTWH(.69, .64, .15, .20),
  ],
};
