import 'package:flutter/material.dart';

import '../../../../core/tokens.dart';
import '../../../listings/domain/entities/listing.dart';

class EditListingResult {
  final String title;
  final int price;
  const EditListingResult(this.title, this.price);
}

class EditListingDialog extends StatefulWidget {
  final Listing listing;
  const EditListingDialog({super.key, required this.listing});
  @override
  State<EditListingDialog> createState() => _EditListingDialogState();
}

/// StatefulWidget only to own and dispose the controllers and form key.
class _EditListingDialogState extends State<EditListingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.listing.title);
  late final _price =
      TextEditingController(text: widget.listing.price.toString());

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context,
        EditListingResult(_title.text.trim(), int.parse(_price.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: C.white,
      title: const Text('Edit listing', style: T.h1),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price (RWF)'),
            validator: (v) => (int.tryParse(v?.trim() ?? '') ?? 0) <= 0
                ? 'Enter a price in RWF'
                : null,
          ),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
