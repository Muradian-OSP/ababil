import 'package:flutter/material.dart';
import 'package:ababil_flutter/domain/models/collection.dart';
import 'package:ababil_flutter/domain/models/environment.dart';
import 'package:ababil_flutter/domain/models/http_request.dart';
import 'package:ababil_flutter/domain/models/request_path.dart';
import 'package:ababil_flutter/data/services/postman_service.dart';

class CollectionsViewModel extends ChangeNotifier {
  final List<Collection> _collections = [];
  final List<Environment> _environments = [];
  RequestPath? _selectedRequestPath;

  List<Collection> get collections => _collections;
  List<Environment> get environments => _environments;
  RequestPath? get selectedRequestPath => _selectedRequestPath;

  CollectionsViewModel() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    await PostmanService.initialize();
  }

  Future<bool> importCollection(String jsonString) async {
    try {
      // Ensure service is initialized before parsing
      await PostmanService.initialize();
      final collection = PostmanService.parseCollection(jsonString);
      if (collection != null) {
        _collections.add(collection);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing collection: $e');
      return false;
    }
  }

  Future<String?> exportCollection(Collection collection) async {
    try {
      return PostmanService.collectionToJson(collection);
    } catch (e) {
      debugPrint('Error exporting collection: $e');
      return null;
    }
  }

  Future<bool> importEnvironment(String jsonString) async {
    try {
      // Ensure service is initialized before parsing
      await PostmanService.initialize();
      final environment = PostmanService.parseEnvironment(jsonString);
      if (environment != null) {
        _environments.add(environment);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing environment: $e');
      return false;
    }
  }

  Future<String?> exportEnvironment(Environment environment) async {
    try {
      return PostmanService.environmentToJson(environment);
    } catch (e) {
      debugPrint('Error exporting environment: $e');
      return null;
    }
  }

  void removeCollection(Collection collection) {
    final index = _collections.indexOf(collection);
    if (index == -1) return;

    // Clear selection if it's in this collection
    if (_selectedRequestPath != null &&
        _selectedRequestPath!.collectionIndex == index) {
      _selectedRequestPath = null;
    }
    // Adjust indices if collection is before selected one
    else if (_selectedRequestPath != null &&
        _selectedRequestPath!.collectionIndex > index) {
      _selectedRequestPath = RequestPath(
        collectionIndex: _selectedRequestPath!.collectionIndex - 1,
        itemIndices: _selectedRequestPath!.itemIndices,
      );
    }

    _collections.removeAt(index);
    notifyListeners();
  }

  void removeEnvironment(Environment environment) {
    _environments.remove(environment);
    notifyListeners();
  }

  void selectRequest(RequestPath? path) {
    _selectedRequestPath = path;
    notifyListeners();
  }

  /// Get collection by index
  Collection? getCollectionByIndex(int index) {
    if (index < 0 || index >= _collections.length) return null;
    return _collections[index];
  }

  /// Get request item by path
  CollectionItem? getRequestItemByPath(RequestPath path) {
    final collection = getCollectionByIndex(path.collectionIndex);
    if (collection == null) return null;

    return _getItemByIndices(collection.item, path.itemIndices);
  }

  /// Get request by path
  HttpRequest? getRequestByPath(RequestPath path) {
    final item = getRequestItemByPath(path);
    return item?.request;
  }

  /// Get item by indices path
  CollectionItem? _getItemByIndices(
    List<CollectionItem> items,
    List<int> indices,
  ) {
    if (indices.isEmpty) return null;

    final currentIndex = indices[0];
    if (currentIndex < 0 || currentIndex >= items.length) return null;

    final currentItem = items[currentIndex];

    if (indices.length == 1) {
      return currentItem;
    }

    if (currentItem.item == null) return null;

    return _getItemByIndices(currentItem.item!, indices.sublist(1));
  }

  // Collection management methods
  void createCollection(String name, {String? description}) {
    final collection = Collection(
      info: CollectionInfo(
        name: name,
        description: description,
        schema:
            'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
      ),
      item: [],
    );
    _collections.add(collection);
    notifyListeners();
  }

  void updateCollection(
    Collection collection,
    String newName, {
    String? description,
  }) {
    final index = _collections.indexOf(collection);
    if (index != -1) {
      final updatedCollection = Collection(
        info: CollectionInfo(
          name: newName,
          description: description ?? collection.info.description,
          schema: collection.info.schema,
          postmanId: collection.info.postmanId,
          exporterId: collection.info.exporterId,
        ),
        item: collection.item,
        variable: collection.variable,
        event: collection.event,
        auth: collection.auth,
      );
      _collections[index] = updatedCollection;
      notifyListeners();
    }
  }

  // Request management methods
  void addRequestToCollection(
    Collection collection,
    String requestName,
    HttpRequest request, {
    String? folderPath,
  }) {
    final index = _collections.indexOf(collection);
    if (index == -1) return;

    final newItem = CollectionItem(name: requestName, request: request);

    if (folderPath != null && folderPath.isNotEmpty) {
      // Add to folder
      final folderNames = folderPath
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList();
      final updatedItems = _addRequestToFolder(
        collection.item,
        folderNames,
        newItem,
      );
      _collections[index] = Collection(
        info: collection.info,
        item: updatedItems,
        variable: collection.variable,
        event: collection.event,
        auth: collection.auth,
      );
    } else {
      // Add to root
      final updatedItems = List<CollectionItem>.from(collection.item)
        ..add(newItem);
      _collections[index] = Collection(
        info: collection.info,
        item: updatedItems,
        variable: collection.variable,
        event: collection.event,
        auth: collection.auth,
      );
    }
    notifyListeners();
  }

  List<CollectionItem> _addRequestToFolder(
    List<CollectionItem> items,
    List<String> folderPath,
    CollectionItem newItem,
  ) {
    if (folderPath.isEmpty) {
      return List<CollectionItem>.from(items)..add(newItem);
    }

    final folderName = folderPath.first;
    final remainingPath = folderPath.sublist(1);

    final updatedItems = <CollectionItem>[];
    bool folderFound = false;

    for (final item in items) {
      if (item.name == folderName && item.request == null) {
        // Found the folder
        folderFound = true;
        final updatedFolder = CollectionItem(
          name: item.name,
          item: _addRequestToFolder(item.item ?? [], remainingPath, newItem),
          description: item.description,
          variable: item.variable,
          event: item.event,
        );
        updatedItems.add(updatedFolder);
      } else {
        updatedItems.add(item);
      }
    }

    if (!folderFound) {
      // Create new folder
      final newFolder = CollectionItem(
        name: folderName,
        item: remainingPath.isEmpty
            ? [newItem]
            : _addRequestToFolder([], remainingPath, newItem),
      );
      updatedItems.add(newFolder);
    }

    return updatedItems;
  }

  /// Update request in collection using RequestPath
  void updateRequestByPath(
    RequestPath path,
    HttpRequest updatedRequest, {
    String? newRequestName,
  }) {
    final collection = getCollectionByIndex(path.collectionIndex);
    if (collection == null) return;

    final updatedItems = _updateRequestByIndices(
      collection.item,
      path.itemIndices,
      updatedRequest,
      newRequestName: newRequestName,
    );

    _collections[path.collectionIndex] = Collection(
      info: collection.info,
      item: updatedItems,
      variable: collection.variable,
      event: collection.event,
      auth: collection.auth,
    );
    notifyListeners();
  }

  /// Update request by indices path
  List<CollectionItem> _updateRequestByIndices(
    List<CollectionItem> items,
    List<int> indices,
    HttpRequest updatedRequest, {
    String? newRequestName,
  }) {
    if (indices.isEmpty) return items;

    final currentIndex = indices[0];
    if (currentIndex < 0 || currentIndex >= items.length) return items;

    final updatedItems = List<CollectionItem>.from(items);

    if (indices.length == 1) {
      // This is the target item
      final currentItem = items[currentIndex];
      if (currentItem.request != null) {
        updatedItems[currentIndex] = CollectionItem(
          name: newRequestName ?? currentItem.name,
          request: updatedRequest,
          response: currentItem.response,
          description: currentItem.description,
          variable: currentItem.variable,
          event: currentItem.event,
        );
      }
    } else {
      // Navigate deeper
      final currentItem = items[currentIndex];
      if (currentItem.item != null) {
        final updatedSubItems = _updateRequestByIndices(
          currentItem.item!,
          indices.sublist(1),
          updatedRequest,
          newRequestName: newRequestName,
        );
        updatedItems[currentIndex] = CollectionItem(
          name: currentItem.name,
          item: updatedSubItems,
          description: currentItem.description,
          variable: currentItem.variable,
          event: currentItem.event,
        );
      }
    }

    return updatedItems;
  }

  /// Delete request from collection using RequestPath
  void deleteRequestByPath(RequestPath path) {
    final collection = getCollectionByIndex(path.collectionIndex);
    if (collection == null) return;

    final updatedItems = _deleteRequestByIndices(
      collection.item,
      path.itemIndices,
    );

    _collections[path.collectionIndex] = Collection(
      info: collection.info,
      item: updatedItems,
      variable: collection.variable,
      event: collection.event,
      auth: collection.auth,
    );

    // Clear selection if this was the selected request
    if (_selectedRequestPath == path) {
      _selectedRequestPath = null;
    }

    notifyListeners();
  }

  /// Delete request by indices path
  List<CollectionItem> _deleteRequestByIndices(
    List<CollectionItem> items,
    List<int> indices,
  ) {
    if (indices.isEmpty) return items;

    final currentIndex = indices[0];
    if (currentIndex < 0 || currentIndex >= items.length) return items;

    final updatedItems = List<CollectionItem>.from(items);

    if (indices.length == 1) {
      // This is the target item - remove it
      updatedItems.removeAt(currentIndex);
    } else {
      // Navigate deeper
      final currentItem = items[currentIndex];
      if (currentItem.item != null) {
        final updatedSubItems = _deleteRequestByIndices(
          currentItem.item!,
          indices.sublist(1),
        );
        // Remove empty folders
        if (updatedSubItems.isEmpty) {
          updatedItems.removeAt(currentIndex);
        } else {
          updatedItems[currentIndex] = CollectionItem(
            name: currentItem.name,
            item: updatedSubItems,
            description: currentItem.description,
            variable: currentItem.variable,
            event: currentItem.event,
          );
        }
      }
    }

    return updatedItems;
  }

  // Folder management methods
  void addFolderToCollection(
    Collection collection,
    String folderName, {
    String? parentFolderPath,
  }) {
    final index = _collections.indexOf(collection);
    if (index == -1) return;

    final newFolder = CollectionItem(name: folderName, item: []);

    if (parentFolderPath != null && parentFolderPath.isNotEmpty) {
      final folderPath = parentFolderPath
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList();
      final updatedItems = _addFolderToFolder(
        collection.item,
        folderPath,
        newFolder,
      );
      _collections[index] = Collection(
        info: collection.info,
        item: updatedItems,
        variable: collection.variable,
        event: collection.event,
        auth: collection.auth,
      );
    } else {
      final updatedItems = List<CollectionItem>.from(collection.item)
        ..add(newFolder);
      _collections[index] = Collection(
        info: collection.info,
        item: updatedItems,
        variable: collection.variable,
        event: collection.event,
        auth: collection.auth,
      );
    }
    notifyListeners();
  }

  List<CollectionItem> _addFolderToFolder(
    List<CollectionItem> items,
    List<String> folderPath,
    CollectionItem newFolder,
  ) {
    if (folderPath.isEmpty) {
      return List<CollectionItem>.from(items)..add(newFolder);
    }

    final folderName = folderPath.first;
    final remainingPath = folderPath.sublist(1);

    final updatedItems = <CollectionItem>[];
    bool folderFound = false;

    for (final item in items) {
      if (item.name == folderName && item.request == null) {
        folderFound = true;
        final updatedFolder = CollectionItem(
          name: item.name,
          item: _addFolderToFolder(item.item ?? [], remainingPath, newFolder),
          description: item.description,
          variable: item.variable,
          event: item.event,
        );
        updatedItems.add(updatedFolder);
      } else {
        updatedItems.add(item);
      }
    }

    if (!folderFound) {
      final newParentFolder = CollectionItem(
        name: folderName,
        item: remainingPath.isEmpty
            ? [newFolder]
            : _addFolderToFolder([], remainingPath, newFolder),
      );
      updatedItems.add(newParentFolder);
    }

    return updatedItems;
  }

  // Helper method to find collection item by path
  CollectionItem? findItemByPath(Collection collection, List<String> path) {
    if (path.isEmpty) return null;

    CollectionItem? current = null;
    List<CollectionItem> items = collection.item;

    for (final segment in path) {
      current = items.firstWhere(
        (item) => item.name == segment,
        orElse: () => throw StateError('Item not found'),
      );
      items = current.item ?? [];
    }

    return current;
  }
}
