import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RawAutoComplete extends StatefulWidget {
  RawAutoComplete({
    super.key,
    required this.listData,
    required this.onSelected,
  });

  var listData = <String>[];
  final FormFieldSetter<String> onSelected;

  @override
  // ignore: library_private_types_in_public_api
  _RawAutoCompleteState createState() => _RawAutoCompleteState();
}

class _RawAutoCompleteState extends State<RawAutoComplete> {
  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        List myData = widget.listData;
        myData.sort((a, b) => a.compareTo(b));
        // print(widget.listData);
        // print(myData);
        return widget.listData.where((String option) {
          return option.contains(textEditingValue.text.toUpperCase());
        });
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          // autofocus: true,
          textAlign: TextAlign.center,
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: '',
          ),
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          validator: (String? value) {
            if (!widget.listData.contains(value)) {
              return 'Nothing selected.';
            }
            return null;
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              width: 230,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Center(child: Text(option)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
