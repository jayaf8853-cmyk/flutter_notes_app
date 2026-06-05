import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class NoteService {
  static const String boxName = 'notesBox';

  
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(boxName);
  }

  static Box<Note> getBox() => Hive.box<Note>(boxName);

  static void addNote(Note note) => getBox().add(note);
  static void updateNote(dynamic key, Note note) => getBox().put(key, note);
  static void deleteNote(dynamic key) => getBox().delete(key);
}