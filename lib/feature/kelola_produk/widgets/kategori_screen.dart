import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/category_provider.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String userId = user.uid;
          await Provider.of<CategoryProvider>(
            context,
            listen: false,
          ).fetchCategories(userId);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: categoryProvider.categories.length,
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];
          return ListTile(
            title: Text(category),
            trailing: category != CategoryProvider.fixedCategory
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCategoryDialog(context, category),
                  )
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, categoryProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    CategoryProvider categoryProvider,
  ) {
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
                decoration:
                    const InputDecoration(labelText: 'Nama kategori baru'),
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
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        // Dapatkan userId dari Firebase Authentication
                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          String userId = user.uid;
                          // Panggil addCategory dengan userId dan kategori
                          await categoryProvider.addCategory(
                              userId, controller.text);
                        } else {
                          print('User belum login');
                        }
                        Navigator.pop(context);
                      }
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

  void _showEditCategoryDialog(BuildContext context, String currentCategory) {
    TextEditingController controller =
        TextEditingController(text: currentCategory);

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
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol hapus kategori
                  TextButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty &&
                          controller.text != currentCategory) {
                        // Ambil instance CategoryProvider
                        final categoryProvider = Provider.of<CategoryProvider>(
                            context,
                            listen: false);

                        // Dapatkan userId dari Firebase Authentication
                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          String userId = user.uid;

                          // Panggil deleteCategory menggunakan instance
                          await categoryProvider.deleteCategory(
                              userId, currentCategory);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Hapus',
                        style: TextStyle(color: Colors.red)),
                  ),

                  // Tombol batal
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),

                  // Tombol simpan kategori
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty &&
                          controller.text != currentCategory) {
                        // Ambil instance CategoryProvider
                        final categoryProvider = Provider.of<CategoryProvider>(
                            context,
                            listen: false);

                        // Dapatkan userId dari Firebase Authentication
                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          String userId = user.uid;

                          // Panggil editCategory menggunakan instance
                          await categoryProvider.editCategory(
                              userId, currentCategory, controller.text);
                        }
                        Navigator.pop(context);
                      }
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
}
