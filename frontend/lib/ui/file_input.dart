import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '/ui/snackbar.dart';

class FileInputButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final FileType fileType;
  final List<String>? fileExtensions;
  final Function(PlatformFile) onFileSelected;

  const FileInputButton({
    super.key,
    required this.label,
    this.subLabel,
    required this.fileType,
    this.fileExtensions,
    required this.onFileSelected,
  });

  @override
  State<FileInputButton> createState() => _FileInputButtonState();
}

class _FileInputButtonState extends State<FileInputButton> {
  PlatformFile? _file;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: widget.fileType,
      allowedExtensions:
          widget.fileType == FileType.custom ? widget.fileExtensions : null,
    );
    if (!mounted) return;

    if (result == null) {
      errorSnack(context, 'No file selected');
      return;
    }
    List<PlatformFile> files = result.files;
    if (files.isEmpty) {
      errorSnack(context, 'No file selected');
      return;
    }
    setState(() {
      _file = files.first;
    });
    widget.onFileSelected(_file!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: MaterialButton(
        child: Column(
          children: [
            const Icon(Icons.file_upload, size: 48),
            const SizedBox(height: 16),
            Text(widget.label, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (widget.subLabel != null)
              Text(
                widget.subLabel!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (widget.subLabel != null) const SizedBox(height: 16),
          ],
        ),
        onPressed: () {
          _pickFile();
        },
      ),
    );
  }
}
