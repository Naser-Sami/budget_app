import 'package:drift/drift.dart';
import 'categories_table.dart';
import 'accounts_table.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  TextColumn get accountId => text().references(AccountsTable, #id)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
