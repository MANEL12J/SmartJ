import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';

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
  List<List<String>> _excelData = [];

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
      _fileBytes = bytes;

      // Parse Excel file
      if (_extension == 'xlsx' || _extension == 'xls') {
        _excelData = await _parseExcelFile(bytes);
      } else if (_extension == 'csv') {
        _excelData = _parseCSVFile(bytes);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement du fichier: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<List<String>>> _parseExcelFile(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final List<List<String>> data = [];

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet != null) {
          for (final row in sheet.rows) {
            final List<String> rowData = [];
            for (final cell in row) {
              rowData.add(cell?.value?.toString() ?? '');
            }
            if (rowData.any((cell) => cell.isNotEmpty)) {
              data.add(rowData);
            }
          }
          break; // Only read first sheet
        }
      }
      return data;
    } catch (e) {
      print('Error parsing Excel: $e');
      return [['Erreur lors du parsing du fichier Excel']];
    }
  }

  List<List<String>> _parseCSVFile(Uint8List bytes) {
    try {
      final String content = utf8.decode(bytes);
      final List<List<String>> data = [];
      final lines = content.split('\n');

      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          final cells = line.split(',');
          data.add(cells);
        }
      }
      return data;
    } catch (e) {
      print('Error parsing CSV: $e');
      return [['Erreur lors du parsing du fichier CSV']];
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
                child: Padding(
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
        // File info header
        Row(
          children: [
            Icon(
              _getFileIcon(),
              size: 24,
              color: _getFileColor(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _fileName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Uploadé le ${_getUploadDate()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Excel data table
        Expanded(
          child: _excelData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.orange[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune donnée trouvée dans le fichier',
                        style: TextStyle(fontSize: 16, color: Colors.orange[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: _buildDataTable(),
                ),
        ),
        const SizedBox(height: 16),
        // Action buttons
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

  Widget _buildDataTable() {
    if (_excelData.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: _excelData[0].map((header) {
              return DataColumn(
                label: Text(
                  header,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            rows: _excelData.skip(1).map((row) {
              return DataRow(
                cells: row.map((cell) {
                  return DataCell(
                    Text(cell),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
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
