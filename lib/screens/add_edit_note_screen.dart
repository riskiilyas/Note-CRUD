import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({this.note});

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final NoteService _noteService = NoteService();
  bool _isLoading = false;
  String _errorMessage = '';
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Judul tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isEditing) {
        await _noteService.updateNote(
          widget.note!.id,
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      } else {
        await _noteService.addNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                hintText: 'Judul',
                maxLines: 1,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.0),
              CustomTextField(
                controller: _contentController,
                hintText: 'Isi catatan...',
                maxLines: 10,
                minLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 8.0),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 16.0),
              CustomButton(
                text: _isEditing ? 'Simpan Perubahan' : 'Simpan',
                isLoading: _isLoading,
                onPressed: _saveNote,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}