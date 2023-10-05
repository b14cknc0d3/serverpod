// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../open_api_objects.dart';

///[TypeDefinition] toJson
Map<String, dynamic> typeToJson(TypeDefinition type, [bool child = false]) {
  Map<String, dynamic> map = {};
  if (type.className == 'Future') return typeToJson(type.generics.first, child);
  if (type.className == 'void') return map;
  if (type.isMapType) {
    map = mapToJson(type, child);
    return map;
  }
  if (type.isListType) {
    map = listToJson(type, child);
    return map;
  }

  if (!type.isDartCoreType) {
    map = refToJson(type, child);
    return map;
  }
  map = dartCoreTypeToJson(type, child);
  return map;
}

/// [TypeDefinition] map Type to Json
Map<String, dynamic> mapToJson(TypeDefinition type, [bool child = false]) {
  assert(type.isMapType,
      'Use mapToJson only when the typeDefinition is of the MapType.');

  Map<String, dynamic> map = {};
  map['type'] = SchemaObjectType.object.name;
  if (type.nullable) map['nullable'] = true;

  /// If data is Map<String,int>  use last int as additionalProperties
  var lastType = type.generics.last;
  if (lastType.isDartCoreType) {
    if (lastType.isListType) {
      map['additionalProperties'] = listToJson(lastType, true);
    } else if (lastType.isMapType) {
      map['additionalProperties'] = mapToJson(lastType, true);
    } else {
      map['additionalProperties'] = dartCoreTypeToJson(
        lastType,
        true,
      );
    }
  } else {
    map['additionalProperties'] = refToJson(lastType, true);
  }

  return map;
}

/// [TypeDefinition] dartCoreType to Json (string,bool,double,int,BigInt,)
Map<String, dynamic> dartCoreTypeToJson(TypeDefinition type,
    [bool child = false]) {
  assert(
      type.className == 'String' ||
          type.className == 'int' ||
          type.className == 'double' ||
          type.className == 'bool' ||
          type.className == 'BigInt',
      'Use dartCoreTypeToJson only when class Name are String,int,double,BigInt,bool, ');
  Map<String, dynamic> map = {};
  map['type'] = SchemaObjectType.string.name;
  if (type.nullable) map['nullable'] = true;
  return map;
}

///[TypeDefinition] custom class (!dartCoreType) to json
Map<String, dynamic> refToJson(TypeDefinition type, [bool child = false]) {
  Map<String, dynamic> map = {};
  if (!child) map['type'] = SchemaObjectType.object.name;
  map['\$ref'] = getRef(type.className);
  if (type.nullable && !child) map['nullable'] = true;
  return map;
}

/// [TypeDefinition] list Type to Json
Map<String, dynamic> listToJson(TypeDefinition type, [bool child = false]) {
  assert(type.isListType,
      'Use listToJson only when the typeDefinition is of the ListType.');
  Map<String, dynamic> map = {};
  map['type'] = SchemaObjectType.object.name;

  map['items'] = {};
  if (type.generics.isEmpty) {
    map['items']['\$ref'] = getRef('AnyValue');
    return map;
  }
  if (type.generics.first.isListType) {
    map['items'] = listToJson(type.generics.first, true);
    return map;
  }
  if (type.generics.first.isMapType) {
    map['items'] = mapToJson(type, true);
    return map;
  }

  if (!type.generics.first.isDartCoreType) {
    map['items'] = refToJson(type.generics.first, true);
    return map;
  }
  map['items'] = dartCoreTypeToJson(type.generics.first, true);
  return map;
}

/// A Schema object which will use in [ComponentObject]
class ComponentSchemaObject {
  final ClassDefinition classDefinition;

  ComponentSchemaObject(
    this.classDefinition,
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};

    Map<String, dynamic> objectMap = {};
    objectMap['type'] = SchemaObjectType.object.name;
    objectMap['properties'] = {};
    for (var field in classDefinition.fields) {
      objectMap['properties'][field.name] = {};
      if (field.type.isListType) {
        objectMap['properties'][field.name] = listToJson(field.type);
      } else if (field.type.isMapType) {
        objectMap['properties'][field.name] = mapToJson(field.type);
      } else {
        objectMap['properties'][field.name] = dartCoreTypeToJson(field.type);
      }
    }
    map[classDefinition.className] = objectMap;

    return map;
  }
}

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
      if (param.type.className == 'ByteData') continue;
      map['properties'][param.name] = typeToJson(param.type, true);
    }

    return map;
  }
}

/// A Schema Object that will be used in ParameterObject
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
    map = typeToJson(typeDefinition);
    return map;
  }
}
