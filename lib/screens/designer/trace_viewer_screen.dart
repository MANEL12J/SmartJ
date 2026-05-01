import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class TraceViewerScreen extends StatefulWidget {
  final Map<String, dynamic> traceData;
  final String showName;

  const TraceViewerScreen({
    super.key,
    required this.traceData,
    required this.showName,
  });

  @override
  State<TraceViewerScreen> createState() => _TraceViewerScreenState();
}

class _TraceViewerScreenState extends State<TraceViewerScreen> {
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
        // Pour les PDF, on pourrait utiliser un package de visualisation PDF
        // Pour l'instant, on affiche juste les informations
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
      final fileName = widget.traceData['fileName'] as String? ?? 'tracé';
      final extension = widget.traceData['extension'] as String? ?? 'pdf';

      // Copier dans le presse-papiers pour le moment
      // Dans une vraie app, on utiliserait un package de téléchargement
      await Clipboard.setData(ClipboardData(text: base64String));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Tracé copié dans le presse-papiers (${fileName}.$extension)'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracé - ${widget.showName}'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadTrace,
            tooltip: 'Copier le tracé',
          ),
        ],
      ),
      body: _isLoading
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
