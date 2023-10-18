import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/analyzer/dart/definitions.dart';
import 'package:serverpod_cli/src/generator/open_api/helpers/extensions.dart';
import 'package:serverpod_cli/src/generator/open_api/helpers/utils.dart';

/// Serializes [TypeDefinition] all type to JSON.
Map<String, dynamic> typeDefinitionToJson(TypeDefinition type,
    [bool child = false]) {
  Map<String, dynamic> map = {};
  if (type.className == 'Future') {
    return typeDefinitionToJson(type.generics.first, child);
  }
  if (type.className == 'void') return map;
  if (type.isMapType) {
    map = mapTypeToJson(type, child);
    return map;
  }
  if (type.isListType) {
    map = listTypeToJson(type, child);
    return map;
  }

  if (type.isUnknownSchemaType) {
    map = unknownSchemaTypeToJson(type, child);
    return map;
  }
  map = coreDartTypeToJson(type, child);
  return map;
}

/// Serializes a [TypeDefinition] [Map] type to JSON
Map<String, dynamic> mapTypeToJson(TypeDefinition type, [bool child = false]) {
  assert(
    type.isMapType,
    'Use mapTypeToJson only when the typeDefinition is of the MapType.',
  );

  Map<String, dynamic> map = {};
  map['type'] = SchemaObjectType.object.name;
  if (type.nullable) map['nullable'] = true;

  // If data is Map<String,int> use last int from generics as
  // additionalProperties
  if (type.generics.isEmpty) return map;
  var lastType = type.generics.last;
  if (lastType.isListType) {
    map['additionalProperties'] = listTypeToJson(lastType, true);
  } else if (lastType.isMapType) {
    map['additionalProperties'] = mapTypeToJson(lastType, true);
  } else if (lastType.isUnknownSchemaType) {
    map['additionalProperties'] = unknownSchemaTypeToJson(lastType, true);
  } else {
    map['additionalProperties'] = coreDartTypeToJson(
      lastType,
      true,
    );
  }

  return map;
}

/// Serializes a [TypeDefinition] core dart type (String, bool, double, int,
/// BigInt, ...) to JSON
Map<String, dynamic> coreDartTypeToJson(TypeDefinition type,
    [bool child = false]) {
  assert(
    type.toSchemaObjectType != SchemaObjectType.serializableObjects,
    'SchemaObjectType should not be serializableObjects type',
  );
  assert(
    type.toSchemaObjectType != SchemaObjectType.array,
    'SchemaObjectType should not be array type',
  );
  assert(
    type.toSchemaObjectType != SchemaObjectType.object,
    'SchemaObjectType should not be object type',
  );
  Map<String, dynamic> map = {};
  map['type'] = type.toSchemaObjectType.name;
  if (type.nullable) map['nullable'] = true;
  return map;
}

/// Serializes a [SchemaObjectType.serializableObjects] to JSON
Map<String, dynamic> unknownSchemaTypeToJson(TypeDefinition type,
    [bool child = false]) {
  assert(
    type.toSchemaObjectType == SchemaObjectType.serializableObjects,
    'Use unknownSchemaTypeToJson only when the SchemaObjectType is serializableObjects.',
  );
  Map<String, dynamic> map = {};

  // SerializableObjects types are always object.
  if (!child) map['type'] = SchemaObjectType.object.name;
  map['\$ref'] =
      _getRef(type.className == 'dynamic' ? 'AnyValue' : type.className);
  if (type.nullable && !child) map['nullable'] = true;
  return map;
}

/// Serializes a [TypeDefinition] [List] type to JSON
Map<String, dynamic> listTypeToJson(TypeDefinition type, [bool child = false]) {
  assert(
    type.isListType,
    'Use listTypeToJson only when the typeDefinition is of the ListType.',
  );
  Map<String, dynamic> map = {};
  map['type'] = SchemaObjectType.array.name;

  map['items'] = {};

  var generic = type.generics;
  if (generic.isEmpty) {
    map['items']['\$ref'] = _getRef('AnyValue');
    return map;
  }
  if (generic.first.isListType) {
    map['items'] = listTypeToJson(generic.first, true);
    return map;
  }
  if (generic.first.isMapType) {
    map['items'] = mapTypeToJson(generic.first, true);
    return map;
  }

  if (generic.first.isUnknownSchemaType) {
    map['items'] = unknownSchemaTypeToJson(generic.first, true);
    return map;
  }
  map['items'] = coreDartTypeToJson(generic.first, true);
  return map;
}

/// A schema object used within [ComponentObject].
class ComponentSchemaObject {
  final SerializableEntityDefinition entityDefinition;

  ComponentSchemaObject(
    this.entityDefinition,
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};

    if (entityDefinition is EnumDefinition) {
      var enumDefinition = entityDefinition as EnumDefinition;
      map[entityDefinition.className] = {
        'type': SchemaObjectType.string.name,
        'enum': enumDefinition.values.map((e) => e.name).toList(),
      };
      return map;
    }
    var classDefinition = entityDefinition as ClassDefinition;
    Map<String, dynamic> objectMap = {};
    objectMap['type'] = SchemaObjectType.object.name;
    objectMap['properties'] = {};
    for (var field in classDefinition.fields) {
      objectMap['properties'][field.name] = {};
      objectMap['properties'][field.name] =
          typeDefinitionToJson(field.type, true);
    }
    map[entityDefinition.className] = objectMap;

    return map;
  }
}

/// A schema object used within [ContentObject]. Generate request body content
/// based on the parameters of a Serverpod endpoint's method.
class RequestContentSchemaObject {
  final List<ParameterDefinition> params;
  RequestContentSchemaObject({
    required this.params,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['type'] = SchemaObjectType.object.name;
    map['properties'] = {};
    for (var param in params) {
      map['properties'][param.name] = typeDefinitionToJson(param.type, true);
    }

    return map;
  }
}

/// A schema object that will be used in [ParameterObject].
class ParameterSchemaObject {
  final TypeDefinition typeDefinition;

  ParameterSchemaObject(this.typeDefinition);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    if (typeDefinition.isEnum) {
      map['type'] = SchemaObjectType.string.name;
      map['enum'] = {};
      return map;
    }
    map = typeDefinitionToJson(typeDefinition);
    return map;
  }
}

String _getRef(String ref) {
  return '#/components/schemas/$ref';
}
