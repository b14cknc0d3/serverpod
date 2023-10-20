import 'package:serverpod_cli/src/generator/open_api/helpers/utils.dart';
import 'package:serverpod_cli/src/generator/types.dart';

/// Check whether [TypeDefinition] is dartCoreType or not.
extension TypeDefinitionExtension on TypeDefinition {
  bool get isCoreDartType =>
      className == 'String' ||
      className == 'int' ||
      className == 'double' ||
      className == 'bool' ||
      className == 'List' ||
      className == 'Map' ||
      className == 'Set' ||
      className == 'ByteData' ||
      className == 'BigInt' ||
      className == 'DateTime' ||
      className == 'UuidValue' ||
      className == 'Duration' ||
      url == 'dart:core' ||
      url == 'dart:async';

  /// Convert [TypeDefinition] to [SchemaObjetType].
  OpenAPISchemaType get toOpenAPISchemaType {
    switch (className) {
      case 'int':
        return OpenAPISchemaType.integer;
      case 'double':
        return OpenAPISchemaType.number;
      case 'BigInt':
        return OpenAPISchemaType.number;
      case 'bool':
        return OpenAPISchemaType.boolean;
      case 'String':
        return OpenAPISchemaType.string;
      case 'DateTime':
        return OpenAPISchemaType.string;
      case 'ByteData':
        return OpenAPISchemaType.string;
      case 'Duration':
        return OpenAPISchemaType.integer;
      case 'UuidValue':
        return OpenAPISchemaType.string;
      case 'List':
        return OpenAPISchemaType.array;
      case 'Map':
        return OpenAPISchemaType.object;
      default:
        return OpenAPISchemaType.serializableObjects;
    }
  }

  /// Check whether [TypeDefinition] is UnknownSchemaType or not.
  bool get isUnknownSchemaType =>
      toOpenAPISchemaType == OpenAPISchemaType.serializableObjects;

  /// convert [TypeDefinition] className to [SchemaObjetFormat]
  SchemaObjectFormat? get toSchemaObjectFormat {
    if (className == 'int') return SchemaObjectFormat.int64;
    if (className == 'double') return SchemaObjectFormat.float;
    if (className == 'DateTime') return SchemaObjectFormat.dateTime;
    if (className == 'ByteData') return SchemaObjectFormat.byte;
    if (className == 'UuidValue') return SchemaObjectFormat.uuid;
    return null;
  }
}
