$files = Get-ChildItem -Path "lib\views\user_side" -Filter "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $original = $content
    
    # Replace Text('...') with Text('...'.tr())
    $content = [regex]::Replace($content, "Text\((['""])([^`$'""]{2,}?)\1\)", "Text(`$1`$2`$1.tr())")
    
    if ($content -ne $original) {
        if (-not $content.Contains("import 'package:easy_localization/easy_localization.dart';")) {
            $content = "import 'package:easy_localization/easy_localization.dart';`r`n" + $content
        }
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Updated $($file.FullName)"
    }
}
