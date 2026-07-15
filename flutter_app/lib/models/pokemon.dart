class Pokemon {
  final int id;
  final int national;
  final String name;
  final String alias;
  final String form;
  final String formalias;
  final int published;
  final int genid;
  final int releaseid;
  final int type1;
  final int type2;
  final int hp;
  final int attack;
  final int defense;
  final int spatk;
  final int spdef;
  final int speed;
  final String fullname;
  final String img;
  
  // Campo calculado para la imagen (sprites oficiales)
  String get imageUrl => 
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  Pokemon({
    required this.id,
    required this.national,
    required this.name,
    required this.alias,
    required this.form,
    required this.formalias,
    required this.published,
    required this.genid,
    required this.releaseid,
    required this.type1,
    required this.type2,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spatk,
    required this.spdef,
    required this.speed,
    required this.fullname,
    required this.img,
  });

  factory Pokemon.fromPokeApi(Map<String, dynamic> json, int id) {
    // PokeAPI devuelve datos básicos, necesitamos otra llamada para stats
    // Pero para simplicidad, usamos valores por defecto si no tenemos stats
    return Pokemon(
      id: id,
      national: id,
      name: json['name'] != null 
          ? (json['name'] as String)[0].toUpperCase() + (json['name'] as String).substring(1)
          : 'Desconocido',
      alias: json['name'] ?? '',
      form: '',
      formalias: '',
      published: 1,
      genid: 1,
      releaseid: 1,
      type1: 1,
      type2: 0,
      hp: 0,
      attack: 0,
      defense: 0,
      spatk: 0,
      spdef: 0,
      speed: 0,
      fullname: json['name'] != null 
          ? (json['name'] as String)[0].toUpperCase() + (json['name'] as String).substring(1)
          : 'Desconocido',
      img: json['name'] ?? '',
    );
  }

  // Para CRUD simulado, podemos crear desde un mapa simple
  factory Pokemon.fromSimpleMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'] as int,
      national: map['national'] as int? ?? map['id'] as int,
      name: map['name'] as String,
      alias: map['alias'] as String? ?? (map['name'] as String).toLowerCase(),
      form: map['form'] as String? ?? '',
      formalias: map['formalias'] as String? ?? '',
      published: map['published'] as int? ?? 1,
      genid: map['genid'] as int? ?? 1,
      releaseid: map['releaseid'] as int? ?? 1,
      type1: map['type1'] as int? ?? 1,
      type2: map['type2'] as int? ?? 0,
      hp: map['hp'] as int? ?? 0,
      attack: map['attack'] as int? ?? 0,
      defense: map['defense'] as int? ?? 0,
      spatk: map['spatk'] as int? ?? 0,
      spdef: map['spdef'] as int? ?? 0,
      speed: map['speed'] as int? ?? 0,
      fullname: map['fullname'] as String? ?? map['name'] as String,
      img: map['img'] as String? ?? (map['name'] as String).toLowerCase(),
    );
  }

  Map<String, dynamic> toSimpleMap() {
    return {
      'id': id,
      'national': national,
      'name': name,
      'alias': alias,
      'form': form,
      'formalias': formalias,
      'published': published,
      'genid': genid,
      'releaseid': releaseid,
      'type1': type1,
      'type2': type2,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'spatk': spatk,
      'spdef': spdef,
      'speed': speed,
      'fullname': fullname,
      'img': img,
    };
  }
}