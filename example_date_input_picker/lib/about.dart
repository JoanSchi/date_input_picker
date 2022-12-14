import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    const headerSize = 20.0;
    const paragraphSize = 18.0;

    return Column(children: [
      const Center(child: Text('About', style: TextStyle(fontSize: 24.0))),
      const SizedBox(
        height: 12.0,
      ),
      RichText(
          text: const TextSpan(
        text:
            'DateInputPicker was originaly intented for a month/year input field with a month/year picker, later the input field was adjusted to work also with dates and the default date picker.'
            ' If in following order year, month or day is not filled in, the current year, month or day is used. Order of format does not matter.'
            ' Sometimes the divider is not found on the soft keyboard or it is less convenient, therefore is it possible to add more dividers. In this example following dividers where added: /|\.|- .'
            ' If the date pass the validation test after submit or focus lost the divider is changed to the preferred one.',
        style: TextStyle(fontSize: paragraphSize, color: Colors.black),
        children: [
          TextSpan(
              text: '\n\nSamsung datetime keyboard',
              style: TextStyle(
                  fontSize: headerSize,
                  color: Color.fromARGB(255, 65, 114, 166))),
          TextSpan(
              text:
                  '\nUnlike the Google keyboard (GBoard), the samsung keyboard does not have any dividers when the text input is set to TextInputType.datetime.'
                  ' To overcome this problem, the date picker will change into a divider button after a number.'
                  ' This solution is only for Android/Ios, because the textfield maintains only focus on these platforms, this is not the case with the other platforms.'
                  ' For demontration the option is availible, but the autocompletion after focus lost is turned off, otherwise a divider is inserted just after a autocompletion of the date trigged by de unfocus listener.')
        ],
      ))
    ]);
  }
}
