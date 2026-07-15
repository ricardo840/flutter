import 'package:flutter/cupertino.dart';
import '../data/services/auth_service.dart';
import '../widgets/section_header.dart';
import '../main.dart' show LoginScreen;
import '../screens/pos_screen.dart'; // Ajusta la ruta según tu estructura
import '../screens/personalizados.dart';
import '../screens/poke_list_screen.dart';
import '../screens/async_demo_screen.dart';

// ─────────────────────────────────────────────────────────────
// Pantalla principal con ejemplos de controles de Flutter
// ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Estado de cada control ────────────────────────────────

  // Slider
  double _sliderValor = 0.5;

  // Checkbox
  bool _checkboxValor = false;

  // DropdownButton (en Cupertino se usa CupertinoPicker o simulado con acción)
  final List<String> _opcionesDropdown = ['Opción A', 'Opción B', 'Opción C'];
  String _opcionSeleccionada = 'Opción A';

  // Progress bars (valor fijo para mostrar visualmente)
  double _progreso = 0.65;

  // Switch
  bool _switchValor = true;

  // RadioButton — índice seleccionado
  int _radioSeleccionado = 0;
  final List<String> _opcionesRadio = ['Rojo', 'Verde', 'Azul'];

  // ─────────────────────────────────────────────────────────
  // Muestra el picker de dropdown estilo Cupertino
  // ─────────────────────────────────────────────────────────
  void _mostrarPicker() {
    int indexTemp = _opcionesDropdown.indexOf(_opcionSeleccionada);

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color(0xFF1C1C1E),
        child: Column(
          children: [
            // Barra superior con botón Listo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF3A3A3C), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selecciona una opción',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Listo',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Picker giratorio
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: indexTemp,
                ),
                onSelectedItemChanged: (i) {
                  setState(() => _opcionSeleccionada = _opcionesDropdown[i]);
                },
                children: _opcionesDropdown
                    .map((o) => Center(
                          child: Text(
                            o,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Navega de regreso al login eliminando esta pantalla
  // ─────────────────────────────────────────────────────────
  void _cerrarSesion() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await AuthService.instance.signOutCurrent();
              if (!mounted) {
                return;
              }
              // Elimina toda la pila y regresa a la raíz (LoginScreen)
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  

  // ── Navegación a POS ──────────────────────────────────────
  void _irAPos() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => const POSHomePage(), // Asegúrate que POSHomePage esté importado
      ),
    );
  }

  // ── Navegación a Personalizados ──────────────────────────
  void _irAPersonalizados() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => const PersonalizadosScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,

      // ── Navigation bar estilo iOS ──────────────────────────
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1C1C1E),
        border: null,
        middle: const Text(
          'Componentes Flutter',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: GestureDetector(
          onTap: _cerrarSesion,
          child: const Text(
            'Salir',
            style: TextStyle(
              color: CupertinoColors.destructiveRed,
              fontSize: 14,
            ),
          ),
        ),
      ),

      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ════════════════════════════════════════════════
            // SECCIÓN 1: Controles de valor
            // ════════════════════════════════════════════════
            SectionHeader(
              titulo: 'Controles de valor',
              icono: CupertinoIcons.slider_horizontal_3,
            ),

            // ── Slider ──────────────────────────────────────
            _Tarjeta(
              titulo: 'Slider',
              descripcion: 'Selecciona un valor deslizando',
              child: Column(
                children: [
                  CupertinoSlider(
                    value: _sliderValor,
                    onChanged: (v) => setState(() => _sliderValor = v),
                    activeColor: CupertinoColors.activeBlue,
                  ),
                  Text(
                    'Valor: ${(_sliderValor * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Switch ──────────────────────────────────────
            _Tarjeta(
              titulo: 'Switch (ToggleSwitch)',
              descripcion: 'Activa o desactiva una opción',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _switchValor ? 'Activado' : 'Desactivado',
                    style: TextStyle(
                      color: _switchValor
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _switchValor,
                    onChanged: (v) => setState(() => _switchValor = v),
                  ),
                ],
              ),
            ),

            // ════════════════════════════════════════════════
            // SECCIÓN 2: Selectores
            // ════════════════════════════════════════════════
            SectionHeader(
              titulo: 'Selectores',
              icono: CupertinoIcons.checkmark_circle,
            ),

            // ── Checkbox ─────────────────────────────────────
            _Tarjeta(
              titulo: 'Checkbox',
              descripcion: 'Marca o desmarca una opción',
              child: GestureDetector(
                onTap: () =>
                    setState(() => _checkboxValor = !_checkboxValor),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _checkboxValor
                            ? CupertinoColors.activeBlue
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _checkboxValor
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                      child: _checkboxValor
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              size: 16,
                              color: CupertinoColors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _checkboxValor ? 'Seleccionado' : 'Sin seleccionar',
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── RadioButton ──────────────────────────────────
            _Tarjeta(
              titulo: 'RadioButton',
              descripcion: 'Elige una sola opción del grupo',
              child: Column(
                children: List.generate(
                  _opcionesRadio.length,
                  (i) => GestureDetector(
                    onTap: () => setState(() => _radioSeleccionado = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _radioSeleccionado == i
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.systemGrey,
                                width: 2,
                              ),
                            ),
                            child: _radioSeleccionado == i
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CupertinoColors.activeBlue,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _opcionesRadio[i],
                            style: const TextStyle(
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── DropdownButton (CupertinoPicker) ─────────────
            _Tarjeta(
              titulo: 'DropdownButton (ComboBox)',
              descripcion: 'Despliega un selector tipo picker',
              child: GestureDetector(
                onTap: _mostrarPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _opcionSeleccionada,
                        style: const TextStyle(color: CupertinoColors.white),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_up_chevron_down,
                        color: CupertinoColors.systemGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ════════════════════════════════════════════════
            // SECCIÓN 3: Indicadores de progreso
            // ════════════════════════════════════════════════
            SectionHeader(
              titulo: 'Indicadores de progreso',
              icono: CupertinoIcons.chart_bar,
            ),

            // ── LinearProgressIndicator ──────────────────────
            _Tarjeta(
              titulo: 'LinearProgressIndicator (ProgressBar)',
              descripcion: 'Progreso determinado e indeterminado',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Determinado
                  const Text(
                    'Determinado (65%)',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progreso,
                      backgroundColor: const Color(0xFF2C2C2E),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        CupertinoColors.activeBlue,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Indeterminado
                  const Text(
                    'Indeterminado (animado)',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: Color(0xFF2C2C2E),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CupertinoColors.activeOrange,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── CircularProgressIndicator ────────────────────
            _Tarjeta(
              titulo: 'CircularProgressIndicator (ProgressRing)',
              descripcion: 'Indicador circular y spinner de actividad',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: _progreso,
                          backgroundColor: const Color(0xFF2C2C2E),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            CupertinoColors.activeBlue,
                          ),
                          strokeWidth: 5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Determinado',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      // Spinner nativo de iOS
                      const CupertinoActivityIndicator(radius: 18),
                      const SizedBox(height: 8),
                      const Text(
                        'Spinner iOS',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          backgroundColor: Color(0xFF2C2C2E),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CupertinoColors.activeGreen,
                          ),
                          strokeWidth: 5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Indeterminado',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ════════════════════════════════════════════════
            // SECCIÓN 4: Botones
            // ════════════════════════════════════════════════
            SectionHeader(
              titulo: 'Botones',
              icono: CupertinoIcons.cursor_rays,
            ),

            // ── IconButton ───────────────────────────────────
            _Tarjeta(
              titulo: 'IconButton',
              descripcion: 'Botón que solo muestra un ícono',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _icono(CupertinoIcons.heart, CupertinoColors.destructiveRed),
                  _icono(CupertinoIcons.star_fill, CupertinoColors.activeOrange),
                  _icono(CupertinoIcons.share, CupertinoColors.activeBlue),
                  _icono(CupertinoIcons.bookmark, CupertinoColors.systemPurple),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── FilledButton ─────────────────────────────────
            _Tarjeta(
              titulo: 'FilledButton',
              descripcion: 'Botón con fondo de color sólido',
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () => _mostrarSnack('FilledButton presionado'),
                  child: const Text(
                    'FilledButton',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── TextButton ───────────────────────────────────
            _Tarjeta(
              titulo: 'TextButton',
              descripcion: 'Botón solo con texto, sin fondo',
              child: Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _mostrarSnack('TextButton presionado'),
                  child: const Text(
                    'TextButton',
                    style: TextStyle(color: CupertinoColors.activeBlue),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── ElevatedButton ───────────────────────────────
            _Tarjeta(
              titulo: 'ElevatedButton',
              descripcion: 'Botón con sombra y relieve',
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.activeBlue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    color: const Color(0xFF0A84FF),
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    onPressed: () => _mostrarSnack('ElevatedButton presionado'),
                    child: const Text(
                      'ElevatedButton',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── OutlinedButton ───────────────────────────────
            _Tarjeta(
              titulo: 'OutlinedButton',
              descripcion: 'Botón con solo borde visible',
              child: Center(
                child: GestureDetector(
                  onTap: () => _mostrarSnack('OutlinedButton presionado'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CupertinoColors.activeBlue,
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'OutlinedButton',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Botón con ícono y texto ───────────────────────
            _Tarjeta(
              titulo: 'Botón con ícono y texto',
              descripcion: 'Combina ícono y etiqueta en un solo botón',
              child: Center(
                child: CupertinoButton(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  onPressed: () => _mostrarSnack('Botón con ícono presionado'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.add_circled, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Agregar item',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ════════════════════════════════════════════════
            // SECCIÓN 5: Texto y enlaces
            // ════════════════════════════════════════════════
            SectionHeader(
              titulo: 'Texto y enlaces',
              icono: CupertinoIcons.link,
            ),

            _Tarjeta(
              titulo: 'Hyperlink / Enlace',
              descripcion: 'Texto interactivo que simula un enlace',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _mostrarSnack('Enlace presionado'),
                    child: const Text(
                      'Visitar documentación de Flutter →',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        decoration: TextDecoration.underline,
                        decorationColor: CupertinoColors.activeBlue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _mostrarSnack('Enlace secundario presionado'),
                    child: const Text(
                      'Más información aquí',
                      style: TextStyle(
                        color: CupertinoColors.systemPurple,
                        decoration: TextDecoration.underline,
                        decorationColor: CupertinoColors.systemPurple,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ════════════════════════════════════════════════
            // NUEVA SECCIÓN: Navegación a otras pantallas
            // ════════════════════════════════════════════════
            SectionHeader(
              titulo: 'Navegación',
              icono: CupertinoIcons.arrow_right_circle,
            ),

            _Tarjeta(
              titulo: 'Programación Asíncrona',
              descripcion: 'Ejemplos de FutureBuilder, compute, Timer.periodic',
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.systemOrange,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const AsyncDemoScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.time, size: 18),
                      SizedBox(width: 8),
                      Text('Ver Asíncrono', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Botón POS ────────────────────────────────────
            _Tarjeta(
              titulo: 'Punto de Venta (POS)',
              descripcion: 'Ir al módulo de ventas',
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: _irAPos,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.cart, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Abrir POS',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

          const SizedBox(height: 10),

// ── Botón Pokédex ──────────────────────────
_Tarjeta(
  titulo: 'Pokédex',
  descripcion: 'Ver lista de Pokémon desde API',
  child: SizedBox(
    width: double.infinity,
    child: CupertinoButton(
      color: CupertinoColors.activeGreen,
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(vertical: 12),
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => PokeListScreen(),
          ),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.person_alt_circle, size: 18),
          SizedBox(width: 8),
          Text('Ver Pokédex', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  ),
),

            // ── Botón Personalizados ─────────────────────────
            _Tarjeta(
              titulo: 'Personalizados',
              descripcion: 'Ir a la pantalla de personalización',
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.systemPurple,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: _irAPersonalizados,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.paintbrush, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Ver Personalizados',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Botón de cerrar sesión (existente) ─────────
            GestureDetector(
              onTap: _cerrarSesion,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.destructiveRed.withOpacity(0.6),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.square_arrow_left,
                      color: CupertinoColors.destructiveRed,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  // Construye un IconButton circular
  Widget _icono(IconData icon, Color color) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _mostrarSnack('${icon.codePoint} presionado'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // Muestra un diálogo simple a modo de "snackbar"
  void _mostrarSnack(String mensaje) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CupertinoAlertDialog(
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget privado: tarjeta contenedora para cada control
// ─────────────────────────────────────────────────────────────
class _Tarjeta extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final Widget child;

  const _Tarjeta({
    required this.titulo,
    required this.descripcion,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del control
          Text(
            titulo,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),

          // Descripción
          Text(
            descripcion,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),

          // Contenido del control
          child,
        ],
      ),
    );
  }
}

// Extensión auxiliar para usar withOpacity con CupertinoColors
extension ColorOpacity on Color {
  Color withOpacityValue(double opacity) => withOpacity(opacity);
}

// Alias para usar LinearProgressIndicator y CircularProgressIndicator
// que son widgets de Material pero funcionan sin MaterialApp
class LinearProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Animation<Color?>? valueColor;
  final double minHeight;

  const LinearProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.minHeight = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = (valueColor as AlwaysStoppedAnimation<Color?>?)?.value ??
        CupertinoColors.activeBlue;
    final bg = backgroundColor ?? const Color(0xFF2C2C2E);

    return SizedBox(
      height: minHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Fondo
              Container(
                width: constraints.maxWidth,
                height: minHeight,
                color: bg,
              ),

              // Barra de progreso
              if (value != null)
                Container(
                  width: constraints.maxWidth * value!,
                  height: minHeight,
                  color: color,
                )
              else
                // Animación indeterminada simulada con TweenAnimationBuilder
                _IndeterminateBar(
                  color: color,
                  width: constraints.maxWidth,
                  height: minHeight,
                ),
            ],
          );
        },
      ),
    );
  }
}

// Barra indeterminada animada
class _IndeterminateBar extends StatefulWidget {
  final Color color;
  final double width;
  final double height;

  const _IndeterminateBar({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: -0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final barW = widget.width * 0.4;
        final x = _anim.value * widget.width;
        return Positioned(
          left: x.clamp(-barW, widget.width),
          child: Container(
            width: barW,
            height: widget.height,
            color: widget.color,
          ),
        );
      },
    );
  }
}

// CircularProgressIndicator personalizado (sin depender de Material)
class CircularProgressIndicator extends StatefulWidget {
  final double? value;
  final Color? backgroundColor;
  final Animation<Color?>? valueColor;
  final double strokeWidth;

  const CircularProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.strokeWidth = 4.0,
  });

  @override
  State<CircularProgressIndicator> createState() =>
      _CircularProgressIndicatorState();
}

class _CircularProgressIndicatorState extends State<CircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.value == null) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = (widget.valueColor as AlwaysStoppedAnimation<Color?>?)?.value
        ?? CupertinoColors.activeBlue;
    final bg = widget.backgroundColor ?? const Color(0xFF2C2C2E);

    if (widget.value != null) {
      return CustomPaint(
        painter: _CirclePainter(
          progress: widget.value!,
          color: color,
          backgroundColor: bg,
          strokeWidth: widget.strokeWidth,
          rotation: 0,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _CirclePainter(
          progress: 0.75,
          color: color,
          backgroundColor: bg,
          strokeWidth: widget.strokeWidth,
          rotation: _ctrl.value * 2 * 3.14159,
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double rotation;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Fondo
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Arco de progreso
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotation - 3.14159 / 2,
      progress * 2 * 3.14159,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.progress != progress || old.rotation != rotation;
}

// Alias de AlwaysStoppedAnimation para no importar Material
class AlwaysStoppedAnimation<T> extends Animation<T> {
  final T value;
  const AlwaysStoppedAnimation(this.value);

  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}
  @override
  AnimationStatus get status => AnimationStatus.forward;
}