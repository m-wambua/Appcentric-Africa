
import 'dart:convert';
import 'package:appcentricafrica/models/question.dart';
import 'package:appcentricafrica/models/subject.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/paper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('papers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cached_papers (
        id INTEGER PRIMARY KEY,
        subject_id INTEGER NOT NULL,
        year INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        subject_data TEXT,
        questions_data TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');
  }

  // Cache a paper
  Future<void> cachePaper(Paper paper) async {
    final db = await database;
    
    await db.insert(
      'cached_papers',
      {
        'id': paper.id,
        'subject_id': paper.subjectId,
        'year': paper.year,
        'title': paper.title,
        'description': paper.description,
        'subject_data': paper.subject != null 
            ? jsonEncode({
                'id': paper.subject!.id,
                'name': paper.subject!.name,
                'code': paper.subject!.code,
              })
            : null,
        'questions_data': paper.questions != null
            ? jsonEncode(paper.questions!.map((q) => q.toJson()).toList())
            : null,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get cached paper
  Future<Paper?> getCachedPaper(int paperId) async {
    final db = await database;
    
    final maps = await db.query(
      'cached_papers',
      where: 'id = ?',
      whereArgs: [paperId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return Paper(
      id: map['id'] as int,
      subjectId: map['subject_id'] as int,
      year: map['year'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      subject: map['subject_data'] != null
          ? Subject.fromJson(jsonDecode(map['subject_data'] as String))
          : null,
      questions: map['questions_data'] != null
          ? (jsonDecode(map['questions_data'] as String) as List)
              .map((q) => Question.fromJson(q))
              .toList()
          : null,
    );
  }

  // Get last viewed paper
  Future<Paper?> getLastViewedPaper() async {
    final db = await database;
    
    final maps = await db.query(
      'cached_papers',
      orderBy: 'cached_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return Paper(
      id: map['id'] as int,
      subjectId: map['subject_id'] as int,
      year: map['year'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      subject: map['subject_data'] != null
          ? Subject.fromJson(jsonDecode(map['subject_data'] as String))
          : null,
      questions: map['questions_data'] != null
          ? (jsonDecode(map['questions_data'] as String) as List)
              .map((q) => Question.fromJson(q))
              .toList()
          : null,
    );
  }

  // Get all cached papers
  Future<List<Paper>> getAllCachedPapers() async {
    final db = await database;
    
    final maps = await db.query(
      'cached_papers',
      orderBy: 'cached_at DESC',
    );

    return maps.map((map) {
      return Paper(
        id: map['id'] as int,
        subjectId: map['subject_id'] as int,
        year: map['year'] as int,
        title: map['title'] as String,
        description: map['description'] as String?,
        subject: map['subject_data'] != null
            ? Subject.fromJson(jsonDecode(map['subject_data'] as String))
            : null,
        questions: map['questions_data'] != null
            ? (jsonDecode(map['questions_data'] as String) as List)
                .map((q) => Question.fromJson(q))
                .toList()
            : null,
      );
    }).toList();
  }

  // Clear old cache (keep last 10 papers)
  Future<void> clearOldCache() async {
    final db = await database;
    
    await db.delete(
      'cached_papers',
      where: 'id NOT IN (SELECT id FROM cached_papers ORDER BY cached_at DESC LIMIT 10)',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}