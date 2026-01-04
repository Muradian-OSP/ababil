/// Represents a path to a request item in a collection using indices
/// Format: "collectionIndex/itemIndex/itemIndex/..."
/// This ensures unique identification even when names are duplicated
class RequestPath {
  final int collectionIndex;
  final List<int> itemIndices;

  RequestPath({required this.collectionIndex, required this.itemIndices});

  /// Parse from string format: "collectionIndex/itemIndex/itemIndex/..."
  factory RequestPath.fromString(String pathString) {
    final parts = pathString.split('/');
    if (parts.isEmpty) {
      throw ArgumentError('Invalid path string: $pathString');
    }

    final collectionIndex = int.parse(parts[0]);
    final itemIndices = parts.length > 1
        ? parts.sublist(1).map((p) => int.parse(p)).toList()
        : <int>[];

    return RequestPath(
      collectionIndex: collectionIndex,
      itemIndices: itemIndices,
    );
  }

  /// Convert to string format
  @override
  String toString() {
    final parts = [
      collectionIndex.toString(),
      ...itemIndices.map((i) => i.toString()),
    ];
    return parts.join('/');
  }

  /// Get the parent path (one level up)
  RequestPath? get parent {
    if (itemIndices.isEmpty) return null;
    return RequestPath(
      collectionIndex: collectionIndex,
      itemIndices: itemIndices.sublist(0, itemIndices.length - 1),
    );
  }

  /// Get the folder path as a string (for display purposes)
  String get folderPath {
    return itemIndices.isEmpty ? '' : itemIndices.join('/');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestPath &&
          runtimeType == other.runtimeType &&
          collectionIndex == other.collectionIndex &&
          _listEquals(itemIndices, other.itemIndices);

  @override
  int get hashCode => collectionIndex.hashCode ^ itemIndices.hashCode;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
