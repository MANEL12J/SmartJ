import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/session_service.dart';
import 'add_judge_screen.dart';
import 'add_designer_screen.dart';
import 'add_rider_screen.dart';
import 'add_horse_screen.dart';
import 'show_list_screen.dart';
import 'competition_list_screen.dart';
import 'event_list_screen.dart';
import 'participation_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();

  int _selectedIndex = 0;
  int _totalUsers = 0;
  int _totalShows = 0;
  int _totalCompetitions = 0;
  int _totalParticipations = 0;
  bool _isLoadingStats = true;

  // Sub-pages for personnel submenu
  int? _personnelSubIndex;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final users = await _firebaseService.getAllUsers();
      final shows = await _firebaseService.getShows();
      final competitions = await _firebaseService.getCompetitions();
      final participations = await _firebaseService.getAllParticipations();

      setState(() {
        _totalUsers = users.length;
        _totalShows = shows.length;
        _totalCompetitions = competitions.length;
        _totalParticipations = participations.length;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _personnelSubIndex = null;
    });
    if (index == 0) _loadStatistics();
  }

  void _onPersonnelSubSelected(int subIndex) {
    setState(() {
      _selectedIndex = 1;
      _personnelSubIndex = subIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.blue[800],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue[900],
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Jump Judge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Administration',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[200],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.dashboard,
                  label: 'Tableau de bord',
                ),
                _buildPersonnelMenu(),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.event,
                  label: 'Shows',
                ),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.emoji_events,
                  label: 'Compétitions',
                ),
                _buildMenuItem(
                  index: 4,
                  icon: Icons.sports_gymnastics,
                  label: 'Épreuves',
                ),
                _buildMenuItem(
                  index: 5,
                  icon: Icons.list_alt,
                  label: 'Participations',
                ),
              ],
            ),
          ),

          // Logout
          Divider(color: Colors.blue[600], height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index && _personnelSubIndex == null;
    return InkWell(
      onTap: () => _onMenuSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: Colors.white, width: 4))
              : Border(left: BorderSide(color: Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: isSelected ? Colors.white : Colors.blue[200]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.blue[200],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelMenu() {
    final isExpanded = _selectedIndex == 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = 1;
              _personnelSubIndex = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _selectedIndex == 1
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              border: _selectedIndex == 1
                  ? Border(left: BorderSide(color: Colors.white, width: 4))
                  : Border(
                      left: BorderSide(color: Colors.transparent, width: 4)),
            ),
            child: Row(
              children: [
                Icon(Icons.people,
                    size: 20,
                    color:
                        _selectedIndex == 1 ? Colors.white : Colors.blue[200]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personnel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedIndex == 1
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color:
                          _selectedIndex == 1 ? Colors.white : Colors.blue[200],
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.blue[200],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          _buildSubMenuItem(
            subIndex: 0,
            icon: Icons.gavel,
            label: 'Ajouter Juge',
          ),
          _buildSubMenuItem(
            subIndex: 1,
            icon: Icons.design_services,
            label: 'Ajouter Designer',
          ),
          _buildSubMenuItem(
            subIndex: 2,
            icon: Icons.sports_gymnastics,
            label: 'Ajouter Cavalier',
          ),
          _buildSubMenuItem(
            subIndex: 3,
            icon: Icons.pets,
            label: 'Ajouter Cheval',
          ),
        ],
      ],
    );
  }

  Widget _buildSubMenuItem({
    required int subIndex,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _personnelSubIndex == subIndex;
    return InkWell(
      onTap: () => _onPersonnelSubSelected(subIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            const SizedBox(width: 32),
            Icon(icon,
                size: 16, color: isSelected ? Colors.white : Colors.blue[300]),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.blue[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _logout,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.logout, size: 20, color: Colors.red[300]),
            const SizedBox(width: 12),
            Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    // Personnel sub-pages
    if (_selectedIndex == 1 && _personnelSubIndex != null) {
      switch (_personnelSubIndex) {
        case 0:
          return const AddJudgeScreen();
        case 1:
          return const AddDesignerScreen();
        case 2:
          return const AddRiderScreen();
        case 3:
          return const AddHorseScreen();
      }
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildPersonnelOverview();
      case 2:
        return const ShowListScreen();
      case 3:
        return const CompetitionListScreen();
      case 4:
        return const EventListScreen();
      case 5:
        return const ParticipationManagementScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Row(
              children: [
                Icon(Icons.dashboard, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenue Administrateur — Gérez les concours équestres',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Stats cards
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('Utilisateurs', _totalUsers,
                        Icons.person, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(
                        'Shows', _totalShows, Icons.event, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Compétitions', _totalCompetitions,
                        Icons.emoji_events, Colors.purple)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Participations',
                        _totalParticipations, Icons.list_alt, Colors.teal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const Spacer(),
                Icon(Icons.trending_up, size: 20, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _isLoadingStats ? '...' : '$value',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelOverview() {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Gestion du Personnel',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez une action dans le menu à gauche',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildPersonnelActionCard(
                    'Ajouter un Juge',
                    Icons.gavel,
                    Colors.green,
                    () => _onPersonnelSubSelected(0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPersonnelActionCard(
                    'Ajouter un Designer',
                    Icons.design_services,
                    Colors.orange,
                    () => _onPersonnelSubSelected(1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPersonnelActionCard(
                    'Ajouter un Cavalier',
                    Icons.sports_gymnastics,
                    Colors.blue,
                    () => _onPersonnelSubSelected(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPersonnelActionCard(
                    'Ajouter un Cheval',
                    Icons.pets,
                    Colors.brown,
                    () => _onPersonnelSubSelected(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await SessionService.clearSession();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Erreur lors du logout: $e');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}
