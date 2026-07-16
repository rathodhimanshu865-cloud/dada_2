import 'dart:io';
import 'dart:convert';

void main() async {
  final targetDir = Directory('lib/views');
  
  final RegExp stringRegex = RegExp(r"Text\(['""]([^'""]+)['""]\)|_navItem\(['""]([^'""]+)['""]\)|_dropdownItem\(['""]([^'""]+)['""]\)|_buildDropdownNavItem\(['""]([^'""]+)['""]\)|label:\s*['""]([^'""]+)['""]");
  
  Set<String> uniqueStrings = {};
  
  List<FileSystemEntity> files = targetDir.listSync(recursive: true);
  for (var file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = file.readAsStringSync();
      Iterable<RegExpMatch> matches = stringRegex.allMatches(content);
      for (var match in matches) {
        for (int i = 1; i <= match.groupCount; i++) {
          if (match.group(i) != null && match.group(i)!.isNotEmpty) {
            String str = match.group(i)!;
            // Filter out paths, single characters
            if (!str.startsWith('/') && str.length > 1 && !str.contains(r'$')) {
              uniqueStrings.add(str);
            }
          }
        }
      }
    }
  }

  // Common strings
  uniqueStrings.addAll([
    'Home', 'About Dada', 'Katha', 'Shrimad Bhagvat Katha', 'Devi Bhagvat Katha', 
    'Shivmahapuran Katha', 'Full Katha List', 'Upcoming Kathas', 'Stotra / Bhajan', 
    'Gallery', 'Photo Gallery', 'Video Gallery', 'News Gallery', 'Contact',
    'Contact Us', 'ENQUIRIES', 
    'This site is an informative website, therefore please fill in the form below for any technical website related queries only.',
    'Kathas List', 'SEARCH KATHAS', 'WATCH ON YOUTUBE', 'READ MORE',
    'No photos added to this section yet.', 'More Details', 'CLOSE', 
    'READ FULL BIOGRAPHY', 'Image link copied to clipboard!', 
    'VIEW ALL VIDEOS', 'VIEW ALL NEWS', 'EXPLORE FULL GALLERY', 
    'EXPLORE KATHA JOURNEY', 'VIEW ALL UPCOMING KATHAS', 'English'
  ]);
  
  // Create translation map
  Map<String, String> en = {};
  Map<String, String> gu = {};
  Map<String, String> hi = {};
  
  for (var str in uniqueStrings) {
    en[str] = str;
    gu[str] = str + " (Gu)"; // Placeholder
    hi[str] = str + " (Hi)"; // Placeholder
  }

  // Create assets/translations directory
  final dir = Directory('assets/translations');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  File('assets/translations/en.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(en));
  File('assets/translations/gu.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(gu));
  File('assets/translations/hi.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(hi));

  print('Extracted \${uniqueStrings.length} strings.');
}
