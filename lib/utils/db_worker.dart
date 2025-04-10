// The University of Texas at El Paso
// Bryan Perez

/// An interface for database workers in the FlutterBook app.
///
/// This abstract class defines the contract for CRUD operations on entities.
abstract class DBWorker<T> {
  /// Creates a new entity in the database.
  Future<int> create(T entity);

  /// Retrieves an entity by its ID.
  Future<T?> get(int id);

  /// Retrieves all entities from the database.
  Future<List<T>> getAll();

  /// Updates an existing entity in the database.
  Future<int> update(T entity);

  /// Deletes an entity from the database by its ID.
  Future<int> delete(int id);
}