import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';

class CategoryAdminPage extends StatefulWidget {
  @override
  State<CategoryAdminPage> createState() => _CategoryAdminPageState();
}

class _CategoryAdminPageState extends State<CategoryAdminPage> {
  final CategoryService service = CategoryService();
  final TextEditingController controller = TextEditingController();

  List<Category> categories = [];
  int? editingId;

  Future<void> fetch() async {
    final data = await service.getCategories();
    setState(() => categories = data);
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void addCategory() async {
    if (controller.text.isEmpty) return;
    await service.createCategory(controller.text);
    controller.clear();
    fetch();
  }

  void updateCategory(int id) async {
    if (controller.text.isEmpty) return;
    await service.updateCategory(id, controller.text);
    controller.clear();
    setState(() => editingId = null);
    fetch();
  }

  void deleteCategory(int id) async {
    await service.deleteCategory(id);
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
              (route) => false,
            );
          },
        ),
        title: const Text("Manage Categories")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: editingId == null
                            ? "Category name"
                            : "Edit category...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      editingId == null
                          ? addCategory()
                          : updateCategory(editingId!);
                    },
                    child: Text(editingId == null ? "Add" : "Update"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final c = categories[i];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(c.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                controller.text = c.name;
                                editingId = c.id;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteCategory(c.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
