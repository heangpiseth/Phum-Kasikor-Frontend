import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/controller/farmer/profile_controller.dart';
import 'package:phum_kasikors/view/farmer/Farm/farmer_farm_profile.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FarmerProfileController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF8),
      body: SafeArea(
        child: Obx(() {
          final profile = controller.profile.value;
          return Column(
            children: [
              const _ProfileAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshProfile,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                    children: [
                      _Header(name: profile?.name ?? 'Sokha Nam'),
                      const SizedBox(height: 12),
                      _Stats(
                        products: profile?.products ?? 24,
                        orders: profile?.orders ?? 156,
                        rating: profile?.rating ?? 4.8,
                      ),
                      const SizedBox(height: 10),
                      _FarmHelpCard(onTap: () => _message('Farm Assistant')),
                      const SizedBox(height: 10),
                      _SettingTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile Info',
                        subtitle: 'Name, phone, identity verification',
                        onTap: controller.editProfile,
                      ),
                      _SettingTile(
                        icon: Icons.agriculture_outlined,
                        title: 'My Farm Details',
                        subtitle: 'Farm size, irrigation, crop varieties',
                        onTap: () => Get.to(() => const FarmerFarmProfile()),
                      ),
                      _SettingTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Payment & ABA Settings',
                        subtitle: '•••• 4892 (Sokha V.)',
                        trailing: const _ConnectedBadge(),
                        onTap: () => _message('Payment & ABA Settings'),
                      ),
                      _SettingTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification Preferences',
                        subtitle: 'Order alerts, price shifts, SMS',
                        onTap: () => _message('Notification Preferences'),
                      ),
                      _SettingTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'App interface language',
                        trailingText: 'ភាសាខ្មែរ / EN',
                        onTap: () => _message('Language'),
                      ),
                      _SettingTile(
                        icon: Icons.headset_mic_outlined,
                        title: 'Help & Customer Support',
                        subtitle: 'Agronomist hotline & live chat',
                        onTap: () => _message('Customer Support'),
                      ),
                      _SettingTile(
                        icon: Icons.description_outlined,
                        title: 'Terms & Privacy Policy',
                        subtitle: 'Produce standards & marketplace rules',
                        onTap: () => _message('Terms & Privacy Policy'),
                      ),
                      const SizedBox(height: 2),
                      OutlinedButton.icon(
                        onPressed: controller.logout,
                        icon: const Icon(Icons.logout_rounded, size: 17),
                        label: const Text('Log Out Account'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: Color(0xFFFFC7C7)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Phum Kasikor Farmer • Version 1.2.4\nEmpowering Cambodian Agriculture Communities',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 8, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _message(String title) => Get.snackbar(title, 'This feature will be available soon.');
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();
  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 4)]),
        child: const Row(children: [
          Icon(Icons.menu_rounded, size: 20),
          SizedBox(width: 13),
          Text('Phum Kasikor', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
          Spacer(),
          Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 18),
        ]),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          ClipOval(
            child: Image.asset(
              'assets/group_people.jpg',
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const CircleAvatar(
                radius: 29,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
          const Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: AppColors.success,
                child: Icon(Icons.check, size: 10, color: Colors.white),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 5),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(width: 3),
          const Icon(Icons.verified, size: 13, color: AppColors.success),
        ]),
        const Text('Certified Organic Farmer • Battambang Coop', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
      ]);
}

class _Stats extends StatelessWidget {
  const _Stats({required this.products, required this.orders, required this.rating});
  final int products;
  final int orders;
  final double rating;
  @override
  Widget build(BuildContext context) => Container(
        height: 54,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          _Stat(value: '$products', label: 'PRODUCTS'),
          const VerticalDivider(indent: 10, endIndent: 10, color: AppColors.border),
          _Stat(value: '$orders', label: 'ORDERS'),
          const VerticalDivider(indent: 10, endIndent: 10, color: AppColors.border),
          _Stat(value: '${rating.toStringAsFixed(1)} ★', label: 'RATING'),
        ]),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 7, color: AppColors.textSecondary)),
      ]));
}

class _FarmHelpCard extends StatelessWidget {
  const _FarmHelpCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          const CircleAvatar(radius: 11, backgroundColor: AppColors.primaryLight, child: Icon(Icons.auto_awesome, size: 13, color: AppColors.success)),
          const SizedBox(width: 9),
          const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Need help with your farm?', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
            Text('Ask Phum Kasikor AI for farming...', style: TextStyle(fontSize: 7, color: AppColors.textSecondary)),
          ])),
          SizedBox(height: 23, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 10)), child: const Text('Ask AI', style: TextStyle(fontSize: 8)))),
        ]),
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.trailing, this.trailingText});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? trailingText;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(9),
            child: Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)),
              child: Row(children: [
                CircleAvatar(radius: 10, backgroundColor: AppColors.primaryLight, child: Icon(icon, size: 13, color: AppColors.success)),
                const SizedBox(width: 9),
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, color: AppColors.textSecondary)),
                ])),
                // ignore: use_null_aware_elements
                if (trailing != null) trailing!,
                if (trailingText != null) Text(trailingText!, style: const TextStyle(fontSize: 7, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 17, color: Color(0xFF91AAB5)),
              ]),
            ),
          ),
        ),
      );
}

class _ConnectedBadge extends StatelessWidget {
  const _ConnectedBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(3)),
        child: const Text('ABA\nConnected', textAlign: TextAlign.center, style: TextStyle(fontSize: 6, color: AppColors.primary, fontWeight: FontWeight.w700)),
      );
}