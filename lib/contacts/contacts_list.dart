import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contacts_model.dart';
import 'contacts_entry.dart';

/// UI for displaying all contacts in a list with swipe-to-delete and edit.
class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactsModel>(
      builder: (context, model, child) {
        if (model.entityList.isEmpty) {
          return const Center(child: Text("No contacts yet. Tap the + button to add a note."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: model.entityList.length,
          itemBuilder: (context, index) {
            final contact = model.entityList[index];
            return Dismissible(
              key: Key('contact-${contact.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                model.delete(contact.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Contact deleted")),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(contact.name),
                  subtitle: Text("${contact.email}\n${contact.phone}"),
                  isThreeLine: true,
                  onTap: () {
                    model.setEntityBeingEdited(contact);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactsEntry()),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}