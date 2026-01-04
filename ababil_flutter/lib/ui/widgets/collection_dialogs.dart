import 'package:flutter/material.dart';
import 'package:ababil_flutter/domain/models/collection.dart';
import 'package:ababil_flutter/domain/models/http_request.dart';
import 'package:ababil_flutter/domain/models/request_url.dart';
import 'package:ababil_flutter/domain/models/request_path.dart';
import 'package:ababil_flutter/ui/viewmodels/collections_view_model.dart';
import 'package:ababil_flutter/ui/viewmodels/home_view_model.dart';

class CollectionDialogs {
  static Future<void> showCreateCollectionDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
  ) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                hintText: 'Enter collection name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      viewModel.createCollection(
        nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );
    }
  }

  static Future<void> showEditCollectionDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
    Collection collection,
  ) async {
    final nameController = TextEditingController(text: collection.info.name);
    final descriptionController = TextEditingController(
      text: collection.info.description ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      viewModel.updateCollection(
        collection,
        nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );
    }
  }

  static Future<void> showAddRequestDialog(
    BuildContext context,
    CollectionsViewModel collectionsViewModel,
    HomeViewModel homeViewModel,
    Collection collection, {
    String? folderPath,
  }) async {
    final nameController = TextEditingController();
    final methodController = TextEditingController(text: 'GET');
    final urlController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Request Name',
                  hintText: 'Enter request name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: methodController,
                decoration: const InputDecoration(
                  labelText: 'Method',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://api.example.com/endpoint',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  urlController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true &&
        nameController.text.trim().isNotEmpty &&
        urlController.text.trim().isNotEmpty) {
      final request = HttpRequest(
        method: methodController.text.trim().toUpperCase(),
        url: RequestUrl(raw: urlController.text.trim()),
      );

      collectionsViewModel.addRequestToCollection(
        collection,
        nameController.text.trim(),
        request,
        folderPath: folderPath,
      );
    }
  }

  static Future<void> showEditRequestDialog(
    BuildContext context,
    CollectionsViewModel collectionsViewModel,
    HomeViewModel homeViewModel,
    Collection collection,
    String requestName,
    HttpRequest request, {
    RequestPath? requestPath,
  }) async {
    final nameController = TextEditingController(text: requestName);
    final methodController = TextEditingController(
      text: request.method ?? 'GET',
    );
    final urlController = TextEditingController(text: request.url?.raw ?? '');
    final descriptionController = TextEditingController(
      text: request.description ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Request Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: methodController,
                decoration: const InputDecoration(
                  labelText: 'Method',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  urlController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true &&
        nameController.text.trim().isNotEmpty &&
        urlController.text.trim().isNotEmpty &&
        requestPath != null) {
      final updatedRequest = HttpRequest(
        method: methodController.text.trim().toUpperCase(),
        url: RequestUrl(raw: urlController.text.trim()),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        header: request.header,
        body: request.body,
        auth: request.auth,
      );

      collectionsViewModel.updateRequestByPath(
        requestPath,
        updatedRequest,
        newRequestName: nameController.text.trim(),
      );
    }
  }

  static Future<void> showAddFolderDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
    Collection collection, {
    String? parentFolderPath,
  }) async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'Enter folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      viewModel.addFolderToCollection(
        collection,
        nameController.text.trim(),
        parentFolderPath: parentFolderPath,
      );
    }
  }

  static Future<bool> showDeleteRequestDialog(
    BuildContext context,
    String requestName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text('Are you sure you want to delete "$requestName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
