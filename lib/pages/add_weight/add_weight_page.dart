import 'package:flutter/material.dart';

import 'widgets/manual_weight_form.dart';

class AddWeightPage extends StatelessWidget {
  const AddWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        ManualWeightForm(),
      ],
    );
  }
}
