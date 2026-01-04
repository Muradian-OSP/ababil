import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:ababil_flutter/ui/viewmodels/collections_view_model.dart';
import 'package:ababil_flutter/domain/models/collection.dart';
import 'package:ababil_flutter/domain/models/environment.dart';

class ImportExportDialog {
  static Future<void> showImportCollectionDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        final success = await viewModel.importCollection(jsonString);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Collection imported successfully'
                    : 'Failed to import collection',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing collection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> showExportCollectionDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
    Collection collection,
  ) async {
    try {
      final jsonString = await viewModel.exportCollection(collection);
      if (jsonString != null) {
        final directory = await FilePicker.platform.getDirectoryPath();
        if (directory != null) {
          final file = File('$directory/${collection.info.name}.json');
          await file.writeAsString(jsonString);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Collection exported successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to export collection'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting collection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> showImportEnvironmentDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        final success = await viewModel.importEnvironment(jsonString);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Environment imported successfully'
                    : 'Failed to import environment',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing environment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> showExportEnvironmentDialog(
    BuildContext context,
    CollectionsViewModel viewModel,
    Environment environment,
  ) async {
    try {
      final jsonString = await viewModel.exportEnvironment(environment);
      if (jsonString != null) {
        final directory = await FilePicker.platform.getDirectoryPath();
        if (directory != null) {
          final file = File('$directory/${environment.name}.json');
          await file.writeAsString(jsonString);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Environment exported successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to export environment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting environment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
