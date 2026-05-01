import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class EngagesListViewerDialog extends StatefulWidget {
  final Map<String, dynamic> engagesData;
  final String eventName;

  const EngagesListViewerDialog({
    super.key,
    required this.engagesData,
    required this.eventName,
  });

  @override
  State<EngagesListViewerDialog> createState() =>
      _EngagesListViewerDialogState();
}

class _EngagesListViewerDialogState extends State<EngagesListViewerDialog> {
  bool _isLoading = true;
  Uint8List? _fileBytes;
  String? _error;
  String _extension = 'xlsx';
  String _fileName = '';

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final base64String = widget.engagesData['data'] as String;
      _extension = widget.engagesData['extension'] as String? ?? 'xlsx';
      _fileName = widget.engagesData['fileName'] ?? 'liste_engages.$_extension';

      final bytes = base64Decode(base64String);
      setState(() {
        _fileBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement du fichier: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _copyBase64() async {
    try {
      final base64String = widget.engagesData['data'] as String;
      await Clipboard.setData(ClipboardData(text: base64String));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fichier copié dans le presse-papiers ($_fileName)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la copie: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon() {
    switch (_extension) {
      case 'xlsx':
      case 'xls':
        return Icons.table_chart;
      case 'csv':
        return Icons.table_rows;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (_extension) {
      case 'xlsx':
      case 'xls':
        return Colors.green[700]!;
      case 'csv':
        return Colors.blue[700]!;
      case 'pdf':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getFileSize() {
    if (_fileBytes == null) return '0 KB';
    final sizeInKB = _fileBytes!.length / 1024;
    if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    }
    return '${(sizeInKB / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Liste des engagés - ${widget.eventName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyBase64,
                      icon: const Icon(Icons.download, color: Colors.white),
                      tooltip: 'Copier le fichier',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Fermer',
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 64, color: Colors.red[400]),
                                  const SizedBox(height: 16),
                                  Text(_error!,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.red[600]),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          : _buildFileInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getFileIcon(),
          size: 80,
          color: _getFileColor(),
        ),
        const SizedBox(height: 20),
        Text(
          _fileName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Taille: ${_getFileSize()} | Format: ${_extension.toUpperCase()}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Uploadé le ${_getUploadDate()}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _copyBase64,
              icon: const Icon(Icons.copy),
              label: const Text('Copier dans le presse-papiers'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getUploadDate() {
    try {
      final timestamp = widget.engagesData['uploadedAt'];
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return 'Date inconnue';
    } catch (e) {
      return 'Date inconnue';
    }
  }
}
