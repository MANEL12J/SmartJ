import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class EventTraceViewerDialog extends StatefulWidget {
  final Map<String, dynamic> traceData;
  final String eventName;

  const EventTraceViewerDialog({
    super.key,
    required this.traceData,
    required this.eventName,
  });

  @override
  State<EventTraceViewerDialog> createState() => _EventTraceViewerDialogState();
}

class _EventTraceViewerDialogState extends State<EventTraceViewerDialog> {
  bool _isLoading = true;
  Uint8List? _imageBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrace();
  }

  Future<void> _loadTrace() async {
    try {
      final base64String = widget.traceData['data'] as String;
      final extension = widget.traceData['extension'] as String? ?? 'pdf';
      
      if (extension == 'pdf') {
        // Pour les PDF, on affiche juste les informations
        setState(() {
          _isLoading = false;
        });
      } else {
        // Pour les images (jpg, jpeg, png)
        final bytes = base64Decode(base64String);
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement du tracé: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadTrace() async {
    try {
      final base64String = widget.traceData['data'] as String;
      final fileName = widget.traceData['fileName'] ?? 'tracé';
      final extension = widget.traceData['extension'] as String? ?? 'pdf';
      
      // Copier dans le presse-papiers pour le moment
      await Clipboard.setData(ClipboardData(text: base64String));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tracé copié dans le presse-papiers (${fileName}.$extension)'),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tracé - ${widget.eventName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _downloadTrace,
                      icon: const Icon(Icons.download, color: Colors.white),
                      tooltip: 'Copier le tracé',
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
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final extension = widget.traceData['extension'] as String? ?? 'pdf';
    
    if (extension == 'pdf') {
      return _buildPdfViewer();
    } else {
      return _buildImageViewer();
    }
  }

  Widget _buildPdfViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.red[600],
          ),
          const SizedBox(height: 16),
          Text(
            widget.traceData['fileName'] ?? 'tracé.pdf',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Document PDF (${(widget.traceData['data'] as String).length ~/ 1000}KB)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _downloadTrace,
            icon: const Icon(Icons.copy),
            label: const Text('Copier dans le presse-papiers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    if (_imageBytes == null) {
      return const Center(
        child: Text('Image non disponible'),
      );
    }

    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4,
      child: Center(
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
