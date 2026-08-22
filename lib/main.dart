import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color_drawing_game.dart';
import 'mouse_adventure.dart';

// Change these two values to make the balloon game shorter or longer.
const int balloonMissesToEndGame = 10;
const int balloonHitsToEndGame = 20;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrightStepsApp());
}

class LearnerProfile {
  const LearnerProfile({required this.id, required this.name, this.imagePath});
  final String id;
  final String name;
  final String? imagePath;

  LearnerProfile copyWith({String? imagePath, bool removeImage = false}) =>
      LearnerProfile(
        id: id,
        name: name,
        imagePath: removeImage ? null : imagePath ?? this.imagePath,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
  };
  factory LearnerProfile.fromJson(Map<String, dynamic> json) => LearnerProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    imagePath: json['imagePath'] as String?,
  );
}

class ProfileStore {
  static const _profilesKey = 'learner_profiles';
  static const _activeKey = 'active_learner_id';

  static Future<List<LearnerProfile>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map(
            (item) =>
                LearnerProfile.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<LearnerProfile?> activeProfile() async {
    final profiles = await load();
    if (profiles.isEmpty) return null;
    final activeId = (await SharedPreferences.getInstance()).getString(
      _activeKey,
    );
    return profiles.where((profile) => profile.id == activeId).firstOrNull ??
        profiles.first;
  }

  static Future<void> save(
    List<LearnerProfile> profiles,
    String activeId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((profile) => profile.toJson()).toList()),
    );
    await prefs.setString(_activeKey, activeId);
  }

  static Future<void> setActive(String id) async =>
      (await SharedPreferences.getInstance()).setString(_activeKey, id);
}

class BrightStepsApp extends StatelessWidget {
  const BrightStepsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Bright Steps',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
      scaffoldBackgroundColor: const Color(0xFFF7F5FF),
      useMaterial3: true,
    ),
    home: const AppLauncher(),
  );
}

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<LearnerProfile?>(
    future: ProfileStore.activeProfile(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final profile = snapshot.data;
      return profile == null
          ? const LearnerNameScreen()
          : HomeScreen(profile: profile);
    },
  );
}

class LearnerNameScreen extends StatefulWidget {
  const LearnerNameScreen({super.key});

  @override
  State<LearnerNameScreen> createState() => _LearnerNameScreenState();
}

class _LearnerNameScreenState extends State<LearnerNameScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startLearning() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final profiles = await ProfileStore.load();
    final profile = LearnerProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    profiles.add(profile);
    await ProfileStore.save(profiles, profile.id);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shadowColor: const Color(0x446C5CE7),
              child: Padding(
                padding: const EdgeInsets.all(38),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFF6C5CE7),
                        child: Icon(
                          Icons.waving_hand_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome, little learner!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'What is your name?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF6B6680),
                        ),
                      ),
                      const SizedBox(height: 26),
                      TextFormField(
                        key: const Key('learner-name'),
                        controller: _nameController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _startLearning(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          prefixIcon: const Icon(Icons.face_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF5F2FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (name.length > 30) {
                            return 'Please use 30 letters or fewer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          key: const Key('start-learning'),
                          onPressed: _startLearning,
                          icon: const Icon(Icons.rocket_launch_rounded),
                          label: const Text(
                            'Start Learning',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.profile});
  final LearnerProfile profile;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF6C5CE7),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bright Steps',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Learn, play and grow!',
                      style: TextStyle(color: Color(0xFF6B6680)),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  key: const Key('manage-learners'),
                  onPressed: () async {
                    final selected = await Navigator.push<LearnerProfile>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LearnersScreen(activeProfile: profile),
                      ),
                    );
                    if (selected != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(profile: selected),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.people_alt_outlined),
                  label: const Text('Learners'),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Hello, ${profile.name}!',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF6C5CE7),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What would you like to practice?',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose an activity to begin your learning adventure.',
              style: TextStyle(fontSize: 17, color: Color(0xFF6B6680)),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              children: [
                _ModuleCard(
                  icon: Icons.mouse,
                  color: const Color(0xFF6C5CE7),
                  title: 'Mouse Practice',
                  subtitle: 'Move, point and click the right answer',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MouseAdventureScreen(
                        learnerName: profile.name,
                        clickGarden: (_) =>
                            MousePracticeScreen(profile: profile),
                        balloonPark: (_) =>
                            BalloonSpeedGame(learnerName: profile.name),
                        starSpace: (_) =>
                            StarTargetGame(learnerName: profile.name),
                        coloringStudio: (_) =>
                            ColorDrawingGame(learnerName: profile.name),
                      ),
                    ),
                  ),
                ),
                const _ModuleCard(
                  icon: Icons.lock_outline,
                  color: Color(0xFFFFA94D),
                  title: 'More activities',
                  subtitle: 'New learning games are coming soon',
                ),
              ],
            ),
            const Spacer(flex: 2),
            const Center(
              child: Text(
                'Made for little learners',
                style: TextStyle(color: Color(0xFF918BA8)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LearnersScreen extends StatefulWidget {
  const LearnersScreen({super.key, required this.activeProfile});
  final LearnerProfile activeProfile;

  @override
  State<LearnersScreen> createState() => _LearnersScreenState();
}

class _LearnersScreenState extends State<LearnersScreen> {
  List<LearnerProfile>? _profiles;
  late String _activeId;

  @override
  void initState() {
    super.initState();
    _activeId = widget.activeProfile.id;
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await ProfileStore.load();
    if (mounted) setState(() => _profiles = profiles);
  }

  Future<void> _select(LearnerProfile profile) async {
    await ProfileStore.setActive(profile.id);
    if (!mounted) return;
    Navigator.pop(context, profile);
  }

  void _returnToHome() {
    if (_profiles == null || _profiles!.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final active = _profiles!.firstWhere(
      (profile) => profile.id == _activeId,
      orElse: () => _profiles!.first,
    );
    Navigator.pop(context, active);
  }

  Future<void> _edit(LearnerProfile profile) async {
    final controller = TextEditingController(text: profile.name);
    final formKey = GlobalKey<FormState>();
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit learner name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: const Key('edit-learner-name'),
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Learner name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'Please enter a name';
              if (name.length > 30) return 'Please use 30 letters or fewer';
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('save-learner-name'),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName == profile.name || !mounted) return;

    final updated = LearnerProfile(
      id: profile.id,
      name: newName,
      imagePath: profile.imagePath,
    );
    final index = _profiles!.indexWhere((item) => item.id == profile.id);
    if (index < 0) return;
    setState(() => _profiles![index] = updated);
    await ProfileStore.save(_profiles!, _activeId);
  }

  Future<void> _delete(LearnerProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
        title: Text('Delete ${profile.name}?'),
        content: const Text(
          'This learner and their saved picture will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-delete-learner'),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _profiles!.removeWhere((item) => item.id == profile.id));
    if (profile.imagePath != null) {
      try {
        final image = File(profile.imagePath!);
        if (await image.exists()) await image.delete();
      } on FileSystemException {
        // The learner should still be removed if an old picture is unavailable.
      }
    }

    if (_profiles!.isEmpty) {
      await ProfileStore.save(const [], '');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LearnerNameScreen()),
        (_) => false,
      );
      return;
    }

    if (_activeId == profile.id) _activeId = _profiles!.first.id;
    await ProfileStore.save(_profiles!, _activeId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back',
        onPressed: _returnToHome,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Choose a learner'),
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('add-learner'),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LearnerNameScreen()),
      ),
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Add learner'),
    ),
    body: _profiles == null
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: _profiles!.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final profile = _profiles![index];
              final selected = profile.id == _activeId;
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    child: Text(profile.name.characters.first.toUpperCase()),
                  ),
                  title: Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    selected
                        ? 'Currently learning'
                        : 'Tap to continue as ${profile.name}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00A884),
                        ),
                      IconButton(
                        key: Key('edit-learner-${profile.id}'),
                        tooltip: 'Edit ${profile.name}',
                        onPressed: () => _edit(profile),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        key: Key('delete-learner-${profile.id}'),
                        tooltip: 'Delete ${profile.name}',
                        color: Colors.redAccent,
                        onPressed: () => _delete(profile),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                  onTap: () => _select(profile),
                ),
              );
            },
          ),
  );
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 330,
    height: 225,
    child: Card(
      elevation: onTap == null ? 0 : 4,
      color: onTap == null ? Colors.white60 : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .14),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6B6680))),
            ],
          ),
        ),
      ),
    ),
  );
}

enum PracticeMode { letters, numbers, urdu, mixed }

class MousePracticeScreen extends StatefulWidget {
  const MousePracticeScreen({super.key, required this.profile});
  final LearnerProfile profile;
  @override
  State<MousePracticeScreen> createState() => _MousePracticeScreenState();
}

class _MousePracticeScreenState extends State<MousePracticeScreen> {
  final _random = Random();
  PracticeMode _mode = PracticeMode.letters;
  late List<String> _choices;
  late String _target;
  int _score = 0;
  int _round = 1;
  String? _imagePath;
  String _message = 'Find it and click!';
  String? _lastWrong;

  List<String> get _pool => switch (_mode) {
    PracticeMode.letters => List.generate(
      26,
      (i) => String.fromCharCode(65 + i),
    ),
    PracticeMode.numbers => List.generate(10, (i) => '$i'),
    PracticeMode.urdu => const [
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
      'و',
      'ہ',
      'ء',
      'ی',
    ],
    PracticeMode.mixed => [
      ...List.generate(26, (i) => String.fromCharCode(65 + i)),
      ...List.generate(10, (i) => '$i'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _imagePath = widget.profile.imagePath;
    _newQuestion(first: true);
  }

  void _newQuestion({bool first = false}) {
    final values = [..._pool]..shuffle(_random);
    setState(() {
      _choices = values.take(12).toList();
      _target = _choices[_random.nextInt(_choices.length)];
      _message = 'Find it and click!';
      _lastWrong = null;
      if (!first) _round++;
    });
  }

  void _choose(String value) {
    if (value != _target) {
      setState(() {
        _message = 'Almost! Try again.';
        _lastWrong = value;
      });
      return;
    }
    setState(() {
      _score++;
      _message = 'Wonderful, ${widget.profile.name}! You found $_target! ⭐';
      _lastWrong = null;
    });
    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (mounted) _newQuestion();
    });
  }

  Future<void> _pickPicture() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (picked == null) return;

      final pickedFile = picked.files.single;
      final bytes =
          pickedFile.bytes ??
          (pickedFile.path == null
              ? null
              : await File(pickedFile.path!).readAsBytes());
      if (bytes == null) {
        throw const FileSystemException(
          'The selected image could not be read.',
        );
      }

      final extension = pickedFile.extension?.toLowerCase() ?? 'jpg';
      final directory = await getApplicationDocumentsDirectory();
      await directory.create(recursive: true);
      final savedPath =
          '${directory.path}${Platform.pathSeparator}bright_steps_${widget.profile.id}.$extension';
      await File(savedPath).writeAsBytes(bytes, flush: true);
      await _saveImagePath(savedPath);

      final oldPath = _imagePath;
      if (oldPath != null && oldPath != savedPath) {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) await oldFile.delete();
      }
      if (mounted) setState(() => _imagePath = savedPath);
    } on FileSystemException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save that picture. Please select it again.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That picture could not be opened. Please try another image.',
          ),
        ),
      );
    }
  }

  Future<void> _saveImagePath(String? path) async {
    final profiles = await ProfileStore.load();
    final index = profiles.indexWhere(
      (profile) => profile.id == widget.profile.id,
    );
    if (index < 0) return;
    profiles[index] = profiles[index].copyWith(
      imagePath: path,
      removeImage: path == null,
    );
    await ProfileStore.save(profiles, widget.profile.id);
  }

  Future<void> _removePicture() async {
    final oldPath = _imagePath;
    await _saveImagePath(null);
    if (oldPath != null) {
      final file = File(oldPath);
      if (await file.exists()) await file.delete();
    }
    if (mounted) setState(() => _imagePath = null);
  }

  void _changeMode(PracticeMode mode) {
    _mode = mode;
    _round = 0;
    _score = 0;
    _newQuestion();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        if (_imagePath != null)
          Image.file(
            File(_imagePath!),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(),
          ),
        Container(
          color: _imagePath == null
              ? const Color(0xFFF7F5FF)
              : Colors.white.withValues(alpha: .78),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mouse Practice',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 24),
                      SegmentedButton<PracticeMode>(
                        segments: const [
                          ButtonSegment(
                            value: PracticeMode.letters,
                            label: Text('ABC'),
                          ),
                          ButtonSegment(
                            value: PracticeMode.numbers,
                            label: Text('123'),
                          ),
                          ButtonSegment(
                            value: PracticeMode.urdu,
                            label: Text('اردو'),
                          ),
                          ButtonSegment(
                            value: PracticeMode.mixed,
                            label: Text('Mix'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (value) => _changeMode(value.first),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _pickPicture,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          _imagePath == null ? 'Add picture' : 'Change picture',
                        ),
                      ),
                      if (_imagePath != null)
                        IconButton(
                          tooltip: 'Remove picture',
                          onPressed: _removePicture,
                          icon: const Icon(Icons.hide_image_outlined),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatusPill(
                      icon: Icons.stars_rounded,
                      text: 'Score  $_score',
                      color: const Color(0xFFFFA800),
                    ),
                    const SizedBox(width: 12),
                    _StatusPill(
                      icon: Icons.flag_rounded,
                      text: 'Round  $_round',
                      color: const Color(0xFF00A884),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _message.startsWith('Almost')
                        ? Colors.deepOrange
                        : const Color(0xFF4E4865),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Click on',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x446C5CE7),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Text(
                        _target,
                        key: const Key('target'),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.18,
                            ),
                        itemCount: _choices.length,
                        itemBuilder: (_, i) {
                          final value = _choices[i];
                          return _AnswerTile(
                            value: value,
                            isWrong: _lastWrong == value,
                            onTap: () => _choose(value),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Move the pointer onto a card, then press the left mouse button.',
                  style: TextStyle(color: Color(0xFF6B6680), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: color.withValues(alpha: .3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _AnswerTile extends StatefulWidget {
  const _AnswerTile({
    required this.value,
    required this.isWrong,
    required this.onTap,
  });
  final String value;
  final bool isWrong;
  final VoidCallback onTap;
  @override
  State<_AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<_AnswerTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF6C5CE7),
      Color(0xFF00A884),
      Color(0xFFFF8A65),
      Color(0xFF318CE7),
    ];
    final color = widget.isWrong
        ? Colors.redAccent
        : colors[widget.value.codeUnitAt(0) % colors.length];
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.07 : 1,
        duration: const Duration(milliseconds: 130),
        child: Material(
          color: color.withValues(alpha: _hovered ? .98 : .9),
          elevation: _hovered ? 10 : 3,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            key: Key('answer-${widget.value}'),
            borderRadius: BorderRadius.circular(22),
            onTap: widget.onTap,
            child: Center(
              child: Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Balloon {
  _Balloon({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });

  final int id;
  final double x;
  double y;
  final double size;
  final Color color;
  bool popping = false;
}

class BalloonSpeedGame extends StatefulWidget {
  const BalloonSpeedGame({super.key, required this.learnerName});

  final String learnerName;

  @override
  State<BalloonSpeedGame> createState() => _BalloonSpeedGameState();
}

class _BalloonSpeedGameState extends State<BalloonSpeedGame> {
  static const _colors = [
    Color(0xFFFF5D8F),
    Color(0xFFFFA62B),
    Color(0xFF41C7B5),
    Color(0xFF6C5CE7),
    Color(0xFF3A86FF),
    Color(0xFFFF70A6),
  ];

  final _random = Random();
  final List<_Balloon> _balloons = [];
  Timer? _gameTimer;
  DateTime? _lastTick;
  Duration _sinceSpawn = Duration.zero;
  int _nextId = 0;
  int _speed = 3;
  int _hits = 0;
  int _misses = 0;
  int _hitGoal = balloonHitsToEndGame;
  int _missGoal = balloonMissesToEndGame;
  bool _playing = false;
  bool _finished = false;
  bool _won = false;

  Duration get _spawnDelay => Duration(milliseconds: 1550 - (_speed * 190));
  double get _travelPerSecond => .075 + (_speed * .032);

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _gameTimer?.cancel();
    setState(() {
      _balloons.clear();
      _hits = 0;
      _misses = 0;
      _finished = false;
      _won = false;
      _playing = true;
      _sinceSpawn = _spawnDelay;
    });
    _lastTick = DateTime.now();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), _tick);
  }

  void _tick(Timer timer) {
    if (!_playing || !mounted) return;
    final now = DateTime.now();
    final elapsed = now.difference(_lastTick!);
    _lastTick = now;
    _sinceSpawn += elapsed;
    final movement = _travelPerSecond * elapsed.inMicroseconds / 1000000;
    var missedThisFrame = 0;

    setState(() {
      for (final balloon in _balloons) {
        if (!balloon.popping) balloon.y -= movement;
      }
      _balloons.removeWhere((balloon) {
        if (!balloon.popping && balloon.y < -.16) {
          missedThisFrame++;
          return true;
        }
        return false;
      });
      _misses += missedThisFrame;
      if (_sinceSpawn >= _spawnDelay) {
        _sinceSpawn = Duration.zero;
        _addBalloon();
      }
    });
    if (_misses >= _missGoal) _endGame(won: false);
  }

  void _addBalloon() {
    final size = 62.0 + _random.nextDouble() * 25;
    _balloons.add(
      _Balloon(
        id: _nextId++,
        x: .04 + _random.nextDouble() * .84,
        y: 1.02,
        size: size,
        color: _colors[_random.nextInt(_colors.length)],
      ),
    );
  }

  void _pop(_Balloon balloon) {
    if (!_playing || balloon.popping) return;
    setState(() {
      balloon.popping = true;
      _hits++;
    });
    if (_hits >= _hitGoal) {
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (mounted) _endGame(won: true);
      });
    } else {
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _balloons.remove(balloon));
      });
    }
  }

  void _endGame({required bool won}) {
    if (!_playing) return;
    _gameTimer?.cancel();
    setState(() {
      _playing = false;
      _finished = true;
      _won = won;
      _balloons.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBDEBFF), Color(0xFFE9E2FF), Color(0xFFFFF1B8)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Balloon Pop!',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  _StatusPill(
                    icon: Icons.ads_click_rounded,
                    text: 'Hits  $_hits / $_hitGoal',
                    color: const Color(0xFF00A884),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    icon: Icons.heart_broken_rounded,
                    text: 'Misses  $_misses / $_missGoal',
                    color: const Color(0xFFE84A5F),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Icon(Icons.speed_rounded, color: Color(0xFF6C5CE7)),
                  const SizedBox(width: 8),
                  Text(
                    'Speed $_speed',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    width: 260,
                    child: Slider(
                      key: const Key('balloon-speed'),
                      value: _speed.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_speed',
                      onChanged: _playing
                          ? null
                          : (value) => setState(() => _speed = value.round()),
                    ),
                  ),
                  Text(
                    _speed <= 2
                        ? 'Easy'
                        : (_speed <= 4 ? 'Quick' : 'Super fast!'),
                    style: const TextStyle(color: Color(0xFF625B78)),
                  ),
                  _GoalStepper(
                    label: 'Hit goal',
                    value: _hitGoal,
                    enabled: !_playing,
                    min: 5,
                    max: 50,
                    step: 5,
                    onChanged: (value) => setState(() => _hitGoal = value),
                  ),
                  _GoalStepper(
                    label: 'Miss limit',
                    value: _missGoal,
                    enabled: !_playing,
                    min: 1,
                    max: 25,
                    step: 1,
                    onChanged: (value) => setState(() => _missGoal = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .32),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned(
                            left: 24,
                            top: 20,
                            child: Icon(
                              Icons.cloud,
                              size: 90,
                              color: Colors.white70,
                            ),
                          ),
                          const Positioned(
                            right: 50,
                            top: 90,
                            child: Icon(
                              Icons.cloud,
                              size: 120,
                              color: Colors.white54,
                            ),
                          ),
                          for (final balloon in _balloons)
                            Positioned(
                              key: ValueKey(balloon.id),
                              left:
                                  balloon.x *
                                  (constraints.maxWidth - balloon.size),
                              top: balloon.y * constraints.maxHeight,
                              child: _BalloonWidget(
                                balloon: balloon,
                                onTap: () => _pop(balloon),
                              ),
                            ),
                          if (!_playing) Center(child: _buildGameCard()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildGameCard() => Card(
    elevation: 12,
    color: _finished
        ? (_won ? const Color(0xFFE8FFF3) : const Color(0xFFFFECEF))
        : Colors.white,
    shadowColor: _finished
        ? (_won ? const Color(0x8800A884) : const Color(0x88E84A5F))
        : const Color(0x556C5CE7),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_finished)
              _GameResultVisual(won: _won)
            else
              const Text('🎈', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              _finished ? (_won ? 'YOU WIN!' : 'GAME OVER') : 'Ready to pop?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _finished ? 34 : 28,
                fontWeight: FontWeight.w900,
                color: !_finished
                    ? null
                    : (_won
                          ? const Color(0xFF00875F)
                          : const Color(0xFFD9364F)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _finished
                  ? (_won
                        ? 'Amazing, ${widget.learnerName}! You popped $_hits balloons!'
                        : 'Good try, ${widget.learnerName}! You popped $_hits balloons.')
                  : 'Click $_hitGoal balloons before $_missGoal float away.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, color: Color(0xFF625B78)),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('start-balloon-game'),
              onPressed: _startGame,
              icon: Icon(
                _finished ? Icons.replay_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(_finished ? 'Play Again' : 'Start Game'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BalloonWidget extends StatelessWidget {
  const _BalloonWidget({required this.balloon, required this.onTap});

  final _Balloon balloon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        scale: balloon.popping ? 1.8 : 1,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          opacity: balloon.popping ? 0 : 1,
          child: SizedBox(
            width: balloon.size,
            height: balloon.size * 1.38,
            child: CustomPaint(painter: _BalloonPainter(balloon.color)),
          ),
        ),
      ),
    ),
  );
}

class _BalloonPainter extends CustomPainter {
  const _BalloonPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final balloonHeight = size.height * .72;
    final oval = Rect.fromLTWH(2, 1, size.width - 4, balloonHeight);
    canvas.drawOval(oval, Paint()..color = color);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .2,
        size.height * .1,
        size.width * .18,
        size.height * .2,
      ),
      Paint()..color = Colors.white.withValues(alpha: .48),
    );
    final knot = Path()
      ..moveTo(size.width / 2, balloonHeight - 1)
      ..lineTo(size.width * .42, balloonHeight + 10)
      ..lineTo(size.width * .58, balloonHeight + 10)
      ..close();
    canvas.drawPath(knot, Paint()..color = color.withValues(alpha: .9));
    canvas.drawLine(
      Offset(size.width / 2, balloonHeight + 10),
      Offset(size.width * .44, size.height),
      Paint()
        ..color = const Color(0xFF756D88)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GoalStepper extends StatelessWidget {
  const _GoalStepper({
    required this.label,
    required this.value,
    required this.enabled,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });
  final String label;
  final int value, min, max, step;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .85),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Decrease $label',
          onPressed: enabled && value > min
              ? () => onChanged(value - step < min ? min : value - step)
              : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Increase $label',
          onPressed: enabled && value < max
              ? () => onChanged(value + step > max ? max : value + step)
              : null,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    ),
  );
}

class StarTargetGame extends StatefulWidget {
  const StarTargetGame({super.key, required this.learnerName});
  final String learnerName;
  @override
  State<StarTargetGame> createState() => _StarTargetGameState();
}

class _StarTargetGameState extends State<StarTargetGame> {
  final _random = Random();
  Timer? _timer;
  int _speed = 3,
      _hitGoal = 20,
      _missGoal = 10,
      _hits = 0,
      _misses = 0,
      _targetNumber = 0;
  double _x = 0, _y = 0, _remaining = 1;
  bool _playing = false, _finished = false, _won = false;
  double get _secondsPerTarget => 2.25 - (_speed * .27);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _hits = 0;
      _misses = 0;
      _finished = false;
      _won = false;
      _playing = true;
    });
    _next();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_playing || !mounted) return;
      setState(() => _remaining -= .04 / _secondsPerTarget);
      if (_remaining <= 0) {
        _misses++;
        _misses >= _missGoal ? _end(false) : _next();
      }
    });
  }

  void _next() => setState(() {
    _targetNumber++;
    _x = _random.nextDouble() * 1.7 - .85;
    _y = _random.nextDouble() * 1.5 - .7;
    _remaining = 1;
  });

  void _hit() {
    if (!_playing) return;
    _hits++;
    _hits >= _hitGoal ? _end(true) : _next();
  }

  void _end(bool won) {
    _timer?.cancel();
    setState(() {
      _playing = false;
      _finished = true;
      _won = won;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17153B), Color(0xFF433D8B), Color(0xFF2E236C)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Star Target Challenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  _StatusPill(
                    icon: Icons.bolt_rounded,
                    text: 'Hits  $_hits / $_hitGoal',
                    color: const Color(0xFF00C897),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    icon: Icons.close_rounded,
                    text: 'Misses  $_misses / $_missGoal',
                    color: const Color(0xFFFF5D8F),
                  ),
                ],
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                const Text(
                  'Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: Slider(
                    value: _speed.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_speed',
                    onChanged: _playing
                        ? null
                        : (v) => setState(() => _speed = v.round()),
                  ),
                ),
                _GoalStepper(
                  label: 'Hit goal',
                  value: _hitGoal,
                  enabled: !_playing,
                  min: 5,
                  max: 50,
                  step: 5,
                  onChanged: (v) => setState(() => _hitGoal = v),
                ),
                _GoalStepper(
                  label: 'Miss limit',
                  value: _missGoal,
                  enabled: !_playing,
                  min: 1,
                  max: 25,
                  step: 1,
                  onChanged: (v) => setState(() => _missGoal = v),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10102A),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 24),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const CustomPaint(painter: _StarFieldPainter()),
                      if (_playing)
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 130),
                          alignment: Alignment(_x, _y),
                          child: _SpeedTarget(
                            key: ValueKey(_targetNumber),
                            remaining: _remaining.clamp(0.0, 1.0).toDouble(),
                            onTap: _hit,
                          ),
                        ),
                      if (!_playing) Center(child: _gameCard()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _gameCard() => Card(
    elevation: 14,
    color: _finished
        ? (_won ? const Color(0xFFE8FFF3) : const Color(0xFFFFECEF))
        : Colors.white,
    shadowColor: _finished
        ? (_won ? const Color(0xAA00C897) : const Color(0xAAFF5D8F))
        : Colors.black54,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_finished)
              _GameResultVisual(won: _won)
            else
              const Icon(
                Icons.stars_rounded,
                size: 68,
                color: Color(0xFFFFC857),
              ),
            Text(
              !_finished
                  ? 'How fast can you click?'
                  : (_won ? 'YOU WIN!' : 'GAME OVER'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _finished ? 34 : 27,
                color: !_finished
                    ? null
                    : (_won
                          ? const Color(0xFF00875F)
                          : const Color(0xFFD9364F)),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              !_finished
                  ? 'Click each star before its ring runs out. The star jumps after every click.'
                  : (_won
                        ? 'Lightning fast, ${widget.learnerName}! $_hits targets hit.'
                        : 'Nice try, ${widget.learnerName}! $_hits targets hit.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF625B78)),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('start-target-game'),
              onPressed: _start,
              icon: Icon(
                _finished ? Icons.replay_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(_finished ? 'Play Again' : 'Start Challenge'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GameResultVisual extends StatelessWidget {
  const _GameResultVisual({required this.won});

  final bool won;

  @override
  Widget build(BuildContext context) {
    final color = won ? const Color(0xFF00A884) : const Color(0xFFE84A5F);
    return SizedBox(
      width: 180,
      height: 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (won) ...[
            const Positioned(
              left: 4,
              top: 12,
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFB800),
                size: 35,
              ),
            ),
            const Positioned(
              right: 5,
              top: 28,
              child: Icon(
                Icons.star_rounded,
                color: Color(0xFFFF8A00),
                size: 32,
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 4,
              child: Icon(
                Icons.celebration_rounded,
                color: Color(0xFF6C5CE7),
                size: 30,
              ),
            ),
          ] else ...[
            const Positioned(
              left: 7,
              top: 18,
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFFFF8A9A),
                size: 38,
              ),
            ),
            const Positioned(
              right: 8,
              bottom: 13,
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFFFF8A9A),
                size: 32,
              ),
            ),
          ],
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 7),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .42),
                  blurRadius: 22,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              won ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
              color: Colors.white,
              size: 72,
            ),
          ),
          Positioned(
            right: 21,
            top: 9,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: won ? const Color(0xFF25D366) : const Color(0xFFD7193F),
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Icon(
                won ? Icons.check_rounded : Icons.close_rounded,
                color: Colors.white,
                size: 31,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedTarget extends StatelessWidget {
  const _SpeedTarget({super.key, required this.remaining, required this.onTap});
  final double remaining;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: CircularProgressIndicator(
                value: remaining,
                strokeWidth: 8,
                color: remaining < .3
                    ? const Color(0xFFFF5D8F)
                    : const Color(0xFF52E5E7),
                backgroundColor: Colors.white12,
              ),
            ),
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFFF1A8), Color(0xFFFFA62B)],
                ),
                boxShadow: [
                  BoxShadow(color: Color(0xAAFFC857), blurRadius: 24),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 57,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..color = Colors.white.withValues(alpha: .5);
    for (var i = 0; i < 70; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        .7 + random.nextDouble() * 1.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
