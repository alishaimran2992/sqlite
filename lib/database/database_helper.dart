

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite/models/student.dart';
import 'package:sqlite/data_store.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // database
  DatabaseHelper._privateConstructor(); // Name constructor to create instance of database
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // getter for database

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS
    // to store database

    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/decode.db';

    // open/ create database at a given path
    var studentsDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );

    return studentsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''Create TABLE $tableStudent (
                  $colId INTEGER PRIMARY KEY AUTOINCREMENT,
                  $colName TEXT,
                  $colEmail TEXT UNIQUE,
                  $colMobile TEXT,
                  $colCourse TEXT,
                  $colUni TEXT
                   );
    
    ''');
  }

  // insert
  Future<int> saveStudent(Student student) async {
    // add student to table

    Database db = await instance.database;

    // String insertQuery = '''
    // INSERT INTO $tableStudent
    //   ( $colName, $colEmail, $colMobile, $colCourse, $colUni )
    //   VALUES ( ?, ?, ?, ?, ? )
    // ''';

    //int result = await db.rawInsert(insertQuery, [student.name, student.email, student.mobile, student.course, student.uni ]);

    int result = await db.insert(tableStudent, student.toMap());

    return result;
  }

  // read operation
  Future<List<Student>> getAllStudents() async {
    List<Student> students = [];

    Database db = await instance.database;

    // read data from table
    // we will get list of maps
    List<Map<String, dynamic>> listMap = await db.query(tableStudent);

    // List<Map<String, dynamic>> listOfStudents = await db.rawQuery('SELECT * from $tableStudent');

    // converting map to object and then adding to the list
    for (var studentMap in listMap) {
      Student student = Student.fromMap(studentMap);
      students.add(student);
    }

    //await Future.delayed(const Duration(seconds: 2));

    return students;
  }
  //
  // delete
  Future<int> deleteStudent(int id) async {
    Database db = await instance.database;
    int result = await db.rawDelete('DELETE FROM $tableStudent where id=?', [id]);
    //int result = await db.delete(tableStudent, where: 'id=?', whereArgs: [id]);
    return result;
  }
  //
  // // update
  Future<int> updateStudent(Student student) async {
    Database db = await instance.database;
    int result = await db.update(tableStudent, student.toMap(), where: 'id=?', whereArgs: [student.id]);
    return result;
  }




  // search operation
  Future<List<Student>> searchStudents({required String name}) async {
    List<Student> students = [];

    Database db = await instance.database;

    // read data from table
    // we will get list of map
    // wild card search
    List<Map<String, dynamic>> listMap = await db.query(tableStudent, where: 'name like ?', whereArgs: ['%$name%']);

    // List<Map<String, dynamic>> listOfStudents = await db.rawQuery('SELECT * from $tableStudent');

    // converting map to object and then adding to the list
    for (var studentMap in listMap) {
      Student student = Student.fromMap(studentMap);
      students.add(student);
    }

    //await Future.delayed(const Duration(seconds: 2));

    return students;
  }
}