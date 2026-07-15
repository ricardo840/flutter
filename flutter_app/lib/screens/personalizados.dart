import 'package:flutter/cupertino.dart';
import '../widgets/file_practice_widget.dart';
import '../widgets/async_examples_widget.dart';
import '../services/notification_service.dart';

class PersonalizadosScreen extends StatefulWidget {
  const PersonalizadosScreen({super.key});

  @override
  State<PersonalizadosScreen> createState() => _PersonalizadosScreenState();
}

class _PersonalizadosScreenState extends State<PersonalizadosScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
  }

  Future<void> _initNotifications() async {
    final notifications = NotificationService();
    await notifications.init();
    // ✅ No llamamos a ningún método de permisos
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1C1C1E),
        border: null,
        middle: const Text(
          'Personalizados',
          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CupertinoSegmentedControl<int>(
                selectedColor: CupertinoColors.activeBlue,
                unselectedColor: CupertinoColors.darkBackgroundGray,
                children: const {
                  0: Text('Archivos'),
                  1: Text('Async & Notificaciones'),
                },
                onValueChanged: (value) {
                  setState(() => _selectedIndex = value);
                },
                groupValue: _selectedIndex,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  FilePracticeWidget(),
                  AsyncExamplesWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}