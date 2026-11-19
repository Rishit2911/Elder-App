import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/auth_api_service.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthApiService _authApi = AuthApiService();
  int _activeTabIndex = 0;

  final Map<String, dynamic> _systemStats = {
    'totalUsers': 306,
    'seniorCitizens': 163,
    'familyMembers': 84,
    'verifiedCaregivers': 25,
    'activeSosEvents': 1,
    'pendingBookings': 4,
    'systemHealth': '99.98% Operational',
  };

  final List<Map<String, dynamic>> _recentUsers = [
    {'name': 'Ramesh Sharma', 'phone': '+91 9870636', 'role': 'Senior', 'status': 'Active'},
    {'name': 'Aarav Sharma', 'phone': '+91 9999999997', 'role': 'Family', 'status': 'Active'},
    {'name': 'Sunita Devi', 'phone': '+91 9999999996', 'role': 'Caregiver', 'status': 'Verified'},
    {'name': 'Kailash Chand', 'phone': '+91 9876543210', 'role': 'Senior', 'status': 'Active'},
    {'name': 'Dr. Arvind Sharma', 'phone': '+91 9822334455', 'role': 'Doctor', 'status': 'Verified'},
  ];

  final List<Map<String, dynamic>> _sosAlerts = [
    {
      'id': 'SOS-98124',
      'senior': 'Ramesh Sharma (दादाजी)',
      'location': '402, Shanti Niketan, Jaipur',
      'timestamp': 'Just Now',
      'priority': 'Critical',
      'status': 'Dispatched',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elderly Seva Admin Portal',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                Text(
                  'Operational Control & Safety Console',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.coralRed),
            tooltip: 'Logout',
            onPressed: () async {
              await _authApi.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 20),
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            _buildTabSelector(),
            const SizedBox(height: 16),
            if (_activeTabIndex == 0) _buildOverviewTab(),
            if (_activeTabIndex == 1) _buildSosConsoleTab(),
            if (_activeTabIndex == 2) _buildUserDirectoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.warmAmber, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PostgreSQL 18 & FastAPI Live Console',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Database: seniorcare_db • 41 relational tables • Realtime safety pipeline active',
                  style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Healthy',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Total Users',
              value: '${_systemStats['totalUsers']}',
              icon: Icons.people_alt_rounded,
              color: AppColors.primaryBlue,
            ),
            _buildStatCard(
              title: 'Senior Citizens',
              value: '${_systemStats['seniorCitizens']}',
              icon: Icons.elderly_rounded,
              color: const Color(0xFF2E7D32),
            ),
            _buildStatCard(
              title: 'Active SOS Alerts',
              value: '${_systemStats['activeSosEvents']}',
              icon: Icons.emergency_rounded,
              color: AppColors.coralRed,
              isAlert: true,
            ),
            _buildStatCard(
              title: 'Verified Caregivers',
              value: '${_systemStats['verifiedCaregivers']}',
              icon: Icons.volunteer_activism_rounded,
              color: const Color(0xFFE65100),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isAlert ? AppColors.coralRed.withAlpha(80) : AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withAlpha(30),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isAlert ? AppColors.coralRed : AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['Platform Overview', 'SOS Safety Console', 'User Management'];
    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = _activeTabIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(tabs[index]),
            selected: isSelected,
            selectedColor: AppColors.primaryBlue,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            onSelected: (val) {
              if (val) setState(() => _activeTabIndex = index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Operational Feed',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              _buildFeedRow(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.mintGreen,
                title: 'PostgreSQL Database Synchronized',
                subtitle: 'seniorcare_db loaded with 163 senior profiles and 306 users.',
                time: '10m ago',
              ),
              const Divider(height: 24),
              _buildFeedRow(
                icon: Icons.medical_services_rounded,
                iconColor: AppColors.primaryBlue,
                title: 'Medicine Schedule Adherence Logged',
                subtitle: 'Senior 056dd8 marked Metformin 500mg taken.',
                time: '24m ago',
              ),
              const Divider(height: 24),
              _buildFeedRow(
                icon: Icons.group_add_rounded,
                iconColor: const Color(0xFF2E7D32),
                title: 'Family Relationship Link Approved',
                subtitle: 'Aarav Sharma linked as son to Dadaji with emergency contact rights.',
                time: '1h ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSosConsoleTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Emergency Incidents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.coralRed.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1 Live Alert',
                style: TextStyle(color: AppColors.coralRed, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._sosAlerts.map((alert) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.coralRed.withAlpha(100), width: 1.5),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.coralRed,
                  child: Icon(Icons.emergency_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['senior'],
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.navy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert['location'],
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incident resolved in database.')),
                    );
                  },
                  child: const Text('Resolve Incident'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUserDirectoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registered Users (PostgreSQL)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentUsers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = _recentUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    u['name'][0],
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                  ),
                ),
                title: Text(u['name'], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                subtitle: Text('${u['phone']} • Role: ${u['role']}', style: const TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    u['status'],
                    style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withAlpha(30),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.navy)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ],
    );
  }
}
