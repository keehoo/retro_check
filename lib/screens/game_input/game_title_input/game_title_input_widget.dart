import 'package:flutter/material.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';
import 'package:untitled/utils/typedefs/typedefs.dart';

class GameTitleInputWidget extends StatelessWidget {
  final StringCallback onTitleFinishedEditing;
  final TextEditingController textEditingController;

  const GameTitleInputWidget(
      {super.key,
        required this.onTitleFinishedEditing,
        required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Please type in the title of the item you'd like to add",
                style: context.textStyle.titleLarge),
            const SizedBox(height: 24),
            TextFormField(
              style: context.textStyle.bodySmall,
              controller: textEditingController,
              onChanged: (text) {
                Lgr.log("User has typed in the game title: $text");
              },
              onFieldSubmitted: (a) {
                Lgr.log("On field submitted $a");
                FocusManager.instance.primaryFocus?.unfocus();
                onTitleFinishedEditing(textEditingController.text);
              },
              onEditingComplete: () {
                Lgr.log("On editing complete.");
                FocusManager.instance.primaryFocus?.unfocus();
                onTitleFinishedEditing(textEditingController.text);
              },
              onSaved: (String? a) {
                Lgr.log("On saved $a");
                FocusManager.instance.primaryFocus?.unfocus();
                onTitleFinishedEditing(textEditingController.text);
              },
              onTapOutside: (PointerDownEvent a) {
                Lgr.log("On tapped outside $a");
                FocusManager.instance.primaryFocus?.unfocus();
                onTitleFinishedEditing(textEditingController.text);
              },
              decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: "game title",

                  hintText: "hint",
                  border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
