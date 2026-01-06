import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tp_router_annotation/tp_router_annotation.dart';

/// Builder that collects all @TpRoute annotations and generates
/// a single tp_router.g.dart file.
class TpRouterBuilder implements Builder {
  static const _tpRouteChecker = TypeChecker.fromRuntime(TpRoute);
  static const _tpShellRouteChecker = TypeChecker.fromRuntime(TpShellRoute);
  static const _pathChecker = TypeChecker.fromRuntime(Path);
  static const _queryChecker = TypeChecker.fromRuntime(Query);

  @override
  Map<String, List<String>> get buildExtensions => {
        r'lib/$lib$': ['lib/tp_router.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final allRoutes = <_BaseRouteData>[];
    final imports = <String>{};

    // Find all Dart files in lib/
    await for (final input in buildStep.findAssets(Glob('lib/**/*.dart'))) {
      // Skip generated files
      if (input.path.endsWith('.g.dart')) continue;

      try {
        final library = await buildStep.resolver.libraryFor(input);
        final reader = LibraryReader(library);

        // Find all classes with @TpRoute annotation
        for (final annotated in reader.annotatedWith(_tpRouteChecker)) {
          final element = annotated.element;
          if (element is! ClassElement) continue;

          final routeData = _analyzeRoute(
            element,
            annotated.annotation,
            input.path,
          );

          if (routeData != null) {
            allRoutes.add(routeData);
            // Add import for the source file
            final importPath = input.path.replaceFirst(
              'lib/',
              'package:${buildStep.inputId.package}/',
            );
            imports.add(importPath);
          }
        }

        // Find all classes with @TpShellRoute annotation
        for (final annotated in reader.annotatedWith(_tpShellRouteChecker)) {
          final element = annotated.element;
          if (element is! ClassElement) continue;

          final shellData = _analyzeShellRoute(element, annotated.annotation);

          if (shellData != null) {
            allRoutes.add(shellData);
            // Add import for the source file
            final importPath = input.path.replaceFirst(
              'lib/',
              'package:${buildStep.inputId.package}/',
            );
            imports.add(importPath);
          }
        }
      } catch (e) {
        // Skip files that can't be resolved
        continue;
      }
    }

    if (allRoutes.isNotEmpty) {
      final content = _generateFile(allRoutes, imports);
      final outputId =
          AssetId(buildStep.inputId.package, 'lib/tp_router.g.dart');
      await buildStep.writeAsString(outputId, content);
    }
  }

  /// Analyzes a class with @TpRoute annotation.
  _RouteData? _analyzeRoute(
    ClassElement classElement,
    ConstantReader annotation,
    String sourcePath,
  ) {
    final className = classElement.name;

    // Extract annotation values
    final path = annotation.read('path').stringValue;
    final name = annotation.peek('name')?.stringValue;
    final isInitial = annotation.read('isInitial').boolValue;

    // Generate route class name (remove Page/Screen suffix)
    final routeClassName = _generateRouteClassName(className);

    // Analyze constructor parameters
    final constructor = classElement.unnamedConstructor;
    if (constructor == null) return null;

    // Collect parameter info
    final params = <_ParamData>[];
    for (final param in constructor.parameters) {
      // Skip 'key' parameter for widgets
      if (param.name == 'key') continue;

      final paramData = _analyzeParameter(param, classElement);
      if (paramData != null) {
        params.add(paramData);
      }
    }

    return _RouteData(
      className: className,
      routeClassName: routeClassName,
      path: path,
      name: name,
      isInitial: isInitial,
      params: params,
    );
  }

  /// Analyzes a class with @TpShellRoute annotation.
  _ShellRouteData? _analyzeShellRoute(
      Element element, ConstantReader annotation) {
    if (element is! ClassElement) return null;
    final className = element.name;
    final routeClassName = _generateRouteClassName(className);

    final childrenObj = annotation.read('children').listValue;
    final childrenClassNames = childrenObj
        .map((o) => o.toTypeValue()?.element?.name)
        .whereType<String>()
        .toList();

    final isIndexedStack = annotation.read('isIndexedStack').boolValue;

    return _ShellRouteData(
      className: className,
      routeClassName: routeClassName,
      childrenClassNames: childrenClassNames,
      isIndexedStack: isIndexedStack,
    );
  }

  /// Generates route class name by removing Page/Screen suffix.
  String _generateRouteClassName(String className) {
    String result = className;
    if (result.endsWith('Page')) {
      result = result.substring(0, result.length - 4);
    } else if (result.endsWith('Screen')) {
      result = result.substring(0, result.length - 6);
    }
    return '${result}Route';
  }

  /// Analyzes a constructor parameter.
  _ParamData? _analyzeParameter(
    ParameterElement param,
    ClassElement classElement,
  ) {
    final paramName = param.name;
    final paramType = param.type;
    final typeStr = paramType.getDisplayString(withNullability: true);
    final isNullable =
        paramType.nullabilitySuffix == NullabilitySuffix.question;
    final isRequired = param.isRequired && !isNullable;

    // Determine source from annotations
    String? customName;
    String source = 'auto';

    // Check field annotations first
    final field = classElement.getField(paramName);
    if (field != null) {
      final fieldResult = _checkAnnotations(field);
      if (fieldResult != null) {
        source = fieldResult.source;
        customName = fieldResult.name;
      }
    }

    // Check parameter annotations (override field annotations)
    final paramResult = _checkAnnotations(param);
    if (paramResult != null) {
      source = paramResult.source;
      customName = paramResult.name ?? customName;
    }

    // For complex types without explicit annotation, default to extra
    final baseType = _getBaseType(typeStr);
    if (source == 'auto' && _isComplexType(baseType)) {
      source = 'extra';
    }

    final urlName = customName ?? paramName;

    // Validate type for path/query
    if (source == 'path' || source == 'query') {
      const allowedTypes = ['String', 'int', 'double', 'bool'];
      if (!allowedTypes.contains(baseType)) {
        throw InvalidGenerationSourceError(
          'Parameter "$paramName" in ${classElement.name} has invalid type "$typeStr" for source "$source". '
          'Allowed types are: ${allowedTypes.join(', ')}.',
          element: param,
        );
      }
    }

    // Validate Query parameters must have a default value
    if (source == 'query' && !param.hasDefaultValue) {
      throw InvalidGenerationSourceError(
        'Query parameter "$paramName" in ${classElement.name} must have a default value in the constructor.',
        element: param,
      );
    }

    return _ParamData(
      name: paramName,
      urlName: urlName,
      type: typeStr,
      baseType: baseType,
      isRequired: isRequired,
      isNullable: isNullable,
      isNamed: param.isNamed,
      source: source,
      defaultValueCode: param.defaultValueCode,
    );
  }

  /// Checks for @Path, @Query annotations on an element.
  _AnnotationResult? _checkAnnotations(Element element) {
    // Check @Path
    if (_pathChecker.hasAnnotationOf(element)) {
      final annotation = _pathChecker.firstAnnotationOf(element);
      if (annotation != null) {
        final reader = ConstantReader(annotation);
        final name = reader.peek('name')?.stringValue;
        return _AnnotationResult(source: 'path', name: name);
      }
    }

    // Check @Query
    if (_queryChecker.hasAnnotationOf(element)) {
      final annotation = _queryChecker.firstAnnotationOf(element);
      if (annotation != null) {
        final reader = ConstantReader(annotation);
        final name = reader.peek('name')?.stringValue;
        return _AnnotationResult(source: 'query', name: name);
      }
    }

    return null;
  }

  /// Generates the complete output file content.
  String _generateFile(
    List<_BaseRouteData> allRoutes,
    Set<String> imports,
  ) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by tp_router_generator');
    buffer.writeln();
    buffer.writeln("import 'package:tp_router/tp_router.dart';");

    // Import source files
    for (final import in imports.toList()..sort()) {
      buffer.writeln("import '$import';");
    }
    buffer.writeln();

    // Generate Route classes
    for (final route in allRoutes) {
      if (route is _RouteData) {
        buffer.writeln(_generateRouteClass(route));
      } else if (route is _ShellRouteData) {
        buffer.writeln(_generateShellRouteClass(route, allRoutes));
      }
    }

    // Generate tpRoutes list (Tree Structure)
    buffer.writeln('/// All generated routes in the application.');
    buffer.writeln('///');
    buffer.writeln('/// Use this list to initialize [TpRouter]:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// final router = TpRouter(routes: tpRoutes);');
    buffer.writeln('/// ```');
    buffer.writeln('List<TpRouteBase> get tpRoutes => [');

    // Find child routes to exclude from root list
    final childRouteNames = <String>{};
    for (final route in allRoutes) {
      if (route is _ShellRouteData) {
        childRouteNames.addAll(route.childrenClassNames);
      }
    }

    // Generate root routes
    for (final route in allRoutes) {
      if (!childRouteNames.contains(route.className)) {
        buffer.writeln('  ${route.routeClassName}.routeInfo,');
      }
    }
    buffer.writeln('];');

    return buffer.toString();
  }

  String _generateShellRouteClass(
      _ShellRouteData route, List<_BaseRouteData> allRoutes) {
    final buffer = StringBuffer();
    buffer.writeln('class ${route.routeClassName} {');

    if (route.isIndexedStack) {
      // Generate TpStatefulShellRouteInfo
      buffer.writeln(
          '  static final TpStatefulShellRouteInfo routeInfo = TpStatefulShellRouteInfo(');
      // For stateful shell, the builder receives navigationShell
      buffer.writeln(
          '    builder: (context, navigationShell) => ${route.className}(navigationShell: navigationShell),');
      buffer.writeln('    branches: [');
      for (final childName in route.childrenClassNames) {
        final childRoute = allRoutes.firstWhere(
          (r) => r.className == childName,
          orElse: () => throw StateError(
              'Child route $childName not found for shell ${route.className}'),
        );
        // Each child gets its own branch list (containing just itself for now)
        buffer.writeln('      [');
        buffer.writeln('        ${childRoute.routeClassName}.routeInfo,');
        buffer.writeln('      ],');
      }
      buffer.writeln('    ],');
      buffer.writeln('  );');
    } else {
      // Original Stateless ShellRoute
      buffer.writeln(
          '  static final TpShellRouteInfo routeInfo = TpShellRouteInfo(');
      buffer.writeln(
          '    builder: (context, child) => ${route.className}(child: child),');
      buffer.writeln('    routes: [');
      for (final childName in route.childrenClassNames) {
        final childRoute = allRoutes.firstWhere(
          (r) => r.className == childName,
          orElse: () => throw StateError(
              'Child route $childName not found for shell ${route.className}'),
        );
        buffer.writeln('      ${childRoute.routeClassName}.routeInfo,');
      }
      buffer.writeln('    ],');
      buffer.writeln('  );');
    }

    buffer.writeln('}');
    buffer.writeln();
    return buffer.toString();
  }

  /// Generates a Route class for navigation.
  String _generateRouteClass(_RouteData route) {
    final buffer = StringBuffer();
    final routeClassName = route.routeClassName;

    buffer.writeln('/// Route class for [${route.className}].');
    buffer.writeln('///');
    buffer.writeln('/// Usage:');
    buffer.writeln('/// ```dart');
    if (route.params.isEmpty) {
      buffer.writeln('/// $routeClassName().tp(context);');
    } else {
      final exampleArgs = route.params
          .where((p) => p.isRequired)
          .map((p) => '${p.name}: ${_getExampleValue(p)}')
          .join(', ');
      buffer.writeln('/// $routeClassName($exampleArgs).tp(context);');
    }
    buffer.writeln('/// ```');
    buffer.writeln('class $routeClassName extends BaseRoute {');

    // Fields
    for (final param in route.params) {
      buffer.writeln('  final ${param.type} ${param.name};');
    }
    if (route.params.isNotEmpty) {
      buffer.writeln();
    }

    // Constructor
    buffer.write('  const $routeClassName(');
    if (route.params.isNotEmpty) {
      buffer.writeln('{');
      for (final param in route.params) {
        if (param.isRequired) {
          buffer.writeln('    required this.${param.name},');
        } else {
          if (param.defaultValueCode != null) {
            buffer
                .writeln('    this.${param.name} = ${param.defaultValueCode},');
          } else {
            buffer.writeln('    this.${param.name},');
          }
        }
      }
      buffer.write('  }');
    }
    buffer.writeln(');');
    buffer.writeln();

    // Path getter
    buffer.writeln('  /// The route path.');
    buffer.writeln("  static const String path = '${route.path}';");
    buffer.writeln();

    // Static routeInfo (inline TpRouteInfo)
    buffer.writeln('  /// The route info for this route.');
    buffer.writeln('  static final TpRouteInfo routeInfo = TpRouteInfo(');
    buffer.writeln("    path: '${route.path}',");
    if (route.name != null) {
      buffer.writeln("    name: '${route.name}',");
    }
    buffer.writeln('    isInitial: ${route.isInitial},');
    buffer.writeln('    params: [');
    for (final param in route.params) {
      buffer.writeln('      TpParamInfo(');
      buffer.writeln("        name: '${param.name}',");
      buffer.writeln("        urlName: '${param.urlName}',");
      buffer.writeln("        type: '${param.type}',");
      buffer.writeln('        isRequired: ${param.isRequired},');
      buffer.writeln("        source: '${param.source}',");
      buffer.writeln('      ),');
    }
    buffer.writeln('    ],');
    buffer.writeln('    builder: (settings) {');
    // Generate parameter extraction
    for (final param in route.params) {
      buffer.writeln(_generateParamExtraction(param));
    }
    // Generate constructor call
    buffer.write('      return ${route.className}(');
    final constructorArgs = <String>[];
    for (final p in route.params) {
      if (p.isNamed) {
        if (!p.isRequired && p.defaultValueCode != null) {
          // Only pass if value is not null, otherwise let default take over
          // But extraction logic returns null if missing/failed.
          // So we need to conditionally add this argument.
          // However, we are inside a return statement, hard to do "if".
          // Better approach:
          // The extracted local variable uses nullable logic e.g. `final name = ...`.
          // If we pass `name: name ?? default`, we duplicate default logic.
          // Ideally: if local variable is null, DONT pass it to constructor.
          // But Dart constructor call structure is static.
          //
          // Alternative: modify extraction to use default if provided?
          // No, default is in constructor.
          //
          // If the parameter is named optional `this.age = 0`:
          // Call `UserPage(age: age)` where `age` is null -> `age` becomes null (if nullable type) or error?
          // Wait, if `age` is `int` (non-nullable) but we try to pass null, it errors.
          // If `age` is `int?`, passing null overrides default value `0`?
          // Dart behavior: `({int x = 1})` -> `f(x: null)` -> `x` is `null`. Default value is ignored if explicit null passed.
          // So we MUST NOT pass `age: age` if  `age` is null, if we want default value to trigger.

          // But we can't easily conditionally add args in a single return statement without helper variables or function.
          // Since we are generating code, we can't change the call shape dynamically at runtime.

          // Solution: Pass `value ?? defaultValue` at the call site?
          // We have `defaultValueCode` available at generation time!
          // So we can generate: `age: age ?? 0`.
          constructorArgs.add('${p.name}: ${p.name} ?? ${p.defaultValueCode}');
        } else {
          constructorArgs.add('${p.name}: ${p.name}');
        }
      } else {
        constructorArgs.add(p.name);
      }
    }
    buffer.writeln('${constructorArgs.join(', ')});');
    buffer.writeln('    },');
    buffer.writeln('  );');
    buffer.writeln();

    // Build path method
    buffer.writeln('  @override');
    buffer.writeln('  String get fullPath {');
    buffer.writeln("    var p = '${route.path}';");

    // Replace path parameters
    final pathParams = route.params.where((p) => p.source == 'path');
    for (final param in pathParams) {
      buffer.writeln(
          "    p = p.replaceAll(':${param.urlName}', ${param.name}.toString());");
    }

    // Build query parameters
    final queryParams = route.params.where((p) =>
        p.source == 'query' ||
        (p.source == 'auto' && !_isComplexType(p.baseType)));
    if (queryParams.isNotEmpty) {
      buffer.writeln('    final queryParts = <String>[];');
      for (final param in queryParams) {
        if (param.isNullable) {
          buffer.writeln(
              "    if (${param.name} != null) queryParts.add('${param.urlName}=\${Uri.encodeComponent(${param.name}.toString())}');");
        } else {
          buffer.writeln(
              "    queryParts.add('${param.urlName}=\${Uri.encodeComponent(${param.name}.toString())}');");
        }
      }
      buffer.writeln(
          "    if (queryParts.isNotEmpty) p = '\$p?\${queryParts.join('&')}';");
    }

    buffer.writeln('    return p;');
    buffer.writeln('  }');
    buffer.writeln();

    // Extra data getter
    final extraParams = route.params.where((p) => p.source == 'extra');
    if (extraParams.isNotEmpty) {
      buffer.writeln('  @override');
      buffer.writeln('  Map<String, dynamic> get extra => {');
      for (final param in extraParams) {
        buffer.writeln("    '${param.urlName}': ${param.name},");
      }
      buffer.writeln('  };');
      buffer.writeln();
    }

    buffer.writeln('}');
    buffer.writeln();

    return buffer.toString();
  }

  /// Gets an example value for a parameter type.
  String _getExampleValue(_ParamData param) {
    switch (param.baseType) {
      case 'int':
        return '123';
      case 'double':
        return '1.0';
      case 'bool':
        return 'true';
      case 'String':
        return "'value'";
      default:
        return 'value';
    }
  }

  /// Generates extraction code for a single parameter.
  String _generateParamExtraction(_ParamData p) {
    final name = p.name;
    final urlName = p.urlName;
    final isRequired = p.isRequired;

    // Handle extra source
    if (p.source == 'extra') {
      return _generateExtraExtraction(p);
    }

    // Determine the source access method
    String sourceAccess;
    switch (p.source) {
      case 'path':
        sourceAccess = "settings.pathParams['$urlName']";
        break;
      case 'query':
        sourceAccess = "settings.queryParams['$urlName']";
        break;
      default: // 'auto'
        sourceAccess = "settings.pathParams['$urlName'] ?? "
            "settings.queryParams['$urlName']";
    }

    // Generate type-specific extraction
    switch (p.baseType) {
      case 'int':
        return '''    final $name = (() {
      final raw = $sourceAccess;
      if (raw == null) {
        ${isRequired ? "throw ArgumentError('Missing required parameter: $name');" : "return null;"}
      }
      final parsed = int.tryParse(raw);
      if (parsed == null) {
        ${isRequired ? "throw ArgumentError('Invalid int value for: $name');" : "return null;"}
      }
      return parsed;
    })();''';

      case 'double':
        return '''    final $name = (() {
      final raw = $sourceAccess;
      if (raw == null) {
        ${isRequired ? "throw ArgumentError('Missing required parameter: $name');" : "return null;"}
      }
      final parsed = double.tryParse(raw);
      if (parsed == null) {
        ${isRequired ? "throw ArgumentError('Invalid double value for: $name');" : "return null;"}
      }
      return parsed;
    })();''';

      case 'bool':
        return '''    final $name = (() {
      final raw = $sourceAccess;
      if (raw == null) {
        ${isRequired ? "throw ArgumentError('Missing required parameter: $name');" : "return null;"}
      }
      final lower = raw.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
      ${isRequired ? "throw ArgumentError('Invalid bool value for: $name');" : "return null;"}
    })();''';

      case 'num':
        return '''    final $name = (() {
      final raw = $sourceAccess;
      if (raw == null) {
        ${isRequired ? "throw ArgumentError('Missing required parameter: $name');" : "return null;"}
      }
      final parsed = num.tryParse(raw);
      if (parsed == null) {
        ${isRequired ? "throw ArgumentError('Invalid num value for: $name');" : "return null;"}
      }
      return parsed;
    })();''';

      case 'String':
      default:
        if (_isComplexType(p.baseType)) {
          return _generateExtraExtraction(p);
        }
        if (isRequired) {
          return '''    final $name = $sourceAccess ??
        (throw ArgumentError('Missing required parameter: $name'));''';
        } else {
          return '''    final $name = $sourceAccess;''';
        }
    }
  }

  /// Generates extraction for complex types from extra.
  String _generateExtraExtraction(_ParamData p) {
    final name = p.name;
    final urlName = p.urlName;
    final type = p.type;
    final isRequired = p.isRequired;

    return '''    final $name = (() {
      final extra = settings.extra;
      if (extra is Map && extra.containsKey('$urlName')) {
        return extra['$urlName'] as $type;
      }
      if (extra is ${p.baseType}) {
        return extra;
      }
      ${isRequired ? "throw ArgumentError('Missing required parameter: $name');" : "return null;"}
    })();''';
  }

  /// Gets the base type without nullability suffix.
  String _getBaseType(String type) {
    if (type.endsWith('?')) {
      return type.substring(0, type.length - 1);
    }
    return type;
  }

  /// Checks if a type is complex (not a primitive).
  bool _isComplexType(String type) {
    const primitives = ['String', 'int', 'double', 'bool', 'num'];
    return !primitives.contains(type);
  }
}

/// Result of checking annotations.
class _AnnotationResult {
  final String source;
  final String? name;

  _AnnotationResult({required this.source, this.name});
}

/// Base data for any route.
abstract class _BaseRouteData {
  String get className;
  String get routeClassName;
}

/// Data for a standard route.
class _RouteData implements _BaseRouteData {
  @override
  final String className;
  @override
  final String routeClassName;
  final String path;
  final String? name;
  final bool isInitial;
  final List<_ParamData> params;

  _RouteData({
    required this.className,
    required this.routeClassName,
    required this.path,
    required this.name,
    required this.isInitial,
    required this.params,
  });
}

/// Data for a shell route.
class _ShellRouteData implements _BaseRouteData {
  @override
  final String className;
  @override
  final String routeClassName;
  final List<String> childrenClassNames;
  final bool isIndexedStack;

  _ShellRouteData({
    required this.className,
    required this.routeClassName,
    required this.childrenClassNames,
    required this.isIndexedStack,
  });
}

/// Data for a parameter.
class _ParamData {
  final String name;
  final String urlName;
  final String type;
  final String baseType;
  final bool isRequired;
  final bool isNullable;
  final bool isNamed;
  final String source;
  final String? defaultValueCode;

  _ParamData({
    required this.name,
    required this.urlName,
    required this.type,
    required this.baseType,
    required this.isRequired,
    required this.isNullable,
    required this.isNamed,
    required this.source,
    this.defaultValueCode,
  });
}
