import 'package:flutter/material.dart';
import 'package:ababil_flutter/ui/viewmodels/collections_view_model.dart';
import 'package:ababil_flutter/ui/viewmodels/home_view_model.dart';
import 'package:ababil_flutter/ui/widgets/import_export_dialog.dart';
import 'package:ababil_flutter/ui/widgets/collection_dialogs.dart';
import 'package:ababil_flutter/domain/models/collection.dart';
import 'package:ababil_flutter/domain/models/http_request.dart';
import 'package:ababil_flutter/domain/models/request_path.dart';

class Sidebar extends StatefulWidget {
  final CollectionsViewModel collectionsViewModel;
  final HomeViewModel homeViewModel;

  const Sidebar({
    super.key,
    required this.collectionsViewModel,
    required this.homeViewModel,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedNavIndex =
      0; // 0=Collections, 1=Environments, 2=History, 3=Flows

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Narrow icon-only navigation sidebar
          Container(
            width: 48,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.grey.shade100,
            child: Column(
              children: [
                // My Workspace header (compact)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF3D3D3D)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: const Icon(Icons.lock_outline, size: 18),
                ),
                // Navigation icons
                Expanded(
                  child: Column(
                    children: [
                      _NavIcon(
                        icon: Icons.folder_outlined,
                        isSelected: _selectedNavIndex == 0,
                        onTap: () => setState(() => _selectedNavIndex = 0),
                        tooltip: 'Collections',
                      ),
                      _NavIcon(
                        icon: Icons.square_outlined,
                        isSelected: _selectedNavIndex == 1,
                        onTap: () => setState(() => _selectedNavIndex = 1),
                        tooltip: 'Environments',
                      ),
                      _NavIcon(
                        icon: Icons.history,
                        isSelected: _selectedNavIndex == 2,
                        onTap: () => setState(() => _selectedNavIndex = 2),
                        tooltip: 'History',
                      ),
                      _NavIcon(
                        icon: Icons.account_tree_outlined,
                        isSelected: _selectedNavIndex == 3,
                        onTap: () => setState(() => _selectedNavIndex = 3),
                        tooltip: 'Flows',
                      ),
                    ],
                  ),
                ),
                // Bottom icon
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF3D3D3D)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.apps, size: 20),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'More options',
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Header with workspace name
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF3D3D3D)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'My Workspace',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content view
                Expanded(child: _buildContentArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_selectedNavIndex) {
      case 0: // Collections
        return _CollectionsView(
          collectionsViewModel: widget.collectionsViewModel,
          homeViewModel: widget.homeViewModel,
        );
      case 1: // Environments
        return _EnvironmentsView(
          collectionsViewModel: widget.collectionsViewModel,
        );
      case 2: // History
        return const Center(child: Text('History - Coming soon'));
      case 3: // Flows
        return const Center(child: Text('Flows - Coming soon'));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}

class _CollectionsView extends StatelessWidget {
  final CollectionsViewModel collectionsViewModel;
  final HomeViewModel homeViewModel;

  const _CollectionsView({
    required this.collectionsViewModel,
    required this.homeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: collectionsViewModel,
      builder: (context, _) {
        return Column(
          children: [
            // Add and search
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.add, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'New Collection',
                    onSelected: (value) {
                      if (value == 'new') {
                        CollectionDialogs.showCreateCollectionDialog(
                          context,
                          collectionsViewModel,
                        );
                      } else if (value == 'import') {
                        ImportExportDialog.showImportCollectionDialog(
                          context,
                          collectionsViewModel,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'new',
                        child: Text('New Collection'),
                      ),
                      const PopupMenuItem(
                        value: 'import',
                        child: Text('Import Collection'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search collections',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF3D3D3D)
                                : Colors.grey.shade300,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardTheme.color,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Collections list
            Expanded(
              child: collectionsViewModel.collections.isEmpty
                  ? Center(
                      child: Text(
                        'No collections\nClick + to create or import',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: collectionsViewModel.collections
                          .map(
                            (collection) => _CollectionItem(
                              collection: collection,
                              collectionsViewModel: collectionsViewModel,
                              homeViewModel: homeViewModel,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CollectionItem extends StatefulWidget {
  final Collection collection;
  final CollectionsViewModel collectionsViewModel;
  final HomeViewModel homeViewModel;

  const _CollectionItem({
    required this.collection,
    required this.collectionsViewModel,
    required this.homeViewModel,
  });

  @override
  State<_CollectionItem> createState() => _CollectionItemState();
}

class _CollectionItemState extends State<_CollectionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.collection.info.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) async {
                    if (value == 'add_request') {
                      await CollectionDialogs.showAddRequestDialog(
                        context,
                        widget.collectionsViewModel,
                        widget.homeViewModel,
                        widget.collection,
                      );
                    } else if (value == 'add_folder') {
                      await CollectionDialogs.showAddFolderDialog(
                        context,
                        widget.collectionsViewModel,
                        widget.collection,
                      );
                    } else if (value == 'edit') {
                      await CollectionDialogs.showEditCollectionDialog(
                        context,
                        widget.collectionsViewModel,
                        widget.collection,
                      );
                    } else if (value == 'export') {
                      ImportExportDialog.showExportCollectionDialog(
                        context,
                        widget.collectionsViewModel,
                        widget.collection,
                      );
                    } else if (value == 'delete') {
                      widget.collectionsViewModel.removeCollection(
                        widget.collection,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_request',
                      child: Text('Add Request'),
                    ),
                    const PopupMenuItem(
                      value: 'add_folder',
                      child: Text('Add Folder'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'export', child: Text('Export')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ..._buildRequestItems(widget.collection.item),
      ],
    );
  }

  List<Widget> _buildRequestItems(
    List<CollectionItem> items, {
    List<int> itemIndices = const [],
  }) {
    final widgets = <Widget>[];
    final collectionIndex = widget.collectionsViewModel.collections.indexOf(
      widget.collection,
    );

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final currentIndices = [...itemIndices, i];

      if (item.request != null) {
        // This is a request item
        final requestPath = RequestPath(
          collectionIndex: collectionIndex,
          itemIndices: currentIndices,
        );

        widgets.add(
          _RequestItem(
            collectionName: widget.collection.info.name,
            requestName: item.name,
            request: item.request!,
            requestPath: requestPath,
            isSelected:
                widget.collectionsViewModel.selectedRequestPath == requestPath,
            onTap: () {
              widget.collectionsViewModel.selectRequest(requestPath);
              // Set collections view model if not already set
              widget.homeViewModel.setCollectionsViewModel(
                widget.collectionsViewModel,
              );
              widget.homeViewModel.loadFromPostmanRequest(
                item.request!,
                requestPath: requestPath,
              );
            },
            collectionsViewModel: widget.collectionsViewModel,
            homeViewModel: widget.homeViewModel,
            collection: widget.collection,
          ),
        );
      }
      if (item.item != null) {
        // Handle nested folders - pass indices
        widgets.addAll(
          _buildRequestItems(item.item!, itemIndices: currentIndices),
        );
      }
    }
    return widgets;
  }
}

class _RequestItem extends StatelessWidget {
  final String collectionName;
  final String requestName;
  final HttpRequest request;
  final RequestPath requestPath;
  final bool isSelected;
  final VoidCallback onTap;
  final CollectionsViewModel? collectionsViewModel;
  final HomeViewModel? homeViewModel;
  final Collection? collection;

  const _RequestItem({
    required this.collectionName,
    required this.requestName,
    required this.request,
    required this.requestPath,
    required this.isSelected,
    required this.onTap,
    this.collectionsViewModel,
    this.homeViewModel,
    this.collection,
  });

  Color _getMethodColor() {
    final method = request.method?.toUpperCase() ?? 'GET';
    switch (method) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.amber;
      case 'PUT':
        return Colors.blue;
      case 'PATCH':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4, right: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              request.method ?? 'GET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getMethodColor(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                requestName,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (collectionsViewModel != null &&
                homeViewModel != null &&
                collection != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 14),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (value) async {
                  if (value == 'edit') {
                    await CollectionDialogs.showEditRequestDialog(
                      context,
                      collectionsViewModel!,
                      homeViewModel!,
                      collection!,
                      requestName,
                      request,
                      requestPath: requestPath,
                    );
                  } else if (value == 'delete') {
                    final confirmed =
                        await CollectionDialogs.showDeleteRequestDialog(
                          context,
                          requestName,
                        );
                    if (confirmed && context.mounted) {
                      collectionsViewModel!.deleteRequestByPath(requestPath);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentsView extends StatelessWidget {
  final CollectionsViewModel collectionsViewModel;

  const _EnvironmentsView({required this.collectionsViewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: collectionsViewModel,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.add, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Import Environment',
                    onSelected: (value) {
                      if (value == 'import') {
                        ImportExportDialog.showImportEnvironmentDialog(
                          context,
                          collectionsViewModel,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'import',
                        child: Text('Import Environment'),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: collectionsViewModel.environments.isEmpty
                  ? Center(
                      child: Text(
                        'No environments\nClick + to import',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: collectionsViewModel.environments
                          .map(
                            (env) => ListTile(
                              title: Text(env.name),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'export') {
                                    ImportExportDialog.showExportEnvironmentDialog(
                                      context,
                                      collectionsViewModel,
                                      env,
                                    );
                                  } else if (value == 'delete') {
                                    collectionsViewModel.removeEnvironment(env);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'export',
                                    child: Text('Export'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
