import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
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
  List<List<String>> _excelData = [];
  bool _showTableView = true;

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
      
      // Parser les données Excel
      List<List<String>> excelData = [];
      if (_extension == 'csv') {
        excelData = _parseCSV(bytes);
      } else {
        excelData = _parseExcel(bytes);
      }
      
      setState(() {
        _fileBytes = bytes;
        _excelData = excelData;
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
                    if (_excelData.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showTableView = !_showTableView;
                          });
                        },
                        icon: Icon(
                          _showTableView ? Icons.info_outline : Icons.table_chart,
                          color: Colors.white,
                        ),
                        tooltip: _showTableView ? 'Voir les infos du fichier' : 'Voir le tableau',
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
    if (_showTableView && _excelData.isNotEmpty) {
      return _buildTableView();
    }
    
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

  // Parser CSV
  List<List<String>> _parseCSV(Uint8List bytes) {
    final rows = <List<String>>[];
    final content = utf8.decode(bytes);
    final lines = content.split('\n');
    for (var line in lines) {
      final row = line.split(',').map((e) => e.trim()).toList();
      if (row.any((e) => e.isNotEmpty)) {
        rows.add(row);
      }
    }
    return rows;
  }

  // Parser Excel (réutilise la logique de FirebaseService)
  List<List<String>> _parseExcel(Uint8List bytes) {
    final rows = <List<String>>[];
    try {
      final excel = excel_lib.Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;
        for (var row in sheet.rows) {
          final rowData = row.map((cell) => cell?.value?.toString() ?? '').toList();
          if (rowData.any((e) => e.isNotEmpty)) {
            rows.add(rowData);
          }
        }
        break; // Only use first sheet
      }
    } catch (e) {
      print('Excel parsing error: $e');
      // Fallback: try manual parsing
      try {
        return _parseXlsxManually(bytes);
      } catch (manualError) {
        print('Manual parsing also failed: $manualError');
      }
    }
    return rows;
  }

  // Parser Xlsx manuellement (similaire à FirebaseService)
  List<List<String>> _parseXlsxManually(Uint8List bytes) {
    final rows = <List<String>>[];
    
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Find shared strings
      final sharedStrings = <String>[];
      for (var file in archive.files) {
        if (file.name.toLowerCase() == 'xl/sharedstrings.xml') {
          final content = String.fromCharCodes(file.content as List<int>);
          final doc = XmlDocument.parse(content);
          final siElements = doc.findAllElements('si');
          for (var si in siElements) {
            final tElements = si.findAllElements('t');
            final text = tElements.map((t) => t.innerText).join('');
            sharedStrings.add(text);
          }
          break;
        }
      }

      // Find and parse sheet
      String sheetPath = '';
      for (var file in archive.files) {
        final name = file.name.toLowerCase();
        if (name.startsWith('xl/worksheets/sheet') && name.endsWith('.xml')) {
          sheetPath = file.name;
          break;
        }
      }

      if (sheetPath.isEmpty) return rows;

      final sheetFile = archive.files.firstWhere((f) => f.name == sheetPath);
      final sheetContent = String.fromCharCodes(sheetFile.content as List<int>);
      final sheetDoc = XmlDocument.parse(sheetContent);

      final rowElements = sheetDoc.findAllElements('row');
      final sortedRows = rowElements.toList()
        ..sort((a, b) {
          final rowA = int.tryParse(a.getAttribute('r') ?? '0') ?? 0;
          final rowB = int.tryParse(b.getAttribute('r') ?? '0') ?? 0;
          return rowA.compareTo(rowB);
        });

      for (var rowElem in sortedRows) {
        final rowData = <String>[];
        final cellElements = rowElem.findAllElements('c');

        for (var cellElem in cellElements) {
          final ref = cellElem.getAttribute('r') ?? '';
          int colIndex = _colFromRef(ref);

          while (rowData.length < colIndex) {
            rowData.add('');
          }

          final type = cellElem.getAttribute('t');
          String value = '';

          if (type == 's') {
            final vElem = cellElem.findElements('v').firstOrNull;
            if (vElem != null) {
              final idx = int.tryParse(vElem.innerText) ?? -1;
              if (idx >= 0 && idx < sharedStrings.length) {
                value = sharedStrings[idx];
              }
            }
          } else {
            final vElem = cellElem.findElements('v').firstOrNull;
            if (vElem != null) {
              value = vElem.innerText;
            } else {
              final isElem = cellElem.findElements('is').firstOrNull;
              if (isElem != null) {
                final tElem = isElem.findElements('t').firstOrNull;
                if (tElem != null) {
                  value = tElem.innerText;
                }
              }
            }
          }

          if (rowData.length == colIndex) {
            rowData.add(value);
          } else if (colIndex < rowData.length) {
            rowData[colIndex] = value;
          }
        }

        if (rowData.any((e) => e.isNotEmpty)) {
          rows.add(rowData);
        }
      }
    } catch (e) {
      print('Manual XLSX parsing error: $e');
    }
    
    return rows;
  }

  // Convertir référence de colonne en index
  int _colFromRef(String ref) {
    final letters = ref.replaceAll(RegExp(r'[0-9]'), '');
    int col = 0;
    for (int i = 0; i < letters.length; i++) {
      col = col * 26 + (letters.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1);
    }
    return col - 1;
  }

  // Construire le tableau de données Excel
  Widget _buildTableView() {
    if (_excelData.isEmpty) {
      return const Center(
        child: Text('Aucune donnée à afficher'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du tableau
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
              const Icon(Icons.table_chart, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Contenu du fichier Excel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_excelData.length} lignes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Contenu du tableau
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                dataRowHeight: 40,
                columnSpacing: 16,
                columns: _buildTableColumns(),
                rows: _buildTableRows(),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Boutons d'action
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _copyBase64,
              icon: const Icon(Icons.copy),
              label: const Text('Copier le fichier'),
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

  // Construire les colonnes du tableau
  List<DataColumn> _buildTableColumns() {
    if (_excelData.isEmpty) return [];
    
    final headerRow = _excelData[0];
    return List.generate(
      headerRow.length > 10 ? 10 : headerRow.length, // Limiter à 10 colonnes pour la lisibilité
      (index) => DataColumn(
        label: SizedBox(
          width: 120,
          child: Text(
            headerRow[index].isEmpty ? 'Colonne ${index + 1}' : headerRow[index],
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // Construire les lignes du tableau
  List<DataRow> _buildTableRows() {
    if (_excelData.length <= 1) return [];
    
    final dataRows = _excelData.sublist(1); // Exclure l'en-tête
    final maxColumns = _excelData[0].length > 10 ? 10 : _excelData[0].length;
    
    return List.generate(
      dataRows.length > 50 ? 50 : dataRows.length, // Limiter à 50 lignes pour la performance
      (index) {
        final row = dataRows[index];
        final cells = List.generate(
          maxColumns,
          (colIndex) => colIndex < row.length ? row[colIndex] : '',
        );
        
        return DataRow(
          color: WidgetStateProperty.all(
            index % 2 == 0 ? Colors.white : Colors.grey[50],
          ),
          cells: cells.map((cell) => DataCell(
            SizedBox(
              width: 120,
              child: Text(
                cell.isEmpty ? '-' : cell,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}
