import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/barcode_provider.dart';
import 'multi_scan_screen.dart';
import 'scan_list_screen.dart';
import 'server_data_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '바코드 스캐너',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0), // 하단 패딩 줄임
          child: Column(
            children: [
              const SizedBox(height: 10), // 상단 간격 줄임
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.2, // 카드 비율을 더 넓게 조정 (안드로이드 대응)
                  padding: const EdgeInsets.only(bottom: 20), // 하단 여백 추가
                  children: [
                    _buildMenuCard(
                      context,
                      icon: Icons.qr_code_scanner,
                      title: '바코드 스캔하기',
                      subtitle: '제품 바코드를 스캔합니다',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MultiScanScreen(),
                          ),
                        );
                      },
                    ),
                    Consumer<BarcodeProvider>(
                      builder: (context, provider, child) {
                        return _buildMenuCard(
                          context,
                          icon: Icons.list_alt,
                          title: '스캔 목록',
                          subtitle: '스캔한 제품을 확인합니다',
                          color: Colors.orange,
                          badge: provider.itemCount > 0 ? provider.itemCount : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScanListScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.cloud_download,
                      title: '저장된 데이터',
                      subtitle: '서버에 저장된 데이터를 확인합니다',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ServerDataScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.settings,
                      title: '설정',
                      subtitle: '앱 설정을 변경합니다',
                      color: Colors.grey,
                      onTap: () {
                        // TODO: 설정 화면으로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('준비 중입니다')),
                        );
                      },
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

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    Widget cardContent = Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16), // 패딩 줄임
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
            children: [
              Container(
                padding: const EdgeInsets.all(10), // 패딩 줄임
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30, // 아이콘 크기 줄임
                  color: color,
                ),
              ),
              const SizedBox(height: 8), // 간격 줄임
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13, // 폰트 크기 줄임
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3), // 간격 줄임
              Expanded( // Flexible에서 Expanded로 변경
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10, // 폰트 크기 줄임
                    color: Colors.grey[600],
                    height: 1.2, // 줄 높이 조정
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (badge != null) {
      return badges.Badge(
        badgeContent: Text(
          badge.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Colors.red,
          padding: const EdgeInsets.all(6),
        ),
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        child: cardContent,
      );
    }

    return cardContent;
  }
}