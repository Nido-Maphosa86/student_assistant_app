/**
 Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng


 *          Static list of IT modules grouped by academic level.
 *          Controlled-input source for the application form (Unit 4 -
 *          "controlled input to avoid invalid selections").
 */

/// Static catalogue of available IT modules per academic level.
/// Used by the application form to constrain user input (Unit 4).
class ModuleCatalogue {
  static const List<String> levels = ['Year 1', 'Year 2', 'Year 3'];

  static const List<String> yearsOfStudy = [
    '1st Year',
    '2nd Year',
    '3rd Year',
  ];

  /// Map of academic level -> module codes available at that level.
  static const Map<String, List<String>> modulesByLevel = {
    'Year 1': [
      'PPC116C - Programming PRINCIPLES I',
      'ITM116C - INFORMATION TECHNOLOGY MATHEMATICS I',
      'ITE116C - INFORMATION TECHNOLOGY I',
      'CMN116C - Communication NETWORKS I',
    ],
    'Year 2': [
      'PPC216C - Programming II',
      'DBS216C - Database Systems',
      'SAD216C - Systems Analysis II',
      'TPG216C - TECHNICAL PROGRAMMING II',
    ],
    'Year 3': [
      'TPG316C - Technical Programming III',
      'SOD316C - Software Development',
      'CMN316C - Communication NETWORKS III',
      'ITS316C - INFORMATION TECHNOLOGY SOCIETY III',
    ],
  };

  /// Look up modules for a given level (returns empty list if not found).
  static List<String> modulesFor(String? level) {
    if (level == null) return const [];
    return modulesByLevel[level] ?? const [];
  }
}
