import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/section_card.dart';
import '../widgets/profile/profile_tile.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'wallet_page.dart';
import 'add_expense_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeaderCard(),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Account',
                children: [
                  ProfileTile(icon: Icons.person_outline, title: 'Edit Profile', onTap: () {}),
                  _divider(),
                  ProfileTile(icon: Icons.lock_outline, title: 'Security', subtitle: 'Password, 2FA', onTap: () {}),
                  _divider(),
                  ProfileTile(icon: Icons.payment_outlined, title: 'Payment Methods', onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Preferences',
                children: [
                  ProfileTile(icon: Icons.notifications_none_rounded, title: 'Notifications', onTap: () {}),
                  _divider(),
                  const ProfileTile(icon: Icons.language_rounded, title: 'Language', trailing: Text('English')), 
                  _divider(),
                  const ProfileTile(icon: Icons.dark_mode_outlined, title: 'Theme', trailing: Text('System')), 
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'About',
                children: [
                  const ProfileTile(icon: Icons.info_outline, title: 'Version', trailing: Text('1.0.0')),
                  _divider(),
                  ProfileTile(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () {}),
                  _divider(),
                  ProfileTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}),
                ],
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpensePage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WalletPage()),
            );
          } else if (index == 3) {
            setState(() => _currentIndex = 3);
          }
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout_rounded, color: Colors.red),
      label: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.redAccent),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: Colors.red,
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: Colors.grey[200]);
}
