import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show compute;
import '../services/poke_api_service.dart';
import '../models/pokemon.dart';

class AsyncDemoScreen extends StatefulWidget {
  const AsyncDemoScreen({super.key});

  @override
  State<AsyncDemoScreen> createState() => _AsyncDemoScreenState();
}

class _AsyncDemoScreenState extends State<AsyncDemoScreen> {
  final PokeApiService _api = PokeApiService();
  
  // --- Estado para FutureBuilder ---
  Future<List<Pokemon>>? _futurePokemon;
  String _futureStatus = 'Esperando...';

  // --- Estado para compute ---
  String _computeResult = 'Esperando...';
  bool _isComputing = false;

  // --- Estado para Timer.periodic ---
  int _counter = 0;
  Timer? _timer;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    // Cargamos los Pokémon al iniciar (para FutureBuilder)
    _futurePokemon = _api.fetchAllPokemon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ─── MÉTODOS ────────────────────────────────────────────────

  // 1. async/await con try/catch (usando la API)
  Future<void> _loadPokemonWithTryCatch() async {
    setState(() => _futureStatus = 'Cargando...');
    try {
      final list = await _api.fetchAllPokemon();
      setState(() {
        _futureStatus = '✅ Cargados ${list.length} Pokémon';
        _futurePokemon = Future.value(list);
      });
    } catch (e) {
      setState(() => _futureStatus = '❌ Error: $e');
    }
  }

  // 2. compute: procesamiento pesado (calcular primos hasta N)
  static List<int> _calculatePrimes(int limit) {
    final List<int> primes = [];
    for (int i = 2; i <= limit; i++) {
      bool isPrime = true;
      for (int j = 2; j * j <= i; j++) {
        if (i % j == 0) {
          isPrime = false;
          break;
        }
      }
      if (isPrime) primes.add(i);
    }
    return primes;
  }

  Future<void> _runCompute() async {
    if (_isComputing) return;
    setState(() {
      _isComputing = true;
      _computeResult = 'Calculando primos hasta 100,000...';
    });
    
    // Usamos compute para ejecutar la función pesada en un isolate
    final result = await compute(_calculatePrimes, 100000);
    
    setState(() {
      _isComputing = false;
      _computeResult = '✅ Encontrados ${result.length} primos. Últimos 5: ${result.takeLast(5).join(', ')}';
    });
  }

  // 3. Timer.periodic
  void _toggleTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      setState(() => _isTimerRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _counter++);
      });
      setState(() => _isTimerRunning = true);
    }
  }

  // ─── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1C1C1E),
        border: null,
        middle: const Text('Programación Asíncrona', style: TextStyle(color: CupertinoColors.white)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. FutureBuilder ──────────────────────────
              _buildSectionTitle('FutureBuilder'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cargar datos de la API con FutureBuilder', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Pokemon>>(
                      future: _futurePokemon,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CupertinoActivityIndicator());
                        } else if (snapshot.hasError) {
                          return Text('❌ Error: ${snapshot.error}', style: const TextStyle(color: CupertinoColors.destructiveRed));
                        } else if (snapshot.hasData) {
                          return Text('✅ ${snapshot.data!.length} Pokémon cargados');
                        } else {
                          return const Text('Sin datos');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: _loadPokemonWithTryCatch,
                      child: const Text('Recargar con try/catch'),
                    ),
                    Text('Estado: $_futureStatus', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── 2. compute / Isolate ──────────────────────
              _buildSectionTitle('Compute / Isolate'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cálculo de números primos en isolate', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (_isComputing) const Center(child: CupertinoActivityIndicator()),
                    Text(_computeResult),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      color: CupertinoColors.activeGreen,
                      onPressed: _isComputing ? null : _runCompute,
                      child: const Text('Calcular primos'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── 3. Timer.periodic ─────────────────────────
              _buildSectionTitle('Timer.periodic'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cronómetro (actualiza cada 1s)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Contador: $_counter', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CupertinoButton(
                          color: _isTimerRunning ? CupertinoColors.destructiveRed : CupertinoColors.activeBlue,
                          onPressed: _toggleTimer,
                          child: Text(_isTimerRunning ? 'Detener' : 'Iniciar'),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          color: CupertinoColors.systemGrey,
                          onPressed: () {
                            setState(() => _counter = 0);
                          },
                          child: const Text('Reset'),
                        ),
                      ],
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

  // ─── WIDGETS AUXILIARES ─────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: CupertinoColors.systemGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// Extensión para obtener los últimos N elementos de una lista
extension ListExtension<T> on List<T> {
  List<T> takeLast(int n) {
    if (n >= length) return this;
    return sublist(length - n);
  }
}