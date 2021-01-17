import 'dart:async';

import 'package:fluent_reader_lite/components/list_tile_group.dart';
import 'package:fluent_reader_lite/generated/l10n.dart';
import 'package:fluent_reader_lite/utils/colors.dart';
import 'package:flutter/cupertino.dart';

class TextEditorPage extends StatefulWidget {
  final String title;
  final String saveText;
  final String initialValue;
  final Color navigationBarColor;
  final FutureOr<bool> Function(String) validate;
  final bool isPassword;

  TextEditorPage(
    this.title,
    this.validate,
    {
      this.navigationBarColor,
      this.saveText,
      this.initialValue: "",
      this.isPassword: false,
      Key key,
    })
    : super(key: key);

  @override
  _TextEditorPage createState() => _TextEditorPage();
}

class _TextEditorPage extends State<TextEditorPage> {
  TextEditingController _controller;
  bool _validating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _onSave() async {
    setState(() { _validating = true; });
    var trimmed = _controller.text.trim();
    var valid = await widget.validate(trimmed);
    if (!mounted) return;
    setState(() { _validating = false; });
    if (valid) {
      Navigator.of(context).pop(trimmed);
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(S.of(context).invalidValue),
          actions: [
            CupertinoDialogAction(
              child: Text(S.of(context).close),
              isDefaultAction: true,
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: MyColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        backgroundColor: widget.navigationBarColor,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: _validating
            ? CupertinoActivityIndicator()
            : Text(widget.saveText ?? S.of(context).save),
          onPressed: _validating ? null : _onSave,
        ),
      ),
      child: ListView(children: [
        ListTileGroup([
          CupertinoTextField(
            controller: _controller,
            decoration: null,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            clearButtonMode: OverlayVisibilityMode.editing,
            readOnly: _validating,
            autofocus: true,
            obscureText: widget.isPassword,
            keyboardType: widget.isPassword ? TextInputType.visiblePassword : null,
            onSubmitted: (v) { _onSave(); },
          ),
        ]),
      ]),
    );
  }
}