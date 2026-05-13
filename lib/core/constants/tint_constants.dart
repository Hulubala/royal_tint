class TintSections {
  static const frontWindScreen = 'frontWindScreen';
  static const frontSideWindows = 'frontSideWindows';
  static const rearPassenger = 'rearPassenger';
  static const rearWindscreen = 'rearWindscreen';

  static const all = <String>[
    frontWindScreen,
    frontSideWindows,
    rearPassenger,
    rearWindscreen,
  ];

  static const labelByKey = <String, String>{
    frontWindScreen: 'Front Windscreen',
    frontSideWindows: 'Front Side Windows',
    rearPassenger: 'Rear Passenger',
    rearWindscreen: 'Rear Windscreen',
  };

  static const keyByLabel = <String, String>{
    'Front Windscreen': frontWindScreen,
    'Front Side Windows': frontSideWindows,
    'Rear Passenger': rearPassenger,
    'Rear Windscreen': rearWindscreen,
  };
}

const Map<String, List<String>> kPackageDarknessFallback = {
  'Package A': ['SV50', 'SV35', 'SV20', 'SV05'],
  'Package B': ['GL70', 'GL50', 'GL30', 'SV20', 'SV05'],
  'Package C': ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
  'Package D': ['PTN70', 'PTN50', 'PTN35', 'GL20', 'GL05'],
  'Package E': ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
};

const Map<String, Map<String, List<String>>> kPackageAllowedBySection = {
  'Package A': {
    TintSections.frontWindScreen: ['SV50', 'SV35', 'SV20', 'SV05'],
    TintSections.frontSideWindows: ['SV50', 'SV35', 'SV20', 'SV05'],
    TintSections.rearPassenger: ['SV50', 'SV35', 'SV20', 'SV05'],
    TintSections.rearWindscreen: ['SV50', 'SV35', 'SV20', 'SV05'],

  },
  'Package B': {
    TintSections.frontWindScreen: ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
    TintSections.frontSideWindows: ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
    TintSections.rearPassenger: ['SV50', 'SV35', 'SV20', 'SV05'],
    TintSections.rearWindscreen: ['SV50', 'SV35', 'SV20', 'SV05'],

  },
  'Package C': {
    TintSections.frontWindScreen: ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
    TintSections.frontSideWindows: ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
    TintSections.rearPassenger: ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
    TintSections.rearWindscreen: ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],

  },
  'Package D': {
    TintSections.frontWindScreen: ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
    TintSections.frontSideWindows: ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
    TintSections.rearPassenger: ['GL70', 'GL50', 'GL30','GL20', 'GL05'],
    TintSections.rearWindscreen: ['GL70', 'GL50', 'GL30','GL20', 'GL05'],
  },
  'Package E': {
    TintSections.frontWindScreen: ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
    TintSections.frontSideWindows: ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
    TintSections.rearPassenger: ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
    TintSections.rearWindscreen: ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
  },
};

const Map<String, String> vltToSVMapping = {
  'VLT 50%': 'SV50',
  'VLT 35%': 'SV35',
  'VLT 20%': 'SV20',
  'VLT 05%': 'SV05',
};

const Map<String, String> vltToGLMapping = {
  'VLT 70%': 'GL70',
  'VLT 50%': 'GL50',
  'VLT 30%': 'GL30',
  'VLT 20%': 'GL20',
  'VLT 05%': 'GL05',
};

const Map<String, String> vltToPTNMapping = {
  'VLT 70%': 'PTN70',
  'VLT 50%': 'PTN50',
  'VLT 35%': 'PTN35',
  'VLT 20%': 'PTN20',
  'VLT 05%': 'PTN05',
};

const Map<String, String> svToVLTMapping = {
  'SV50': 'VLT 50%',
  'SV35': 'VLT 35%',
  'SV20': 'VLT 20%',
  'SV05': 'VLT 05%',
  'GL70': 'VLT 70%',
  'GL50': 'VLT 50%',
  'GL30': 'VLT 30%',
  'GL20': 'VLT 20%',
  'GL05': 'VLT 05%',
  'PTN70': 'VLT 70%',
  'PTN50': 'VLT 50%',
  'PTN35': 'VLT 35%',
  'PTN20': 'VLT 20%',
  'PTN05': 'VLT 05%',
};

String mapSVtoVLT(String code) {
  return svToVLTMapping[code.toUpperCase().trim()] ?? code;
}

String resolvePackageType(String nameOrType) {
  final input = nameOrType.trim().toLowerCase();
  
  if (input == 'sv' || input == 'gl' || input == 'ptn') return input;

  if (kPackageDarknessFallback.containsKey(nameOrType)) {
    final List<String>? darknessOptions = kPackageDarknessFallback[nameOrType];
    if (darknessOptions != null && darknessOptions.isNotEmpty) {
      final firstCode = darknessOptions.first.toLowerCase();
      if (firstCode.startsWith('sv')) return 'sv';
      if (firstCode.startsWith('gl')) return 'gl';
      if (firstCode.startsWith('ptn')) return 'ptn';
    }
  }

  if (input.contains('gl') || input.contains('glass')) return 'gl';
  if (input.contains('ptn') || input.contains('platinum')) return 'ptn';
  
  return 'sv'; 
}

String mapVLTtoCode(String vlt, String packageNameOrType, {String? sectionKey}) {
  String type = 'sv';

  if (sectionKey != null && kPackageAllowedBySection.containsKey(packageNameOrType)) {
    final sectionMapping = kPackageAllowedBySection[packageNameOrType];
    final allowedCodes = sectionMapping?[sectionKey];
    if (allowedCodes != null && allowedCodes.isNotEmpty) {
      final firstCode = allowedCodes.first.toUpperCase();
      if (firstCode.startsWith('SV')) {
        type = 'sv';
      } else if (firstCode.startsWith('GL')) type = 'gl';
      else if (firstCode.startsWith('PTN')) type = 'ptn';
    } else {
      type = resolvePackageType(packageNameOrType);
    }
  } else {
    type = resolvePackageType(packageNameOrType);
  }
  
  String cleanVlt = vlt.trim().toUpperCase();
  if (cleanVlt.isEmpty) return vlt;

  if (cleanVlt.startsWith('SV') || cleanVlt.startsWith('GL') || cleanVlt.startsWith('PTN')) {
    return cleanVlt;
  }

  String digits = cleanVlt.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return vlt;

  if (digits.length == 1) digits = '0$digits';
  
  final key = 'VLT $digits%';

  switch (type) {
    case 'sv':
      return vltToSVMapping[key] ?? vlt;
    case 'gl':
      return vltToGLMapping[key] ?? vlt;
    case 'ptn':
      return vltToPTNMapping[key] ?? vlt;
    default:
      return vlt; 
  }
}

bool _isTintCode(String s) {
  final x = s.trim().toUpperCase();
  return x.startsWith('SV') || x.startsWith('GL') || x.startsWith('PTN');
}

String normalizeTintSelection({
  required String selection,
  required List<String> allowedCodes,
}) {
  final sel = selection.trim();
  if (sel.isEmpty) return '';

  if (_isTintCode(sel)) {
    final code = sel.toUpperCase();
    return allowedCodes.contains(code) ? code : code;
  }

  final vlt = sel;

  final candidates = <String>[
    vltToGLMapping[vlt] ?? '',
    vltToSVMapping[vlt] ?? '',
    vltToPTNMapping[vlt] ?? '',
  ].where((c) => c.isNotEmpty).toList();

  for (final c in candidates) {
    if (allowedCodes.contains(c)) return c;
  }

  return '';
}

List<String> allowedCodesFor({
  required String packageName,
  required String sectionKey,
}) {
  final bySection = kPackageAllowedBySection[packageName]?[sectionKey];
  if (bySection != null && bySection.isNotEmpty) return bySection;

  return kPackageDarknessFallback[packageName] ?? const [];
}


Map<String, String> defaultTintSelectionsForPackage(String packageName) {
  final result = <String, String>{};

  for (final sectionKey in TintSections.all) {
    final allowed = allowedCodesFor(packageName: packageName, sectionKey: sectionKey);
    result[sectionKey] = allowed.isNotEmpty ? allowed.first : '';
  }

  return result;
}

Map<String, String> defaultTintSelectionsFromOptions(List<String> options) {
  final def = options.isNotEmpty ? options.first : '';
  return {
    TintSections.frontWindScreen: def,
    TintSections.frontSideWindows: def,
    TintSections.rearPassenger: def,
    TintSections.rearWindscreen: def,
  };
}