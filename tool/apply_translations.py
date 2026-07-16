import os
import re
import json

target_dir = 'lib/views/user_side'

gujarati = {
    "Home": "હોમ",
    "About Dada": "દાદા વિશે",
    "Katha": "કથા",
    "Shrimad Bhagvat Katha": "શ્રીમદ્ ભાગવત કથા",
    "Devi Bhagvat Katha": "દેવી ભાગવત કથા",
    "Shivmahapuran Katha": "શિવમહાપુરાણ કથા",
    "Full Katha List": "સંપૂર્ણ કથા સૂચિ",
    "Upcoming Kathas": "આગામી કથાઓ",
    "Stotra / Bhajan": "સ્તોત્ર / ભજન",
    "Gallery": "ગેલેરી",
    "Photo Gallery": "ફોટો ગેલેરી",
    "Video Gallery": "વિડિઓ ગેલેરી",
    "News Gallery": "સમાચાર ગેલેરી",
    "Contact": "સંપર્ક",
    "Contact Us": "અમારો સંપર્ક કરો",
    "ENQUIRIES": "પૂછપરછ",
    "This site is an informative website, therefore please fill in the form below for any technical website related queries only.": "આ સાઇટ એક માહિતીપ્રદ વેબસાઇટ છે, તેથી કૃપા કરીને ફક્ત કોઈપણ તકનીકી વેબસાઇટ સંબંધિત પ્રશ્નો માટે નીચે આપેલ ફોર્મ ભરો.",
    "Kathas List": "કથાઓની સૂચિ",
    "SEARCH KATHAS": "કથાઓ શોધો",
    "WATCH ON YOUTUBE": "YouTube પર જુઓ",
    "READ MORE": "વધુ વાંચો",
    "No photos added to this section yet.": "હજુ સુધી આ વિભાગમાં કોઈ ફોટા ઉમેર્યા નથી.",
    "More Details": "વધુ વિગતો",
    "CLOSE": "બંધ કરો",
    "READ FULL BIOGRAPHY": "સંપૂર્ણ જીવનચરિત્ર વાંચો",
    "Image link copied to clipboard!": "છબીની લિંક ક્લિપબોર્ડ પર કૉપિ કરવામાં આવી!",
    "VIEW ALL VIDEOS": "બધા વિડિઓઝ જુઓ",
    "VIEW ALL NEWS": "બધા સમાચાર જુઓ",
    "EXPLORE FULL GALLERY": "સંપૂર્ણ ગેલેરીનું અન્વેષણ કરો",
    "EXPLORE KATHA JOURNEY": "કથા યાત્રાનું અન્વેષણ કરો",
    "VIEW ALL UPCOMING KATHAS": "બધી આગામી કથાઓ જુઓ",
    "English": "English",
    "Gujarati": "ગુજરાતી",
    "Hindi": "हिन्दी",
    "Home > Contact Us": "હોમ > અમારો સંપર્ક કરો",
    "Home > Kathas List": "હોમ > કથાઓની સૂચિ",
    "Home > News": "હોમ > સમાચાર",
    "Home > Gallery > Photos": "હોમ > ગેલેરી > ફોટા",
    "Home > Stotra / Bhajan / Aarti": "હોમ > સ્તોત્ર / ભજન / આરતી",
    "Home > Kathas > Upcoming Kathas": "હોમ > કથાઓ > આગામી કથાઓ",
    "Home > Gallery > Videos": "હોમ > ગેલેરી > વિડિઓઝ",
    "Message saved and email draft opened.": "સંદેશ સાચવવામાં આવ્યો અને ઇમેઇલ ડ્રાફ્ટ ખોલવામાં આવ્યો.",
    "Katha ": "કથા ",
    "Privacy Policy": "ગોપનીયતા નીતિ",
    "Terms & Conditions": "નિયમો અને શરતો",
    "LEARN MORE ABOUT DADA": "દાદા વિશે વધુ જાણો"
}

hindi = {
    "Home": "होम",
    "About Dada": "दादा के बारे में",
    "Katha": "कथा",
    "Shrimad Bhagvat Katha": "श्रीमद् भागवत कथा",
    "Devi Bhagvat Katha": "देवी भागवत कथा",
    "Shivmahapuran Katha": "शिवमहापुराण कथा",
    "Full Katha List": "संपूर्ण कथा सूची",
    "Upcoming Kathas": "आगामी कथाएं",
    "Stotra / Bhajan": "स्तोत्र / भजन",
    "Gallery": "गैलरी",
    "Photo Gallery": "फोटो गैलरी",
    "Video Gallery": "वीडियो गैलरी",
    "News Gallery": "समाचार गैलरी",
    "Contact": "संपर्क",
    "Contact Us": "हमसे संपर्क करें",
    "ENQUIRIES": "पूछताछ",
    "This site is an informative website, therefore please fill in the form below for any technical website related queries only.": "यह साइट एक सूचनात्मक वेबसाइट है, इसलिए कृपया केवल किसी भी तकनीकी वेबसाइट से संबंधित प्रश्नों के लिए नीचे दिए गए फॉर्म को भरें।",
    "Kathas List": "कथाओं की सूची",
    "SEARCH KATHAS": "कथाएं खोजें",
    "WATCH ON YOUTUBE": "YouTube पर देखें",
    "READ MORE": "और पढ़ें",
    "No photos added to this section yet.": "अभी तक इस अनुभाग में कोई फ़ोटो नहीं जोड़ा गया है।",
    "More Details": "अधिक जानकारी",
    "CLOSE": "बंद करें",
    "READ FULL BIOGRAPHY": "संपूर्ण जीवनी पढ़ें",
    "Image link copied to clipboard!": "छवि लिंक क्लिपबोर्ड पर कॉपी किया गया!",
    "VIEW ALL VIDEOS": "सभी वीडियो देखें",
    "VIEW ALL NEWS": "सभी समाचार देखें",
    "EXPLORE FULL GALLERY": "संपूर्ण गैलरी का अन्वेषण करें",
    "EXPLORE KATHA JOURNEY": "कथा यात्रा का अन्वेषण करें",
    "VIEW ALL UPCOMING KATHAS": "सभी आगामी कथाएं देखें",
    "English": "English",
    "Gujarati": "ગુજરાતી",
    "Hindi": "हिन्दी",
    "Home > Contact Us": "होम > हमसे संपर्क करें",
    "Home > Kathas List": "होम > कथाओं की सूची",
    "Home > News": "होम > समाचार",
    "Home > Gallery > Photos": "होम > गैलरी > तस्वीरें",
    "Home > Stotra / Bhajan / Aarti": "होम > स्तोत्र / भजन / आरती",
    "Home > Kathas > Upcoming Kathas": "होम > कथाएं > आगामी कथाएं",
    "Home > Gallery > Videos": "होम > गैलरी > वीडियो",
    "Message saved and email draft opened.": "संदेश सहेजा गया और ईमेल ड्राफ्ट खोला गया।",
    "Katha ": "कथा ",
    "Privacy Policy": "गोपनीयता नीति",
    "Terms & Conditions": "नियम और शर्तें",
    "LEARN MORE ABOUT DADA": "दादा के बारे में अधिक जानें"
}

all_strings = set()

# Regex patterns
text_regex = re.compile(r'Text\((["\'])([^$"\'\\]{2,})\1\)')
label_regex = re.compile(r'label:\s*(["\'])([^$"\'\\]{2,})\1')
hint_regex = re.compile(r'hintText:\s*(["\'])([^$"\'\\]{2,})\1')

def replace_func(match):
    q = match.group(1)
    s = match.group(2)
    if not s.startswith('/') and not s.startswith('assets') and s.strip():
        all_strings.add(s)
        return match.group(0).replace(q+s+q, q+s+q+'.tr()')
    return match.group(0)

for root, _, files in os.walk(target_dir):
    for filename in files:
        if filename.endswith('.dart'):
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                
            orig_content = content
            
            content = text_regex.sub(replace_func, content)
            content = label_regex.sub(replace_func, content)
            content = hint_regex.sub(replace_func, content)
            
            if content != orig_content:
                if 'package:easy_localization/easy_localization.dart' not in content:
                    content = "import 'package:easy_localization/easy_localization.dart';\n" + content
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {filepath}")

def update_json(filepath, mapping):
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    else:
        data = {}
        
    for s in all_strings:
        if s not in data:
            data[s] = mapping.get(s, s)
            
    for k, v in mapping.items():
        data[k] = v
        
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

update_json('assets/translations/en.json', {})
update_json('assets/translations/gu.json', gujarati)
update_json('assets/translations/hi.json', hindi)

print("Translation JSON files updated.")
