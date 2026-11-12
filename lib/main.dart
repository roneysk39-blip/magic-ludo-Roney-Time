import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MagicLudoApp());
}

class MagicLudoApp extends StatelessWidget {
  const MagicLudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ম্যাজিক লুডু লাইভ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF59E0B),
          brightness: Brightness.dark,
        ),
      ),
      home: const LobbyScreen(),
    );
  }
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _roomController = TextEditingController(text: "LUDO-786");
  final TextEditingController _nameController = TextEditingController(text: "খেলোয়াড় ১");

  Future<void> _joinRoom() async {
    await [Permission.camera, Permission.microphone].request();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          roomId: _roomController.text.trim(),
          playerName: _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch, size: 72, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'ম্যাজিক লুডু ও ভিডিও কল',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'রকেট বুস্ট • ম্যাজিক ছক্কা • লাইভ ভিডিও আড্ডা',
                style: TextStyle(color: Colors.amberAccent),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'আপনার নাম',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'রুম কোড (বন্ধুদের শেয়ার করুন)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _joinRoom,
                  icon: const Icon(Icons.videocam),
                  label: const Text('গেম ও ভিডিও কল শুরু করুন', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String roomId;
  final String playerName;

  const GameScreen({super.key, required this.roomId, required this.playerName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _diceValue = 6;
  int _magicDiceLeft = 2;
  int _rocketBoostLeft = 2;
  bool _micOn = true;
  bool _camOn = true;
  String _statusMessage = "আপনার চাল! সাধারণ ছক্কা বা ম্যাজিক পাওয়ার ব্যবহার করুন।";

  final List<int> _positions = [1, 1, 1, 1];
  final List<String> _playerNames = ["আপনি (লাল)", "বন্ধু ১ (সবুজ)", "বন্ধু ২ (হলুদ)", "বন্ধু ৩ (নীল)"];
  final List<Color> _playerColors = [Colors.redAccent, Colors.green, Colors.amber, Colors.blueAccent];
  int _currentTurn = 0;

  final List<int> _rocketTiles = [5, 14, 23, 32, 41, 48];

  void _rollDice({bool isMagicSix = false}) {
    setState(() {
      if (isMagicSix) {
        if (_magicDiceLeft <= 0) return;
        _magicDiceLeft--;
        _diceValue = 6;
        _statusMessage = "✨ ম্যাজিক ছক্কা ব্যবহার হয়েছে! নিশ্চিত ৬ উঠেছে!";
      } else {
        _diceValue = Random().nextInt(6) + 1;
        _statusMessage = "${_playerNames[_currentTurn]}-এর উঠেছে: $_diceValue";
      }

      int newPos = _positions[_currentTurn] + _diceValue;

      if (_rocketTiles.contains(newPos)) {
        newPos += 6;
        _statusMessage = "🚀 রকেট বুস্ট! গুটি আরও ৬ ঘর এগিয়ে গেল!";
      }

      if (newPos >= 57) {
        newPos = 57;
        _statusMessage = "🏆 অভিনন্দন! ${_playerNames[_currentTurn]} বিজয়ী হয়েছে!";
      }
      _positions[_currentTurn] = newPos;

      if (_diceValue != 6) {
        _currentTurn = (_currentTurn + 1) % 4;
      }
    });
  }

  void _useManualRocket() {
    if (_rocketBoostLeft <= 0) return;
    setState(() {
      _rocketBoostLeft--;
      _positions[0] = min(57, _positions[0] + 8);
      _statusMessage = "🚀 স্পেশাল রকেট নিক্ষেপ! আপনার গুটি সরাসরি ৮ ঘর এগিয়ে গেছে!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('রুম: ${widget.roomId}'),
        actions: [
          IconButton(
            icon: Icon(_micOn ? Icons.mic : Icons.mic_off, color: _micOn ? Colors.greenAccent : Colors.red),
            onPressed: () => setState(() => _micOn = !_micOn),
          ),
          IconButton(
            icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off, color: _camOn ? Colors.greenAccent : Colors.red),
            onPressed: () => setState(() => _camOn = !_camOn),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 115,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currentTurn == index ? _playerColors[index] : Colors.white24,
                        width: _currentTurn == index ? 2.5 : 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          index == 0 && !_camOn ? Icons.videocam_off : Icons.person,
                          size: 36,
                          color: _playerColors[index],
                        ),
                        Positioned(
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _playerNames[index].split(' ')[0],
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.amber.withOpacity(0.15),
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                padding: constیدیגר EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "🚀 বোর্ডে রকেট ঘরসমূহ: ৫, ১৪, ২৩, ৩২, ৪১, ৪৮",
                      style: TextStyle(fontSize: 12, color: Colors.cyanAccent),
                    ),
                    ...List.generate(4, (i) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_playerNames[i], style: TextStyle(color: _playerColors[i], fontWeight: FontWeight.bold)),
                              Text("ঘর: ${_positions[i]} / ৫৭"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: _positions[i] / 57.0,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(8),
                            color: _playerColors[i],
                            backgroundColor: Colors.white12,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _magicDiceLeft > 0 ? () => _rollDice(isMagicSix: true) : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text("ম্যাজিক ৬ ($_magicDiceLeft)"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white),
                ),
                GestureDetector(
                  onTap: () => _rollDice(),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.amberAccent, blurRadius: 10)],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$_diceValue",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _rocketBoostLeft > 0 ? _useManualRocket : null,
                  icon: const Icon(Icons.rocket_launch),
                  label: Text("রকেট ($_rocketBoostLeft)"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
