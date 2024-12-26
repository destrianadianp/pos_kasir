import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_kasir/feature/kelola_produk/widgets/search_bar.dart';
import '../../provider/category_provider.dart';
import '../../provider/product_provider.dart';
import 'widgets/container_product.dart';
import 'widgets/kategori_screen.dart';
import '../tambah_produk/tambah_produk.dart';
import '../ui/shared_view/drawer_menu.dart';
import '../ui/color.dart';

class KelolaProdukPage extends StatefulWidget {
  const KelolaProdukPage({super.key});

  @override
  State<KelolaProdukPage> createState() => _KelolaProdukPageState();
}

class _KelolaProdukPageState extends State<KelolaProdukPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchValue = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    Provider.of<ProductCartProvider>(context, listen: false).fetchProducts(
      FirebaseAuth.instance.currentUser!.uid,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // Dapatkan user saat ini dari Firebase Authentication
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String userId = user.uid; // Ambil uid dari user
          Provider.of<CategoryProvider>(context, listen: false)
              .fetchCategories(userId); // Kirim uid ke fetchCategories
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productCartProvider = Provider.of<ProductCartProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        leading: Builder(
          builder: (context) => GestureDetector(
            child: const Icon(Icons.list_outlined),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Kelola Produk'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Produk'),
            Tab(text: 'Kategori'),
          ],
        ),
      ),
      drawer: const DrawerMenu(),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            color: secondaryColor,
            child: Column(
              children: [
                CustomSearchBar(
                  hintText: 'Cari barang',
                  onChanged: (value) {
                    setState(() {
                      _searchValue = value;
                    });
                  },
                  controller: _searchController,
                ),
                Expanded(
                  child: ProdukPage(
                    productCartProvider: productCartProvider,
                    searchQuery: _searchValue,
                  ),
                ),
              ],
            ),
          ),
          const KategoriPage()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: () {
          if (_currentIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahProduk(),
              ),
            );
          } else if (_currentIndex == 1) {
            _showAddCategoryDialog(context, categoryProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Fungsi untuk menampilkan dialog tambah kategori
void _showAddCategoryDialog(
    BuildContext context, CategoryProvider categoryProvider) {
  TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nama kategori baru',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        String userId = user.uid;
                        await categoryProvider.addCategory(
                            userId, controller.text);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
