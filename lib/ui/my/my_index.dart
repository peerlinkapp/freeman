import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'my_profile.dart';

/**
 * 本页有GridView结合IconButton的示例
 */

class MyIndexPage extends ConsumerStatefulWidget {

  const MyIndexPage({super.key});

  @override
  _MyIndexPageState createState() => _MyIndexPageState();
}

class _MyIndexPageState extends ConsumerState<MyIndexPage> {

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttonData = [
      {'icon': Icons.home, 'label': '首页'},
      {'icon': Icons.settings, 'label': '设置'},
      {'icon': Icons.person, 'label': '我的'},
      {'icon': Icons.message, 'label': '消息'},
      {'icon': Icons.camera_alt, 'label': '相机'},
      {'icon': Icons.map, 'label': '地图'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔹 个人资料区块
          InkWell(
            onTap: () {
              Get.to<void>(new MyProfilePage());
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('用户名：张三', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('一位热爱 Flutter 的开发者', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 12), // 空白分隔条
          const Divider(thickness: 1), // 或者用 Divider
          const SizedBox(height: 12),


          const Text(
            '功能',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 使用 Expanded 让 GridView 占据剩余空间
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: buttonData.map((item) {
                return TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    //backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('点击了 ${item['label']}')),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 36),
                      const SizedBox(height: 8),
                      Text(item['label'], style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


}
