part of '../open_api_objects.dart';

/// Specifies details regarding the server hosting an API.
/// example
/// ```dart
///   {
///   "url": "https://development.gigantic-server.com/v1",
///   "description": "Development server"
///   }
/// ```
class ServerObject {
  /// A URL to the target host.
  final Uri url;

  /// An optional string describing the host designated by the URL.
  final String? description;

  /// A map between a variable name and its value.
  /// The value is used for substitution in the server's URL template.
  final Map<String, ServerVariableObject>? variables;
  ServerObject({
    required this.url,
    this.description,
    this.variables,
  });

  Map<String, dynamic> toJson() {
    var map = {
      'url': url.toString(),
    };
    if (description != null) {
      map['description'] = description!;
    }
    return map;
  }
}

/// An object representing a Server Variable for server URL template
/// substitution.
class ServerVariableObject {
  final List<String>? enumField;

  /// The default value to use for substitution, which SHALL be sent if an
  /// alternate value is not supplied.
  /// Note this behavior is different than the Schema Object's treatment of
  /// default values, because in those cases parameter values are optional.
  /// If the enum is defined, the value must exist in the enum's values.
  /// key - [default]
  final String defaultField;

  /// An optional description for the server variable. CommonMark syntax
  /// may be used for rich text representation.
  final String? description;
  ServerVariableObject({
    this.enumField,
    required this.defaultField,
    this.description,
  });

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'default': defaultField,
    };
    if (enumField?.isNotEmpty ?? false) {
      map['enum'] = enumField!;
    }
    if (description != null) {
      map['description'] = description;
    }
    return map;
  }
}
