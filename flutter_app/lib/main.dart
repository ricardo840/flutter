import 'package:flutter/cupertino.dart';
import 'data/services/auth_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.bootstrap();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _mostrarPassword = false;
  bool _terminosAceptados = false;

  String? _errorUsuario;
  String? _errorPassword;
  bool _iniciandoSesion = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_iniciandoSesion) {
      return;
    }

    setState(() {
      _iniciandoSesion = true;
      _errorUsuario = null;
      _errorPassword = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validar campos vacíos
    if (username.isEmpty) {
      setState(() {
        _iniciandoSesion = false;
        _errorUsuario = 'Ingresa un usuario';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _iniciandoSesion = false;
        _errorPassword = 'Ingresa una contraseña';
      });
      return;
    }

    final result = await AuthService.instance.signIn(
      username: username,
      password: password,
      termsAccepted: _terminosAceptados,
    );

    if (!mounted) {
      return;
    }

    if (result == SignInResult.userNotFound) {
      setState(() {
        _iniciandoSesion = false;
        _errorUsuario = 'Usuario incorrecto';
      });
      return;
    }

    if (result == SignInResult.invalidPassword) {
      setState(() {
        _iniciandoSesion = false;
        _errorPassword = 'Contraseña incorrecta';
      });
      return;
    }

    if (result == SignInResult.termsNotAccepted) {
      setState(() {
        _iniciandoSesion = false;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  void _mostrarRegistroDeshabilitado() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Registro'),
        content: const Text(
          'El registro se encuentra deshabilitado para este taller.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _verTerminos() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const Text(
          'Al utilizar esta aplicación aceptas que es una práctica educativa. '
          'No se almacenan datos personales y el uso es únicamente académico.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Aceptar'),
            onPressed: () {
              setState(() {
                _terminosAceptados = true;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                const SizedBox(height: 25),

                const Text(
                  'Iniciar sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Accede para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),

                const SizedBox(height: 35),

                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Usuario',
                  padding: const EdgeInsets.all(14),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                    border: _errorUsuario != null
                        ? Border.all(
                            color: CupertinoColors.destructiveRed,
                          )
                        : null,
                  ),
                ),

                if (_errorUsuario != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 4),
                    child: Text(
                      _errorUsuario!,
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    CupertinoTextField(
                      controller: _passwordController,
                      obscureText: !_mostrarPassword,
                      placeholder: 'Contraseña',
                      padding: const EdgeInsets.only(
                        left: 14,
                        top: 14,
                        bottom: 14,
                        right: 45,
                      ),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                        border: _errorPassword != null
                            ? Border.all(
                                color: CupertinoColors.destructiveRed,
                              )
                            : null,
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        _mostrarPassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarPassword = !_mostrarPassword;
                        });
                      },
                    ),
                  ],
                ),

                if (_errorPassword != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 4),
                    child: Text(
                      _errorPassword!,
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                const Text(
                  'Usuario: admin1\nContraseña: lino',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    CupertinoSwitch(
                      value: _terminosAceptados,
                      onChanged: (value) {
                        setState(() {
                          _terminosAceptados = value;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _verTerminos,
                        child: const Text(
                          'Acepto los Términos y Condiciones',
                          style: TextStyle(
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                CupertinoButton.filled(
                  onPressed:
                      _terminosAceptados && !_iniciandoSesion ? _iniciarSesion : null,
                  child: Text(
                    _iniciandoSesion ? 'Validando...' : 'Iniciar sesión',
                  ),
                ),

                const SizedBox(height: 10),

                CupertinoButton(
                  onPressed: _mostrarRegistroDeshabilitado,
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
