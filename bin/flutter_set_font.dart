import 'dart:convert';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:recase/recase.dart';

void main(List<String> arguments) async {
  print(
      'Welcome to Flutter Set Font Program. This program set fonts in dart file & pubspec.yaml. This program was created by "Shuoib Hossain Badon"');
  print('Program Started...\n');

  Directory directory = Directory('${path.current}/assets/fonts');

  List<String> fontList = [];
  var fonts = directory.list(recursive: false);
  await fonts.forEach((element) {
    final item = element.path.split('/').last.split('\\').last;
    fontList.add(item);
  });
  if (fontList.isEmpty) {
    stderr.write('Fonts directory is empty.\n');
    print('Program Finished.\n');
    return;
  }
  String variables = '';
  String yamlVariables = '';
  for (var font in fontList) {
    final elementName = path.basenameWithoutExtension(font).camelCase;
    final variable =
        '''static String get $elementName => '${elementName.pascalCase}';''';
    variables = await joinText(variables, variable);

    final yamlVariable = '''
    - family: ${elementName.pascalCase}
      fonts:
        - asset: assets/fonts/$font
''';
    yamlVariables = await joinText(yamlVariables, yamlVariable, gap: false);
  }
  await updateDartFile('fonts', variables);
  print('Fonts Variables set in "app_fonts.dart" file. \u2713');
  await updatePubspecFile('fonts', yamlVariables);
  print('Fonts Variables set in "pubspec.yaml" file. \u2713\n');
  print('Flutter Pub Get Process Started... ');

  final process =
  Process.runSync('C:\\flutter\\bin\\flutter.bat', ['pub', 'get']);
  print(await process.stdout);
  print(await process.stderr);
  print('Process Exit Code ${process.exitCode}');
  print('Program Finished.\n');
}

Future<String> joinText(String oldText, String newText,
    {bool gap = true}) async {
  if (oldText.isEmpty) {
    return newText;
  } else {
    if (gap) {
      return '$oldText\n  $newText';
    } else {
      return '$oldText\n$newText';
    }
  }
}

Future<void> updateDartFile(String directoryName, String variables) async {
  final fileDirectory =
      Directory('${path.current}/lib/constants/app_$directoryName.dart');

  final file = File(fileDirectory.path);

  final fileData =
      await file.openRead().map(utf8.decode).transform(LineSplitter()).toList();

  String fileHad = '';
  for (var element in fileData) {
    if (element.contains('class')) break;
    fileHad = await joinText(fileHad, element, gap: false);
  }

  String fileBody = '''
 $fileHad
class App${directoryName.titleCase} {
  App${directoryName.titleCase}._();
  
  $variables
  
}

''';
  await file.writeAsString(fileBody);
}

Future<void> updatePubspecFile(
    String directoryName, String yamlVariables) async {
  final fileDirectory = Directory('${path.current}/pubspec.yaml');

  final file = File(fileDirectory.path);

  final fileData =
      await file.openRead().map(utf8.decode).transform(LineSplitter()).toList();

  String fileHad = '';
  for (var element in fileData) {
    if (element.contains('fonts')) break;
    fileHad = await joinText(fileHad, element, gap: false);
  }
  String fileBody = '''
$fileHad
  fonts:

$yamlVariables
''';

  await file.writeAsString(fileBody);
}
// dart compile exe bin/flutter_set_font.dart && dart compile aot-snapshot bin/flutter_set_font.dart
