
import 'package:flutter/material.dart';

void main() {
  runApp(const ElderlySevaApp());
}

class ElderlySevaApp extends StatelessWidget {
  const ElderlySevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Seva',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF1F7FF),
      ),
      home: const HomeDashboard(),
    );
  }
}

class AppColors {
  static const navy = Color(0xFF102B58);
  static const muted = Color(0xFF5C7098);
  static const blue = Color(0xFF3E91F2);
  static const cream = Color(0xFFFFF8E6);
  static const mint = Color(0xFFDDF8E6);
  static const lavender = Color(0xFFF0EDFF);
  static const coral = Color(0xFFFF5555);
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAF5FF),
                Color(0xFFFFFEF7),
                Color(0xFFF0F7FF),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeaderSection(),
                      const SizedBox(height: 22),

                      // FAMILY AND MEDICINE CARDS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(
                            child: ImageServiceCard(
                              title: 'My Family',
                              subtitle: 'Your loved ones\nalways with you',
                              image: 'assets/images/family_illustration.png',
                              background: AppColors.cream,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ImageServiceCard(
                              title: 'My Medicines',
                              subtitle: 'Track your medicines\nand timings',
                              image: 'assets/images/medicine_illustration.png',
                              background: Color(0xFFE8F4FF),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // HEALTH AND DOCTOR
                      Row(
                        children: const [
                          Expanded(
                            child: SmallServiceCard(
                              title: 'Health Tracker',
                              subtitle: 'Monitor your\nhealth easily',
                              icon: Icons.favorite_rounded,
                              iconColor: Color(0xFFFF5D7D),
                              background: Color(0xFFE0F8E9),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: SmallServiceCard(
                              title: 'Talk to a Doctor',
                              subtitle: 'Get medical help\nanytime',
                              icon: Icons.medical_services_rounded,
                              iconColor: Color(0xFF4D91D9),
                              background: AppColors.lavender,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'More Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: const [
                          Expanded(
                            child: MoreServiceCard(
                              title: 'Book a Caregiver',
                              subtitle: 'Trusted daily assistance',
                              icon: Icons.volunteer_activism_rounded,
                              background: Color(0xFFFFE8D9),
                              iconColor: Color(0xFFEC8A55),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: MoreServiceCard(
                              title: 'Nearby Hospitals',
                              subtitle: 'Find medical help nearby',
                              icon: Icons.local_hospital_rounded,
                              background: Color(0xFFE6F0FF),
                              iconColor: Color(0xFF478DE0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const SOSCard(),

                      const SizedBox(height: 16),

                      const VoiceAssistantCard(),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),

              const BottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}

// HEADER

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 86,
          height: 86,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFB7DEFF),
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x223A78B8),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/dadaji_profile.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 13),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "नमस्ते दादाजी",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Take care and stay healthy!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            showMessage(context, 'Settings coming soon!');
          },
          icon: const Icon(
            Icons.settings_rounded,
            color: AppColors.navy,
            size: 27,
          ),
        ),
      ],
    );
  }
}

// LARGE IMAGE SERVICE CARDS

class ImageServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color background;

  const ImageServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      elevation: 3,
      shadowColor: const Color(0x22345C8A),
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          showMessage(context, '$title page coming soon!');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFD7E8FA),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: AspectRatio(
                  aspectRatio: 1.52,
                  child: Image.asset(
                    image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const CircleAvatar(
                          radius: 17,
                          backgroundColor: Color(0xFFBFE2FF),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF1674D0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// HEALTH AND DOCTOR CARDS

class SmallServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color background;

  const SmallServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          showMessage(context, '$title coming soon!');
        },
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 39, color: iconColor),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MORE SERVICES

class MoreServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color iconColor;

  const MoreServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          showMessage(context, '$title coming soon!');
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          constraints: const BoxConstraints(minHeight: 115),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 31, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SOS BUTTON

class SOSCard extends StatelessWidget {
  const SOSCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coral,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Emergency SOS'),
              content: const Text(
                'This is currently a demo button. Emergency calling and family alerts will be connected later.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 17,
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Emergency? Tap here for help',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.coral,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// VOICE ASSISTANT

class VoiceAssistantCard extends StatelessWidget {
  const VoiceAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          showMessage(context, 'Voice assistant coming soon!');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFB8EBC9),
              width: 1.5,
            ),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: Color(0xFF35BD79),
                child: Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask Me Anything',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your Voice Assistant',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.graphic_eq_rounded,
                color: Color(0xFF25B98B),
                size: 43,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BOTTOM NAVIGATION

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 10, 7, 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(27),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x160D3768),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: true,
          ),
          NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Reminders',
          ),
          NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Insights',
          ),
          NavItem(
            icon: Icons.grid_view_rounded,
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.blue
        : const Color(0xFF8492B0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 25),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// MESSAGE HELPER

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
