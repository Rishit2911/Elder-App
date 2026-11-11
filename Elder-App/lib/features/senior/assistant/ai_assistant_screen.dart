import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/circular_sos_button.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'नमस्ते दादाजी! I am RAM, your personal AI care companion. How can I help you today? You can ask about your medicines, health readings, or upcoming family visits.',
    },
  ];
  bool _isListening = false;

  final List<String> _quickPrompts = [
    'Did I take my morning medicine?',
    'What was my last BP reading?',
    'When is my next doctor visit?',
    'When is Rajesh visiting?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendQuery(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _textController.clear();
    });

    String answer = 'I checked your profile: ';
    final qLower = query.toLowerCase();

    if (qLower.contains('medicine') || qLower.contains('tablet') || qLower.contains('morning')) {
      answer += 'Yes! Your morning Vitamin D3 was logged as taken at 08:05 AM. Your afternoon Calcium Citrate is scheduled at 01:30 PM (after lunch).';
    } else if (qLower.contains('bp') || qLower.contains('blood pressure') || qLower.contains('reading')) {
      answer += 'Your latest blood pressure was recorded at 10:30 AM: 120/80 mmHg, which is in the healthy normal range. Heart rate was 72 bpm.';
    } else if (qLower.contains('doctor') || qLower.contains('appointment')) {
      answer += 'You have an appointment with Dr. Alok Sharma (Cardiologist) tomorrow at 11:00 AM at Apollo Super Specialty Hospital.';
    } else if (qLower.contains('rajesh') || qLower.contains('visit') || qLower.contains('family')) {
      answer += 'Your son Rajesh checked in today. He is scheduled to visit this Sunday at 04:00 PM for evening tea!';
    } else {
      answer += 'I have noted your request. You can also press the emergency SOS button anytime if you require immediate help.';
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'assistant', 'text': answer});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.mintGreen,
              child: Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RAM AI Assistant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy)),
                Text('Online • Voice & Text Companion', style: TextStyle(fontSize: 11, color: AppColors.mintGreen, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Chat conversation list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['sender'] == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isUser ? AppColors.primaryBlue : AppColors.cardBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          msg['text']!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: isUser ? Colors.white : AppColors.textPrimary,
                            fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Quick question suggestion chips
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _quickPrompts.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: AppColors.mintBg,
                        side: const BorderSide(color: AppColors.mintGreen, width: 0.8),
                        label: Text(
                          _quickPrompts[i],
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E6C47),
                          ),
                        ),
                        onPressed: () => _sendQuery(_quickPrompts[i]),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Input bar
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isListening = !_isListening;
                        });
                        if (_isListening) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Listening to voice... Speak now'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: _isListening ? AppColors.coralRed : AppColors.mintBg,
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening ? Colors.white : AppColors.mintGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _sendQuery,
                        decoration: InputDecoration(
                          hintText: 'Ask RAM anything...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue),
                      onPressed: () => _sendQuery(_textController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating SOS button
          Positioned(
            right: 20,
            bottom: 90,
            child: const CircularSOSButton(),
          ),
        ],
      ),
    );
  }
}
