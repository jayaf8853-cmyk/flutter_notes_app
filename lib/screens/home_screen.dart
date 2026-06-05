import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../themes/app_theme.dart';
import '../widgets/note_item.dart';
import 'add_note.dart';
import 'edit_note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  void _deleteNoteWithFeedback(dynamic key) {
    NoteService.deleteNote(key);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari catatan...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              )
            : const Text('Daftar Catatan'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  searchQuery = '';
                }
                isSearching = !isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light 
                  ? ThemeMode.dark 
                  : ThemeMode.light;
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: NoteService.getBox().listenable(),
        builder: (context, Box<Note> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }

          final List<Note> notes = box.values.toList();
          final List<dynamic> keys = box.keys.toList();
          List<int> filteredIndices = [];

          for (int i = 0; i < notes.length; i++) {
            if (notes[i].title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                notes[i].content.toLowerCase().contains(searchQuery.toLowerCase())) {
              filteredIndices.add(i);
            }
          }

          if (filteredIndices.isEmpty) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }

          return ListView.builder(
            itemCount: filteredIndices.length,
            itemBuilder: (context, index) {
              final actualIndex = filteredIndices[index];
              final note = notes[actualIndex];
              final key = keys[actualIndex];

              return NoteItem(
                note: note,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNoteScreen(noteKey: key, note: note),
                  ),
                ),
                onDelete: () => _deleteNoteWithFeedback(key),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddNoteScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}