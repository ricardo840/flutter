import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../services/poke_api_service.dart';
import '../services/notification_service.dart';

class AsyncExamplesWidget extends StatefulWidget {
  const AsyncExamplesWidget({super.key});

  @override
  State<AsyncExamplesWidget> createState() => _AsyncExamplesWidgetState();
}

class _AsyncExamplesWidgetState extends State<AsyncExamplesWidget> {
  final PokeApiService _api = PokeApiService();
  final NotificationService _notifications = NotificationService();
  Timer? _timer;
  int _counter = 0;
  String _computeResult = '';
  bool _isComputing = false;

  Future<List<String>> _fetchPokemonNames() async {
    await Future.delayed(const Duration(seconds: 2));
    final pokemons = await _api.fetchAllPokemon();
    return pokemons.take(10).map((p) => p.name).toList();
  }

  static int _computeAverageStats(List<int> stats) {
    return stats.reduce((a, b) => a + b) ~/ stats.length;
  }

  void _runCompute() async {
    setState(() => _isComputing = true);
    try {
      final pokemons = await _api.fetchAllPokemon();
      if (pokemons.isEmpty) return;
      final stats = pokemons.take(50).map((p) => p.hp).toList();
      final result = await compute(_computeAverageStats, stats);
      setState(() {
        _computeResult = 'Promedio de HP (50 Pokémon): $result';
        _isComputing = false;
      });
      await _notifications.showNotification(
        id: 2,
        title: 'Cálculo completado',
        body: 'Promedio de HP: $result',
      );
    } catch (e) {
      setState(() => _isComputing = false);
      print('Error en compute: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() => _counter++);
      if (_counter % 3 == 0) {
        _notifications.showNotification(
          id: 3,
          title: 'Timer periódico',
          body: 'Han pasado ${_counter * 10} segundos',
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── FutureBuilder ────────────────────────────────
          const Text('1. FutureBuilder (carga de Pokémon)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          FutureBuilder<List<String>>(
            future: _fetchPokemonNames(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: CupertinoColors.destructiveRed));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay datos');
              }
              // Usamos Wrap con Container en lugar de Chip
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: snapshot.data!.map((name) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(name, style: const TextStyle(fontSize: 12)),
                  )
                ).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // ─── Compute/Isolate ──────────────────────────────
          const Text('2. Compute/Isolate (cálculo pesado)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          CupertinoButton(
            color: CupertinoColors.activeBlue,
            onPressed: _isComputing ? null : _runCompute,
            child: Text(_isComputing ? 'Calculando...' : 'Calcular promedio'),
          ),
          if (_computeResult.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_computeResult),
          ],
          const SizedBox(height: 24),

          // ─── Timer.periodic ───────────────────────────────
          const Text('3. Timer.periodic (cada 10s)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Segundos transcurridos: ${_counter * 10}s',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),

          // ─── Botón notificación manual ────────────────────
          const Text('4. Notificaciones locales',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          CupertinoButton(
            color: CupertinoColors.activeGreen,
            onPressed: () async {
              await _notifications.showNotification(
                id: 1,
                title: '¡Hola!',
                body: 'Esta es una notificación manual',
              );
            },
            child: const Text('Enviar notificación de prueba'),
          ),
          const SizedBox(height: 16),
          Text(
            '💡 Las notificaciones también se disparan:\n'
            '• Al completar el cálculo con compute\n'
            '• Cada 30 segundos (Timer.periodic)\n'
            '• Al crear/eliminar archivos (integrado)',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}