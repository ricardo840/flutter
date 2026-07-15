import 'package:flutter/cupertino.dart';
import '../data/services/file_service.dart'; // 👈 Ruta corregida


class FilePracticeWidget extends StatefulWidget {
  const FilePracticeWidget({super.key});

  @override
  State<FilePracticeWidget> createState() => _FilePracticeWidgetState();
}

class _FilePracticeWidgetState extends State<FilePracticeWidget> {
  final FileService _fileService = FileService();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _fileContent = '';
  List<String> _fileList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFileList();
    });
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ---- Todos los métodos (create, read, update, delete, list) ----
  // (Son los mismos que ya tienes, no los repito para no alargar)
  // Asegúrate de que los métodos usen _fileService con la ruta corregida.

  Future<void> _createFile() async {
    final name = _fileNameController.text.trim();
    final content = _contentController.text;

    print('📝 Creando archivo: "$name" con contenido: "$content"');
    if (name.isEmpty) {
      _showDialog('Error', 'El nombre del archivo es obligatorio.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await _fileService.createFile(name, content);
      if (success) {
        _showDialog('Éxito', 'Archivo "$name" creado correctamente.');
        await _refreshFileList();
        setState(() => _fileContent = content);
      } else {
        _showDialog('Error', 'No se pudo crear el archivo.');
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _readFile() async {
    final name = _fileNameController.text.trim();
    if (name.isEmpty) {
      _showDialog('Error', 'Ingresa el nombre del archivo.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final content = await _fileService.readFile(name);
      if (content != null) {
        setState(() => _fileContent = content);
        _showDialog('Contenido', 'Contenido de "$name":\n\n$content');
      } else {
        _showDialog('Error', 'El archivo "$name" no existe o no se pudo leer.');
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateFile() async {
    final name = _fileNameController.text.trim();
    final content = _contentController.text;
    if (name.isEmpty) {
      _showDialog('Error', 'Ingresa el nombre del archivo.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await _fileService.updateFile(name, content);
      if (success) {
        _showDialog('Éxito', 'Archivo "$name" actualizado.');
        await _refreshFileList();
        setState(() => _fileContent = content);
      } else {
        _showDialog('Error', 'El archivo "$name" no existe o no se pudo actualizar.');
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFile() async {
    final name = _fileNameController.text.trim();
    if (name.isEmpty) {
      _showDialog('Error', 'Ingresa el nombre del archivo.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await _fileService.deleteFile(name);
      if (success) {
        _showDialog('Éxito', 'Archivo "$name" eliminado.');
        await _refreshFileList();
        setState(() {
          _fileContent = '';
          _fileNameController.clear();
          _contentController.clear();
        });
      } else {
        _showDialog('Error', 'El archivo "$name" no existe o no se pudo eliminar.');
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshFileList() async {
    try {
      final list = await _fileService.listFiles();
      if (mounted) setState(() => _fileList = list);
    } catch (e) {
      if (mounted) {
        _showDialog('Error', 'No se pudo obtener la lista de archivos: ${e.toString()}');
      }
    }
  }

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoTextField(
                  controller: _fileNameController,
                  placeholder: 'Nombre del archivo (ej: nota.txt)',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _contentController,
                  placeholder: 'Contenido del archivo',
                  maxLines: 4,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton('Crear', CupertinoColors.activeBlue, _createFile),
                    _buildActionButton('Leer', CupertinoColors.activeGreen, _readFile),
                    _buildActionButton('Actualizar', CupertinoColors.activeOrange, _updateFile),
                    _buildActionButton('Eliminar', CupertinoColors.destructiveRed, _deleteFile),
                    _buildActionButton('Listar', CupertinoColors.systemPurple, _refreshFileList),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Archivos disponibles:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                if (_fileList.isEmpty)
                  const Text('No hay archivos.',
                      style: TextStyle(color: CupertinoColors.systemGrey))
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _fileList.map((name) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(name, style: const TextStyle(fontSize: 14)),
                      )).toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                if (_fileContent.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 0.5,
                        color: CupertinoColors.separator,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      const Text('Contenido del último archivo:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.darkBackgroundGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_fileContent,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(8),
      color: color,
      onPressed: _isLoading ? null : onPressed,
      child: Text(label, style: const TextStyle(color: CupertinoColors.white)),
    );
  }
}