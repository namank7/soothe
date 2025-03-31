import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.Soothe.channel.audio',
    androidNotificationChannelName: 'Soothe Audio playback',
    androidNotificationOngoing: true,
    preloadArtwork: true,
  );
  runApp(SootheApp());
}

class SootheApp extends StatelessWidget {
  const SootheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soothe',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        drawerTheme: DrawerThemeData(backgroundColor: Colors.black),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(
            fontFamily: 'Bristol',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color.fromARGB(255, 215, 33, 243),
                blurRadius: 0,
                offset: Offset(0, 0),
              ),
              Shadow(
                color: const Color.fromARGB(255, 215, 33, 243),
                blurRadius: 7,
              ),
              Shadow(
                color: const Color.fromARGB(255, 215, 33, 243),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        primaryColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SootheScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A1B5D), Color(0xFF1C1347)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 35, 151, 245),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/app_icon.png'),
                ),
                SizedBox(height: 50),
                // Text(
                //   'Soothe',
                //   style: TextStyle(
                //     fontFamily: 'Bristol',
                //     fontSize: 36,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     letterSpacing: 2,
                //   ),
                // ),
                SizedBox(height: 8),
                Text(
                  'Relax . Unwind . Focus',
                  style: TextStyle(
                    fontFamily: 'Bristol',
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SootheScreen extends StatefulWidget {
  const SootheScreen({super.key});

  @override
  _SootheScreenState createState() => _SootheScreenState();
}

class _SootheScreenState extends State<SootheScreen> {
  late AudioPlayer _audioPlayer;
  String? _currentSound;
  bool _isPlaying = false;
  Map<String, String>? _currentSoundData;
  Duration? _timerDuration;
  Timer? _timer;
  double _progress = 0;
  Timer? _progressTimer;
  int _remainingSeconds = 0;

  final Map<String, List<Map<String, String>>> soundCategories = {
    'Nature': [
      {
        'name': 'Rain',
        'file': 'nature/rain.mp3',
        'image': 'assets/images/rain.png',
      },
      {
        'name': 'Wind',
        'file': 'nature/wind.mp3',
        'image': 'assets/images/wind.png',
      },
      {
        'name': 'Waterfall',
        'file': 'nature/waterfall.mp3',
        'image': 'assets/images/waterfall.png',
      },
      {
        'name': 'River',
        'file': 'nature/river.mp3',
        'image': 'assets/images/river.png',
      },
      {
        'name': 'Beach',
        'file': 'nature/beach.mp3',
        'image': 'assets/images/beach.png',
      },
      {
        'name': 'Thunder',
        'file': 'nature/thunder.mp3',
        'image': 'assets/images/thunder.png',
      },
    ],
    'Meditation': [
      {
        'name': 'Meditation',
        'file': 'meditation/meditation.mp3',
        'image': 'assets/images/meditation.png',
      },
      {
        'name': 'Ohm',
        'file': 'meditation/ohm.wav',
        'image': 'assets/images/ohm.png',
      },
      {
        'name': 'Om',
        'file': 'meditation/om.mp3',
        'image': 'assets/images/om.png',
      },
      {
        'name': 'Tibetan Chanting',
        'file': 'meditation/tibetan-chanting.aiff',
        'image': 'assets/images/tibetan-chanting.png',
      },
      {
        'name': 'Singing Bowl',
        'file': 'meditation/singing-bowl.mp3',
        'image': 'assets/images/singing-bowl.png',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setLoopMode(LoopMode.one); // Enable looping by default
    _audioPlayer.playbackEventStream.listen((event) {
      setState(() {
        _isPlaying = _audioPlayer.playing;
      });
    });
  }

  void _playSound(String file, Map<String, String> soundData) async {
    try {
      // If the same sound is playing, pause it
      if (_currentSound == file && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
        return;
      }

      // Update UI state
      setState(() {
        _currentSound = file;
        _currentSoundData = soundData;
      });

      // Stop current playback if any
      await _audioPlayer.stop();

      try {
        // Set new audio source and play
        await _audioPlayer.setAudioSource(
          AudioSource.asset(
            'assets/audio/$file',
            tag: MediaItem(
              id: file,
              album: 'Soothe Your Mind',
              title: soundData['name'] ?? '',
              artUri: Uri.parse('asset://${soundData['image']}'),
              displayTitle: soundData['name'] ?? '',
              displaySubtitle: 'Soothing Sounds',
            ),
          ),
        );
        await _audioPlayer.play();

        if (!mounted) return;
        setState(() {
          _isPlaying = true;
        });
      } catch (audioError) {
        print("Error loading audio file: $audioError");
        if (!mounted) return;
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play this sound format'),
            backgroundColor: Colors.red,
          ),
        );
        // Reset state
        setState(() {
          _currentSound = null;
          _currentSoundData = null;
          _isPlaying = false;
        });
      }
    } catch (e) {
      print("Error in playSound: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while playing the sound'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Safer version of play button onPressed handler
  void _handlePlayPress() {
    if (_currentSound != null && _currentSoundData != null) {
      _playSound(_currentSound!, _currentSoundData!);
    }
  }

  // Image error handler
  Widget _buildSafeImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print("Error loading image $imagePath: $error");
        return Container(
          color: Colors.grey[900],
          child: Icon(Icons.image_not_supported, color: Colors.white54),
        );
      },
    );
  }

  void _startTimer() {
    if (_timerDuration == null) return;

    _timer?.cancel();
    _progressTimer?.cancel();

    final totalSeconds = _timerDuration!.inSeconds;
    _remainingSeconds = totalSeconds;

    setState(() {
      _progress = 1.0;
    });

    _progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _progressTimer?.cancel();
        _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
          _timerDuration = null;
          _progress = 0;
          _remainingSeconds = 0;
        });
        return;
      }

      _remainingSeconds--;
      setState(() {
        _progress = _remainingSeconds / totalSeconds;
      });
    });
  }

  void _showTimerPicker() {
    int selectedMinutes = (_timerDuration?.inMinutes ?? 0);
    final ScrollController minutesController = FixedExtentScrollController(
      initialItem: selectedMinutes > 0 ? selectedMinutes - 1 : 0,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A1B5D), Color(0xFF1C1347)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Sleep Timer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Text(
                    'How long do you want to play for?',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 150,
                        child: ListWheelScrollView.useDelegate(
                          controller: minutesController,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            selectedMinutes = index + 1;
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 60,
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Text(
                        'minutes',
                        style: TextStyle(color: Colors.white70, fontSize: 20),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final newDuration = Duration(minutes: selectedMinutes);
                        setState(() {
                          _timerDuration = newDuration;
                        });
                        _startTimer();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Set Timer',
                        style: TextStyle(
                          color: Color(0xFF2A1B5D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relax . Unwind . Focus'),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: const Color.fromARGB(255, 169, 117, 177),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: soundCategories.length,
                  itemBuilder: (context, categoryIndex) {
                    String category = soundCategories.keys.elementAt(
                      categoryIndex,
                    );
                    List<Map<String, String>> sounds =
                        soundCategories[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ...sounds.map(
                          (sound) => ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(sound['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(sound['name']!),
                            onTap: () {
                              _playSound(sound['file']!, sound);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        if (categoryIndex < soundCategories.length - 1)
                          Divider(height: 1, thickness: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with error handling
          if (_currentSoundData != null)
            _buildSafeImage(_currentSoundData!['image']!)
          else
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/rain.gif'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print("Error loading background gif: $exception");
                  },
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final maxHeight = constraints.maxHeight;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container(
                        //   width: maxWidth * 0.3,
                        //   height: maxWidth * 0.3,
                        //   child: Image.asset('assets/images/app_icon.png'),
                        // ),
                        SizedBox(height: maxHeight * 0.02),
                        Text(
                          'Welcome to Soothe',
                          style: TextStyle(
                            fontFamily: 'Bristol',
                            fontSize: maxWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: maxHeight * 0.01),
                        Text(
                          'Select a sound from the menu to begin',
                          style: TextStyle(
                            fontSize: maxWidth * 0.04,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: maxHeight * 0.03),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: maxWidth * 0.05,
                            vertical: maxHeight * 0.015,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu, color: Colors.white70),
                              SizedBox(width: 8),
                              Text(
                                'Open Menu',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: maxWidth * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.3)),
          if (_currentSound != null)
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  MediaQuery.of(context).padding.bottom +
                  MediaQuery.of(context).size.height * 0.02,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentSoundData?['name'] ?? '',
                        style: TextStyle(
                          fontSize: maxWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: maxWidth * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: maxWidth * 0.12,
                                    height: maxWidth * 0.12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black38,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_timerDuration != null)
                                          SizedBox(
                                            width: maxWidth * 0.12,
                                            height: maxWidth * 0.12,
                                            child: CircularProgressIndicator(
                                              value: _progress,
                                              backgroundColor: Colors.white24,
                                              color: Colors.blue,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.timer,
                                            size: maxWidth * 0.08,
                                            color:
                                                _timerDuration != null
                                                    ? Colors.blue
                                                    : Colors.white,
                                          ),
                                          onPressed: _showTimerPicker,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_timerDuration != null &&
                                      _remainingSeconds > 0)
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: maxWidth * 0.02,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: maxWidth * 0.02,
                                        vertical: maxWidth * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          221,
                                          236,
                                          70,
                                          70,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: maxWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: maxWidth * 0.05),
                          Container(
                            width: maxWidth * 0.16,
                            height: maxWidth * 0.16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black38,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    35,
                                    151,
                                    245,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: maxWidth * 0.16,
                                color: Colors.white,
                              ),
                              onPressed: _handlePlayPress,
                            ),
                          ),
                          SizedBox(width: maxWidth * 0.05),
                          Container(
                            width: maxWidth * 0.12,
                            height: maxWidth * 0.12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black38,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                size: maxWidth * 0.08,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Share.share(
                                  'Check out Soothe - a beautiful app for relaxing sounds and better sleep! Lifetime subscription for 5 bucks! https://mypathshala.com',
                                  subject: 'Try Soothe App',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
