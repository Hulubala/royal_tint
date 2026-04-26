class TintSections {
  static const frontWindshield = 'frontWindshield';
  static const rearWindshield = 'rearWindshield';
  static const leftSide = 'leftSide';
  static const rightSide = 'rightSide';

  static const all = <String>[
    frontWindshield,
    rearWindshield,
    leftSide,
    rightSide,
  ];

  static const labelByKey = <String, String>{
    frontWindshield: 'Front Windshield',
    rearWindshield: 'Rear Windshield',
    leftSide: 'Left Side',
    rightSide: 'Right Side',
  };

  static const keyByLabel = <String, String>{
    'Front Windshield': frontWindshield,
    'Rear Windshield': rearWindshield,
    'Left Side': leftSide,
    'Right Side': rightSide,
  };
}

const Map<String, List<String>> kPackageDarknessFallback = {
  'Package A': ['SV50', 'SV35', 'SV20', 'SV05'],
  'Package B': ['GL70', 'GL50', 'GL30', 'SV20', 'SV05'],
  'Package C': ['GL70', 'GL50', 'GL30', 'GL20', 'GL05'],
  'Package D': ['PTN70', 'PTN50', 'PTN35', 'GL20', 'GL05'],
  'Package E': ['PTN70', 'PTN50', 'PTN35', 'PTN20', 'PTN05'],
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

String resolvePackageType(String packageName) {
  if (!kPackageDarknessFallback.containsKey(packageName)) {
    return 'sv'; // Default to 'sv' for unknown packages
  }

  // Use the first code to infer package type (e.g., SV50 -> 'sv')
  final List<String>? darknessOptions = kPackageDarknessFallback[packageName];
  if (darknessOptions != null && darknessOptions.isNotEmpty) {
    final firstCode = darknessOptions.first.toLowerCase();
    if (firstCode.startsWith('sv')) {
      return 'sv';
    } else if (firstCode.startsWith('gl')) {
      return 'gl';
    } else if (firstCode.startsWith('ptn')) {
      return 'ptn';
    }
  }

  return 'sv'; 
}

String mapVLTtoCode(String vlt, String packageName) {
 final packageType = resolvePackageType(packageName); 
  switch (packageType) {
    case 'sv':
      return vltToSVMapping[vlt] ?? vlt;
    case 'gl':
      return vltToGLMapping[vlt] ?? vlt;
    case 'ptn':
      return vltToPTNMapping[vlt] ?? vlt;
    default:
      return vlt; 
  }
}

String mapSVtoVLT(String code) {
  return svToVLTMapping[code] ?? code; 
}

Map<String, String> defaultTintSelectionsFromOptions(List<String> options) {
  final def = options.isNotEmpty ? options.first : '';
  return {
    TintSections.frontWindshield: def,
    TintSections.rearWindshield: def,
    TintSections.leftSide: def,
    TintSections.rightSide: def,
  };
}