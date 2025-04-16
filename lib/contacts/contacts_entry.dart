import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contacts_model.dart';
import 'contact.dart';
import 'contacts_db_worker.dart';

/// UI for adding or editing a contact.
class ContactsEntry extends StatefulWidget {
  const ContactsEntry({super.key});

  @override
  State<ContactsEntry> createState() => _ContactsEntryState();
}

class _ContactsEntryState extends State<ContactsEntry> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  int? _loadedContactId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ContactsModel>(context);
    final contact = model.entityBeingEdited;

    // Reload controllers only when a new contact is loaded
    if (contact != null && contact.id != _loadedContactId) {
      _nameController.text = contact.name;
      _emailController.text = contact.email;
      _phoneController.text = contact.phone;
      _notesController.text = contact.notes;
      _loadedContactId = contact.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Contact Entry")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, "Name"),
            _buildTextField(_emailController, "Email"),
            _buildTextField(_phoneController, "Phone"),
            _buildTextField(_notesController, "Notes", maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _saveContact(model),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: hint),
        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required field' : null,
      ),
    );
  }

  Future<void> _saveContact(ContactsModel model) async {
    if (!_formKey.currentState!.validate()) return;

    final existing = model.entityBeingEdited;

    final contact = Contact(
      id: existing?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (contact.id == null) {
      await ContactsDBWorker.db.create(contact);
    } else {
      await ContactsDBWorker.db.update(contact);
    }

    await model.loadData("contacts", ContactsDBWorker.db);
    model.setStackIndex(0);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact saved"), backgroundColor: Colors.green),
      );
    }
  }
}