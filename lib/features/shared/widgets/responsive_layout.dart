import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget header;
  final List<Widget> statCards;
  final Widget mainContent;
  final Widget? quickActions;

  const ResponsiveLayout({
    super.key,
    required this.sidebar,
    required this.header,
    required this.statCards,
    required this.mainContent,
    this.quickActions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1200;
        final isMedium = constraints.maxWidth >= 768;

        if (isWide) {
          return Row(
            children: [
              sidebar,
              Expanded(
                child: Column(
                  children: [
                    header,
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: statCards.map((card) => Expanded(child: card)).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(child: mainContent),
                          const SizedBox(width: 20),
                          if (quickActions != null) SizedBox(width: 300, child: quickActions),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        } else if (isMedium) {
          return Row(
            children: [
              sidebar,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      header,
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: statCards.map((card) => Expanded(child: card)).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: mainContent,
                      ),
                      if (quickActions != null) const SizedBox(height: 20),
                      if (quickActions != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: quickActions,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              sidebar,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      header,
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: statCards[0],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: statCards[1],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: statCards[2],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: statCards[3],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: mainContent,
                      ),
                      if (quickActions != null) const SizedBox(height: 16),
                      if (quickActions != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: quickActions,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
