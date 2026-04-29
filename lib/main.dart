import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize ads on mobile
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  runApp(const BellyMeterApp());
}

class BellyMeterApp extends StatelessWidget {
  const BellyMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belly Meter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NameEntryPage(),
    );
  }
}

class NameEntryPage extends StatefulWidget {
  const NameEntryPage({super.key});

  @override
  State<NameEntryPage> createState() => _NameEntryPageState();
}

class _NameEntryPageState extends State<NameEntryPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Name')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.fitHeight),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'What’s your name?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(childName: name),
                      ),
                    );
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  final String childName;
  const HomePage({super.key, required this.childName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 1000);
  int currentPage = 1000;

  final List<String> avatarPaths = [
    'assets/images/boy.png',
    'assets/images/girl.png',
    'assets/images/dino.png',
    'assets/images/Ptera.png',
    'assets/images/Unicorn.png',
    'assets/images/Red Panda.png',
    'assets/images/Panda.png',
    'assets/images/Lion.png',
    'assets/images/Dragon.png',
    'assets/images/Lemur.png',
    'assets/images/Dog.png',
    'assets/images/Cat.png',
  ];

  void _goToPage(int offset) {
    setState(() {
      currentPage += offset;
    });
    _pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  int get realIndex => currentPage % avatarPaths.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Avatar')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.fitHeight),
          Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, size: 40),
                    onPressed: () => _goToPage(-1),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => currentPage = index),
                        itemBuilder: (context, index) {
                          final actualIndex = index % avatarPaths.length;
                          final path = avatarPaths[actualIndex];
                          final isSelected = actualIndex == realIndex;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BellyHomePage(
                                    childName: widget.childName,
                                    avatarPath: path,
                                  ),
                                ),
                              );
                            },
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (isSelected)
                                    Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueAccent.withOpacity(0.8),
                                            blurRadius: 60,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(
                                    width: 220,
                                    height: 220,
                                    child: Image.asset(path, fit: BoxFit.contain),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, size: 40),
                    onPressed: () => _goToPage(1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class BellyHomePage extends StatefulWidget {
  final String childName;
  final String avatarPath;

  const BellyHomePage({super.key, required this.childName, required this.avatarPath});

  @override
  State<BellyHomePage> createState() => _BellyHomePageState();
}

class _BellyHomePageState extends State<BellyHomePage> with TickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isBannerReady = false;
  double bellyFullness = 0.0;
  double targetFullness = 0.0;
  double _startFullness = 0.0;
  double _parentSelectedFullness = 50.0;
  bool isScanning = false;
  bool showBellyFill = false;
  bool showHappyFace = false;
  double _bellyNudgeX = 0;
  double _bellyNudgeY = 0;
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;
Timer? _fillTimer;
DateTime? _fillStartTime;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, Rect> avatarBellyMap = {
    'assets/images/boy.png':       Rect.fromLTWH(295, 515, 180, 145),
    'assets/images/girl.png':      Rect.fromLTWH(310, 515, 180, 145),
    'assets/images/Cat.png':       Rect.fromLTWH(290, 515, 180, 145),
    'assets/images/dino.png':      Rect.fromLTWH(290, 515, 180, 145),
    'assets/images/Dog.png':       Rect.fromLTWH(290, 515, 180, 154),
    'assets/images/Dragon.png':    Rect.fromLTWH(285, 515, 180, 145),
    'assets/images/Lemur.png':     Rect.fromLTWH(290, 515, 180, 145),
    'assets/images/Lion.png':      Rect.fromLTWH(290, 515, 180, 145),
    'assets/images/Panda.png':     Rect.fromLTWH(200, 515, 180, 145),
    'assets/images/Ptera.png':     Rect.fromLTWH(290, 515, 180, 150),
   'assets/images/Red Panda.png':  Rect.fromLTWH(215, 508, 180, 160),
   'assets/images/Unicorn.png':    Rect.fromLTWH(285, 515, 180, 145),
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 20).animate(_waveController);

    _fillController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _fillController.addListener(() {

  setState(() {
    bellyFullness =
        _startFullness + (targetFullness - _startFullness) * _fillController.value;
  });
});

    _fillController.addListener(() {
  setState(() {
    bellyFullness =
        _startFullness +
        (targetFullness - _startFullness) * _fillController.value;
  });
});
_bannerAd = BannerAd(
  adUnitId: 'ca-app-pub-3940256099942544/2934735716', // iOS TEST banner ad
  size: AdSize.banner,
  request: const AdRequest(),
  listener: BannerAdListener(
    onAdLoaded: (ad) {
      setState(() {
        _isBannerReady = true;
      });
    },
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Banner ad failed to load: $error');
    },
  ),
);

_bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _fillController.dispose();
    _audioPlayer.dispose();
    _fillTimer?.cancel();
    super.dispose();
  }

  void playSound(String filename) async {
    await _audioPlayer.play(AssetSource(filename));
  }

Future<void> startScanning(double fullness) async {
  // stop any previous animation
  _fillTimer?.cancel();

  setState(() {
    isScanning = true;
    showBellyFill = true;

    _startFullness = bellyFullness;
    targetFullness = fullness.clamp(0, 100);
  });

  playSound('sounds/scan.mp3');

  const int durationMs = 5000;
  _fillStartTime = DateTime.now();

  _fillTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
    final elapsed = DateTime.now().difference(_fillStartTime!).inMilliseconds;
    final t = (elapsed / durationMs).clamp(0.0, 1.0);

    // Ease-out feel (simple)
    final eased = 1 - (1 - t) * (1 - t);

    setState(() {
      bellyFullness = _startFullness + (targetFullness - _startFullness) * eased;
    });

    if (t >= 1.0) {
      timer.cancel();

      setState(() {
        isScanning = false;

        if (bellyFullness >= 99.5) {
          _confettiController.play();
          playSound('sounds/ding.mp3');
          showHappyFace = true;
        } else {
          playSound('sounds/fail.mp3');
          showHappyFace = false;
        }
      });
    }
  });
}



@override
Widget build(BuildContext context) {
  final bellyRect = avatarBellyMap[widget.avatarPath];

  return Scaffold(
    appBar: AppBar(title: const Text('Belly Meter')),

    body: LayoutBuilder(
      builder: (context, constraints) {
        const double baseW = 768;
        const double baseH = 1024;

        final double scale = constraints.maxWidth / baseW;
        final double scaleH = constraints.maxHeight / baseH;
        final double containScale = scale < scaleH ? scale : scaleH;

        final double drawnW = baseW * containScale;
        final double drawnH = baseH * containScale;

        final double offsetX = (constraints.maxWidth - drawnW) / 2;
        final double offsetY = (constraints.maxHeight - drawnH) / 2;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (bellyRect != null)
              Positioned(
                left: offsetX + (bellyRect.left * containScale),
                top: offsetY + (bellyRect.top * containScale),
                child: SizedBox(
                  width: bellyRect.width * containScale,
                  height: bellyRect.height * containScale,
                  child: ClipOval(
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: (bellyRect.height * containScale) *
                              (bellyFullness / 100).clamp(0.0, 1.0),
                          child: Container(
                            color: Colors.green.withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Center(
              child: SizedBox(
                width: drawnW,
                height: drawnH,
                child: Image.asset(widget.avatarPath, fit: BoxFit.contain),
              ),
            ),

            if (showHappyFace)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Good Job!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 8,
                  ),
                  onPressed: showParentInputDialog,
                  child: const Text('Ready to Scan!'),
                ),
              ),
            ),
          ],
        );
      },
    ),

    bottomNavigationBar: _isBannerReady
        ? SizedBox(
            height: _bannerAd.size.height.toDouble(),
            width: _bannerAd.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : null,
  );
}
  void showParentInputDialog() {
    _parentSelectedFullness = bellyFullness;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Parent Input'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fullness: ${_parentSelectedFullness.toInt()}%', style: const TextStyle(fontSize: 18)),
                  Slider(
                    value: _parentSelectedFullness,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${_parentSelectedFullness.toInt()}%',
                    onChanged: (value) => setState(() => _parentSelectedFullness = value),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
               

                    Navigator.of(context).pop();
                    startScanning(_parentSelectedFullness);
                  },
                  child: const Text('Start Scan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AnimatedWaveClipper extends CustomClipper<Path> {
  final double waveOffset;

  AnimatedWaveClipper(this.waveOffset);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 10);
    path.quadraticBezierTo(size.width * 0.25 + waveOffset, 0, size.width * 0.5 + waveOffset, 10);
    path.quadraticBezierTo(size.width * 0.75 + waveOffset, 20, size.width + waveOffset, 10);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant AnimatedWaveClipper oldClipper) {
    return oldClipper.waveOffset != waveOffset;
  }
}
