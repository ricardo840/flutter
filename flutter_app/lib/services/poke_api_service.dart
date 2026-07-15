// lib/services/poke_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static final PokeApiService _instance = PokeApiService._internal();
  factory PokeApiService() => _instance;
  PokeApiService._internal();

  final List<Pokemon> _localPokemons = [];
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  // Obtiene los detalles de un Pokémon por ID o nombre
  Future<Map<String, dynamic>> _fetchPokemonDetail(String idOrName) async {
    final url = '$_baseUrl/$idOrName';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener detalles de Pokémon: ${response.statusCode}');
    }
  }

  // Crea un objeto Pokemon completo a partir de los detalles
  Pokemon _pokemonFromDetail(Map<String, dynamic> detail) {
    final id = detail['id'] as int;
    final name = detail['name'] as String;
    final stats = detail['stats'] as List;
    final hp = stats.firstWhere((s) => s['stat']['name'] == 'hp')['base_stat'] as int;
    final attack = stats.firstWhere((s) => s['stat']['name'] == 'attack')['base_stat'] as int;
    final defense = stats.firstWhere((s) => s['stat']['name'] == 'defense')['base_stat'] as int;
    final spatk = stats.firstWhere((s) => s['stat']['name'] == 'special-attack')['base_stat'] as int;
    final spdef = stats.firstWhere((s) => s['stat']['name'] == 'special-defense')['base_stat'] as int;
    final speed = stats.firstWhere((s) => s['stat']['name'] == 'speed')['base_stat'] as int;

    return Pokemon(
      id: id,
      national: id,
      name: name[0].toUpperCase() + name.substring(1),
      alias: name,
      form: '',
      formalias: '',
      published: 1,
      genid: 1,
      releaseid: 1,
      type1: 1,
      type2: 0,
      hp: hp,
      attack: attack,
      defense: defense,
      spatk: spatk,
      spdef: spdef,
      speed: speed,
      fullname: name[0].toUpperCase() + name.substring(1),
      img: name,
    );
  }

  // Obtiene una página de Pokémon con todos los stats
  Future<List<Pokemon>> fetchPokemonPage({int offset = 0, int limit = 10}) async {
    try {
      final url = '$_baseUrl?offset=$offset&limit=$limit';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        // Obtener detalles de cada Pokémon en paralelo
        final List<Future<Map<String, dynamic>>> detailFutures = [];
        for (var item in results) {
          final String urlStr = item['url'];
          final List<String> parts = urlStr.split('/');
          final String id = parts[parts.length - 2];
          detailFutures.add(_fetchPokemonDetail(id));
        }
        
        final List<Map<String, dynamic>> details = await Future.wait(detailFutures);
        final List<Pokemon> page = details.map((d) => _pokemonFromDetail(d)).toList();
        
        // Actualizar lista local
        if (offset == 0) {
          _localPokemons.clear();
          _localPokemons.addAll(page);
        } else {
          _localPokemons.addAll(page);
        }
        
        print('✅ Página ${offset ~/ limit + 1} cargada: ${page.length} Pokémon con stats');
        return page;
      } else {
        throw Exception('Error al cargar Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en fetchPokemonPage: $e');
      rethrow;
    }
  }

  // Obtener todos (carga completa) - opcional, para búsqueda
  Future<List<Pokemon>> fetchAllPokemon() async {
    // Cargamos todos los IDs primero
    try {
      final response = await http.get(Uri.parse('$_baseUrl?limit=1000'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        final List<int> ids = [];
        for (var item in results) {
          final String urlStr = item['url'];
          final List<String> parts = urlStr.split('/');
          ids.add(int.parse(parts[parts.length - 2]));
        }
        
        // Cargar detalles en lotes de 10 para no saturar
        final List<Pokemon> all = [];
        for (int i = 0; i < ids.length; i += 10) {
          final batch = ids.skip(i).take(10).toList();
          final futures = batch.map((id) => _fetchPokemonDetail(id.toString()));
          final details = await Future.wait(futures);
          final batchPokemons = details.map((d) => _pokemonFromDetail(d)).toList();
          all.addAll(batchPokemons);
        }
        
        _localPokemons.clear();
        _localPokemons.addAll(all);
        print('✅ Todos los Pokémon cargados con stats: ${all.length}');
        return all;
      } else {
        throw Exception('Error al cargar todos los Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en fetchAllPokemon: $e');
      rethrow;
    }
  }

  // Búsqueda local
  List<Pokemon> searchPokemon(String query, List<Pokemon> all) {
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all.where((p) =>
      p.name.toLowerCase().contains(lower) ||
      p.alias.toLowerCase().contains(lower)
    ).toList();
  }

  // CRUD simulado (sin cambios)
  List<Pokemon> getLocalPokemons() => List.from(_localPokemons);
  Future<bool> addPokemon(Pokemon pokemon) async {
    try {
      _localPokemons.add(pokemon);
      print('✅ Pokémon añadido (simulado): ${pokemon.name}');
      return true;
    } catch (e) {
      print('❌ Error al añadir Pokémon: $e');
      return false;
    }
  }
  Future<bool> updatePokemon(Pokemon updated) async {
    try {
      final index = _localPokemons.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        _localPokemons[index] = updated;
        print('✅ Pokémon actualizado (simulado): ${updated.name}');
        return true;
      }
      print('⚠️ Pokémon no encontrado para actualizar: id ${updated.id}');
      return false;
    } catch (e) {
      print('❌ Error al actualizar Pokémon: $e');
      return false;
    }
  }
  Future<bool> deletePokemon(int id) async {
    try {
      final previousLength = _localPokemons.length;
      _localPokemons.removeWhere((p) => p.id == id);
      final removed = previousLength > _localPokemons.length;
      if (removed) {
        print('🗑️ Pokémon eliminado (simulado): id $id');
        return true;
      }
      print('⚠️ Pokémon no encontrado para eliminar: id $id');
      return false;
    } catch (e) {
      print('❌ Error al eliminar Pokémon: $e');
      return false;
    }
  }
}