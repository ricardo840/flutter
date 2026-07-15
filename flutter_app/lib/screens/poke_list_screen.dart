import 'package:flutter/cupertino.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

class PokeListScreen extends StatefulWidget {
  const PokeListScreen({super.key});

  @override
  State<PokeListScreen> createState() => _PokeListScreenState();
}

class _PokeListScreenState extends State<PokeListScreen> {
  final PokeApiService _api = PokeApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _displayedPokemons = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final firstPage = await _api.fetchPokemonPage(offset: 0, limit: _pageSize);
      setState(() {
        _allPokemons = firstPage;
        _displayedPokemons = firstPage;
        _currentOffset = _pageSize;
        _hasMore = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Error', 'No se pudieron cargar los Pokémon: $e');
    }
  }

  void _loadMore() async {
    if (_isLoading || !_hasMore || _searchQuery.isNotEmpty) return;
    setState(() => _isLoading = true);
    try {
      final nextPage = await _api.fetchPokemonPage(offset: _currentOffset, limit: _pageSize);
      if (nextPage.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _allPokemons.addAll(nextPage);
        _displayedPokemons = _allPokemons;
        _currentOffset += nextPage.length;
        _hasMore = nextPage.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Error', 'No se pudieron cargar más Pokémon: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _displayedPokemons = _allPokemons;
      } else {
        _displayedPokemons = _api.searchPokemon(query, _allPokemons);
      }
    });
  }

  void _showAlert(String title, String message) {
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

  // ─── CRUD dialogs (sin cambios) ──────────────────────────
  void _showAddDialog() {
    final nameController = TextEditingController();
    final hpController = TextEditingController();
    final atkController = TextEditingController();
    final defController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Agregar Pokémon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(controller: nameController, placeholder: 'Nombre'),
            const SizedBox(height: 8),
            CupertinoTextField(controller: hpController, placeholder: 'HP', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CupertinoTextField(controller: atkController, placeholder: 'Ataque', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CupertinoTextField(controller: defController, placeholder: 'Defensa', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final name = nameController.text.trim();
              final hp = int.tryParse(hpController.text) ?? 0;
              final atk = int.tryParse(atkController.text) ?? 0;
              final def = int.tryParse(defController.text) ?? 0;
              if (name.isEmpty) { _showAlert('Error', 'El nombre es obligatorio.'); return; }
              final newId = _allPokemons.isNotEmpty ? _allPokemons.last.id + 1 : 1000;
              final newPokemon = Pokemon(
                id: newId,
                national: newId,
                name: name,
                alias: name.toLowerCase(),
                form: '',
                formalias: '',
                published: 1,
                genid: 1,
                releaseid: 1,
                type1: 1,
                type2: 0,
                hp: hp,
                attack: atk,
                defense: def,
                spatk: 0,
                spdef: 0,
                speed: 0,
                fullname: name,
                img: name.toLowerCase(),
              );
              final success = await _api.addPokemon(newPokemon);
              Navigator.pop(context);
              if (success) {
                _showAlert('Éxito', 'Pokémon agregado');
                await _refreshData();
              } else {
                _showAlert('Error', 'No se pudo agregar');
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Pokemon pokemon) {
    final nameController = TextEditingController(text: pokemon.name);
    final hpController = TextEditingController(text: pokemon.hp.toString());
    final atkController = TextEditingController(text: pokemon.attack.toString());
    final defController = TextEditingController(text: pokemon.defense.toString());

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Editar ${pokemon.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(controller: nameController, placeholder: 'Nombre'),
            const SizedBox(height: 8),
            CupertinoTextField(controller: hpController, placeholder: 'HP', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CupertinoTextField(controller: atkController, placeholder: 'Ataque', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CupertinoTextField(controller: defController, placeholder: 'Defensa', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final name = nameController.text.trim();
              final hp = int.tryParse(hpController.text) ?? pokemon.hp;
              final atk = int.tryParse(atkController.text) ?? pokemon.attack;
              final def = int.tryParse(defController.text) ?? pokemon.defense;
              if (name.isEmpty) { _showAlert('Error', 'El nombre es obligatorio.'); return; }
              final updated = Pokemon(
                id: pokemon.id,
                national: pokemon.national,
                name: name,
                alias: name.toLowerCase(),
                form: pokemon.form,
                formalias: pokemon.formalias,
                published: pokemon.published,
                genid: pokemon.genid,
                releaseid: pokemon.releaseid,
                type1: pokemon.type1,
                type2: pokemon.type2,
                hp: hp,
                attack: atk,
                defense: def,
                spatk: pokemon.spatk,
                spdef: pokemon.spdef,
                speed: pokemon.speed,
                fullname: name,
                img: name.toLowerCase(),
              );
              final success = await _api.updatePokemon(updated);
              Navigator.pop(context);
              if (success) {
                _showAlert('Éxito', 'Pokémon actualizado');
                await _refreshData();
              } else {
                _showAlert('Error', 'No se pudo actualizar');
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final firstPage = await _api.fetchPokemonPage(offset: 0, limit: _pageSize);
    setState(() {
      _allPokemons = firstPage;
      _displayedPokemons = firstPage;
      _currentOffset = _pageSize;
      _hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1C1C1E),
        border: null,
        middle: const Text('Pokédex', style: TextStyle(color: CupertinoColors.white)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showAddDialog,
          child: const Icon(CupertinoIcons.add, color: CupertinoColors.activeBlue),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CupertinoSearchTextField(
                placeholder: 'Buscar Pokémon...',
                backgroundColor: CupertinoColors.darkBackgroundGray,
                onChanged: _search,
              ),
            ),
            Expanded(
              child: _isLoading && _allPokemons.isEmpty
                  ? const Center(child: CupertinoActivityIndicator())
                  : CupertinoScrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _displayedPokemons.length + (_hasMore && _searchQuery.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _displayedPokemons.length && _hasMore && _searchQuery.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CupertinoActivityIndicator()),
                            );
                          }
                          final pokemon = _displayedPokemons[index];
                          return _buildPokemonTile(pokemon);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonTile(Pokemon pokemon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              pokemon.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                CupertinoIcons.person_alt_circle,
                size: 40,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${pokemon.national} ${pokemon.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'HP: ${pokemon.hp}  ATK: ${pokemon.attack}  DEF: ${pokemon.defense}',
                  style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showEditDialog(pokemon),
                child: const Icon(CupertinoIcons.pencil, color: CupertinoColors.activeOrange, size: 20),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final confirm = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: const Text('Eliminar Pokémon'),
                      content: Text('¿Eliminar a ${pokemon.name}?'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final success = await _api.deletePokemon(pokemon.id);
                    if (success) {
                      _showAlert('Éxito', 'Pokémon eliminado');
                      await _refreshData();
                    } else {
                      _showAlert('Error', 'No se pudo eliminar');
                    }
                  }
                },
                child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}