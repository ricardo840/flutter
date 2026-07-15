import 'package:flutter/cupertino.dart';

// No importamos material.dart

void main() {
  runApp(const MyPOSApp());
}

class MyPOSApp extends StatelessWidget {
  const MyPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Punto de Venta',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeBlue,
        barBackgroundColor: CupertinoColors.black,
        scaffoldBackgroundColor: CupertinoColors.black,
      ),
      home: const POSHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  State<POSHomePage> createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  // Datos de ejemplo
  final List<Product> allProducts = [
    Product(
      id: '1',
      name: 'Fertilizante NPK 20-20',
      category: 'Fertilizantes',
      price: 450.00,
      stock: 25,
      imageIcon: '🌱',
    ),
    Product(
      id: '2',
      name: 'Semilla de Maíz Híbrido',
      category: 'Semillas',
      price: 890.00,
      stock: 50,
      imageIcon: '🌽',
    ),
    Product(
      id: '3',
      name: 'Herbicida Glifosato 1L',
      category: 'Agroquímicos',
      price: 320.00,
      stock: 8,
      imageIcon: '🧪',
    ),
    Product(
      id: '4',
      name: 'Fertilizante Líquido 5L',
      category: 'Fertilizantes',
      price: 620.00,
      stock: 15,
      imageIcon: '💧',
    ),
    Product(
      id: '5',
      name: 'Semilla de Girasol',
      category: 'Semillas',
      price: 210.00,
      stock: 30,
      imageIcon: '🌻',
    ),
    Product(
      id: '6',
      name: 'Insecticida Biológico',
      category: 'Agroquímicos',
      price: 520.00,
      stock: 12,
      imageIcon: '🐞',
    ),
    Product(
      id: '7',
      name: 'Fungicida Cobre 500ml',
      category: 'Agroquímicos',
      price: 380.00,
      stock: 5,
      imageIcon: '🛡️',
    ),
    Product(
      id: '8',
      name: 'Semilla de Trigo',
      category: 'Semillas',
      price: 740.00,
      stock: 40,
      imageIcon: '🌾',
    ),
  ];

  final List<String> categories = ['Todos', 'Fertilizantes', 'Semillas', 'Agroquímicos'];

  String selectedCategory = 'Todos';
  String searchQuery = '';

  final List<CartItem> cartItems = [];

  // Getters para cálculos
  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get iva => subtotal * 0.16;

  double get total => subtotal + iva;

  List<Product> get filteredProducts {
    final query = searchQuery.toLowerCase().trim();
    return allProducts.where((product) {
      final matchesCategory = selectedCategory == 'Todos' || product.category == selectedCategory;
      final matchesSearch = query.isEmpty || product.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void addToCart(Product product) {
    setState(() {
      final existing = cartItems.firstWhereOrNull((item) => item.product.id == product.id);
      if (existing != null) {
        existing.quantity++;
      } else {
        cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void removeFromCart(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cartItems.remove(item);
      }
    });
  }

  void clearCart() {
    setState(() {
      cartItems.clear();
    });
  }

  void checkout() {
    if (cartItems.isEmpty) return;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Confirmar cobro'),
        content: Text(
          'Total a cobrar: \$${total.toStringAsFixed(2)}\n'
          '¿Desea continuar?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cobrar'),
            onPressed: () {
              Navigator.pop(context);
              clearCart();
              showCupertinoDialog(
                context: context,
                builder: (context) => const CupertinoAlertDialog(
                  title: Text('¡Venta completada!'),
                  content: Text('El cobro se realizó con éxito.'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Aceptar'),
                      onPressed: null,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        border: const Border(bottom: BorderSide(color: CupertinoColors.separator, width: 0.5)),
        middle: const Text(
          'Punto de Venta',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings, size: 22),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel izquierdo: productos
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de búsqueda
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    // Filtros por categoría
                    _buildCategoryFilters(),
                    const SizedBox(height: 16),
                    // Lista de productos
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron productos',
                                style: TextStyle(color: CupertinoColors.systemGrey),
                              ),
                            )
                          : CupertinoScrollbar(
                              child: ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _buildProductCard(product);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Panel derecho: carrito
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.cart,
                          color: CupertinoColors.activeBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Carrito',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            'Limpiar',
                            style: TextStyle(
                              color: CupertinoColors.destructiveRed,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: cartItems.isEmpty ? null : clearCart,
                        ),
                      ],
                    ),
                    // Separador reemplazando Divider
                    Container(
                      height: 0.5,
                      color: CupertinoColors.separator,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    // Lista de items del carrito
                    Expanded(
                      child: cartItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.cart_badge_plus,
                                    size: 48,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Carrito vacío',
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : CupertinoScrollbar(
                              child: ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return _buildCartItem(item);
                                },
                              ),
                            ),
                    ),
                    // Separador reemplazando Divider
                    Container(
                      height: 0.5,
                      color: CupertinoColors.separator,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    // Resumen de precios
                    _buildPriceRow('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
                    _buildPriceRow(
                      'IVA (16%):',
                      '\$${iva.toStringAsFixed(2)}',
                      textColor: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 4),
                    _buildPriceRow(
                      'Total:',
                      '\$${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 12),
                    // Botón cobrar
                    CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      onPressed: cartItems.isEmpty ? null : checkout,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.creditcard, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Cobrar \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
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

  Widget _buildSearchBar() {
    return CupertinoSearchTextField(
      placeholder: 'Buscar por nombre o código...',
      backgroundColor: CupertinoColors.darkBackgroundGray,
      prefixIcon: const Icon(
        CupertinoIcons.search,
        color: CupertinoColors.systemGrey,
        size: 18,
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.darkBackgroundGray,
              onPressed: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? CupertinoColors.white : CupertinoColors.systemGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                product.imageIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.stock > 10
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemYellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            borderRadius: BorderRadius.circular(8),
            color: CupertinoColors.activeBlue,
            onPressed: () => addToCart(product),
            child: const Text(
              'Agregar',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.separator.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            item.product.imageIcon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(4),
                minSize: 0,
                onPressed: () => removeFromCart(item),
                child: const Icon(
                  CupertinoIcons.minus_circled,
                  color: CupertinoColors.destructiveRed,
                  size: 20,
                ),
              ),
              SizedBox(
                width: 24,
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(4),
                minSize: 0,
                onPressed: () {
                  setState(() {
                    item.quantity++;
                  });
                },
                child: const Icon(
                  CupertinoIcons.plus_circled,
                  color: CupertinoColors.activeBlue,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: textColor ?? CupertinoColors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
              color: isTotal ? CupertinoColors.activeBlue : (textColor ?? CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Modelos
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String imageIcon;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageIcon,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

// Extensión para firstWhereOrNull (Cupertino no la incluye)
extension FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}