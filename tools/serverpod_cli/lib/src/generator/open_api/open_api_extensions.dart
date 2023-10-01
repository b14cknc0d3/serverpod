part of './open_api_definition.dart';

extension on String {
  /// convert queryFrom -> query-form
  String get camelToKebabCase {
    if (!contains(RegExp(r'[A-Z]'))) {
      return this;
    }
    return replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)}-${match.group(2)?.toLowerCase()}');
  }
}

/// example
/// convert [nullType] -> [null]
///
extension on SchemaObjectType {
  String get type => name.replaceAll('Type', '');
}

/// example
/// convert [dateTime] -> [date-time]
/// convert [string] -> [string]
///
extension ChangeFormat on SchemaObjectFormat {
  String get formattedName => name.camelToKebabCase;
}

/// convert [TypeDefinition] className to [SchemaObjetType]
extension TypeConvert on TypeDefinition {
  SchemaObjectType get toSchemaObjectType {
    if (className == 'int') return SchemaObjectType.integer;
    if (isEnum) return SchemaObjectType.other;
    if (className == 'double') return SchemaObjectType.number;
    if (className == 'bool') return SchemaObjectType.boolean;
    if (className == 'String') return SchemaObjectType.string;
    if (className == 'DateTime') return SchemaObjectType.string;
    if (className == 'ByteData') return SchemaObjectType.string;
    if (className == 'Duration') return SchemaObjectType.string;
    if (className == 'UuidValue') return SchemaObjectType.string;
    if (className == 'List') return SchemaObjectType.array;
    // WIP
    // if ((className == 'Map') || (className == 'List')) {
    //   return SchemaObjectType.;
    // }
    return SchemaObjectType.other;
  }
}

/// convert [TypeDefinition] className to [SchemaObjetFormat]
extension ConvertFormat on TypeDefinition {
  SchemaObjectFormat? get toSchemaObjectFormat {
    if (className == 'int') return SchemaObjectFormat.int64;
    // if (isEnum) return SchemaObjectFormat.;
    if (className == 'double') return SchemaObjectFormat.float;
    // if (className == 'bool') return SchemaObjectFormat.;
    // if (className == 'String') return SchemaObjectFormat.;
    if (className == 'DateTime') return SchemaObjectFormat.dateTime;
    if (className == 'ByteData') return SchemaObjectFormat.byte;
    if (className == 'Duration') return SchemaObjectFormat.time;
    if (className == 'UuidValue') return SchemaObjectFormat.uuid;
    // if ((className == 'Map') || (className == 'List')) {
    //   return SchemaObjectFormat.;
    // }
    return null;
  }
}
