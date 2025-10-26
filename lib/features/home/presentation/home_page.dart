import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/home/provider/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(displayNameProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              nameAsync.when(
                data: (name) => _Header(name: name),
                loading: () => const _Header(name: '...'),
                error: (_, __) => const _Header(name: 'Guest'),
              ),
              const SizedBox(height: 20),

              // 2x2 Grid
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _FeaturesGrid(
                        items: [
                          _FeatureItem(
                            asset: 'assets/meal.png',
                            title: 'Meal Plan',
                            onTap: () => context.push('/meal-plan'),
                          ),
                          _FeatureItem(
                            asset: 'assets/doctor.png',
                            title: 'Contact Doctor',
                            onTap: () => _todo(context, 'Contact Doctor'),
                          ),
                          _FeatureItem(
                            asset: 'assets/medicines.png',
                            title: 'My Medicine',
                            onTap: () => context.push('/my-medicine'),
                          ),
                          _FeatureItem(
                            asset: 'assets/progress.png',
                            title: 'Progress',
                            onTap: () => context.push('/progress'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Add Meal button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => context.push('/add-meal'),
                          child: const Text(
                            'Add Meal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  void _todo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — Coming soon')),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $name',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            )),
        const SizedBox(height: 6),
        const Text(
          'How are you feeling today?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSoft,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.items});
  final List<_FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final maxW = c.maxWidth;
        final isNarrow = maxW < 340;
        final spacing = isNarrow ? 12.0 : 16.0;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            // اطول سنة عشان تقرّب للصورة الأصلية
            childAspectRatio: 0.78,
          ),
          itemBuilder: (_, i) => _FeatureCard(item: items[i]),
        );
      },
    );
  }
}

class _FeatureItem {
  final String asset;
  final String title;
  final VoidCallback onTap;
  _FeatureItem({required this.asset, required this.title, required this.onTap});
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});
  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EEF9)),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  item.asset,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends ConsumerWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = ref.watch(navIndexProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: Icons.home_rounded,
                index: 0,
                current: i,
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 0;
                  context.go('/home'); // يرجّعك للهوم
                },
              ),
              _NavIcon(
                icon: Icons.notifications_none,
                index: 1,
                current: i,
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 1;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications — Coming soon')),
                  );
                },
              ),
              _NavIcon(
                icon: Icons.search,
                index: 2,
                current: i,
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 2;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search — Coming soon')),
                  );
                },
              ),
              _NavIcon(
                icon: Icons.settings,
                index: 3, // ← كان 4
                current: i,
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 3;
                  context.push('/settings'); // ← افتح شاشة الإعدادات
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final int current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = current == index;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? AppColors.primary : const Color(0xFF98A2B3),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 18,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
