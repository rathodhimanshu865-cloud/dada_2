import 'dart:io';

void main() {
  print('--- Starting Zero-English Audit ---');
  
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true);
  
  int hardcodedCount = 0;
  
  for (var file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Simple regex to find Text("...") or Text('...')
        // This is a heuristic and might have false positives
        if (line.contains('Text(\'') || line.contains('Text("')) {
          // Ignore comments
          if (line.trim().startsWith('//')) continue;
          
          // Ignore imports
          if (line.trim().startsWith('import')) continue;

          // Check if it's using a variable or L10n
          if (line.contains('AppLocalizations')) continue;
          if (line.contains('localized')) continue;
          
          print('Potential Hardcoded String in ${file.path}:${i + 1}:');
          print('  $line');
          hardcodedCount++;
        }
      }
    }
  }
  
  print('--- Audit Complete ---');
  print('Total potential hardcoded strings found: $hardcodedCount');
}
