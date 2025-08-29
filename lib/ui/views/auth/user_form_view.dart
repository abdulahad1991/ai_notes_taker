import 'package:ai_notes_taker/ui/views/auth/user_form_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class UserFormView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserFormViewModel>.reactive(
        viewModelBuilder: () => UserFormViewModel()..init(),
        builder: (context, model, child) => Scaffold());
  }

}