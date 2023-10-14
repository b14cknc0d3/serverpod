part of '../open_api_objects.dart';

/// Holds the relative paths to the individual endpoints and their operations.
/// The path is appended to the URL from the Server Object in order to
///  construct the full URL.
/// The Paths may be empty, due to Access Control List (ACL) constraints.
/// ***Parameter Locations***
/// There are four possible parameter locations specified by the in field:
///  - path - Used together with Path Templating, where the parameter value is
///    actually part of the operation's URL. This does not include the host or
///    base path of the API. For example, in /items/{itemId}, the path
///    parameter is itemId.
///  - query - Parameters that are appended to the URL. For example, in /items?
///    id=###, the query parameter is id.
///  - header - Custom headers that are expected as part of the request.
///    Note that RFC7230 states header names are case insensitive.
///  - cookie - Used to pass a specific cookie value to the API.
class ParameterObject {
  /// parameter name
  final String name;

  /// The location of the parameter. Possible values are "query", "header",
  ///  "body" ,"path" or "cookie". key - [in]
  final ParameterLocation inField;
  final String? description;

  /// Determines whether this parameter is mandatory. If the parameter location
  /// is "path", this property is required and its value must be true.
  /// Otherwise, the property may be included and its default value is false.
  final bool requiredField;

  /// Specifies that a parameter is deprecated and should be transitioned
  /// out of usage. Default value is false.
  final bool deprecated;

  /// Sets the ability to pass empty-valued parameters. This is valid only for
  /// query parameters and allows sending a parameter with an empty value
  /// Default value is false. If style is used, and if behavior is n/a (cannot
  /// be serialized), the value of allowEmptyValue SHALL be ignored. Use of
  /// this property is not recommended, as it is likely to be removed in a
  /// later revision.
  final bool allowEmptyValue;

  /// Describes how the parameter value will be serialized depending
  /// on the type of the parameter value. Default values (based on value of in)
  /// query -> form; path -> simple; header -> simple; cookie -> form.
  final ParameterStyle? style;

  /// When this is true, parameter values of type array or
  /// object generate separate parameters for each value of the array
  /// or key-value pair of the map.
  /// For other types of parameters this property has no effect.
  /// When style is form, the default value is true. For all other styles,
  /// the default value is false.
  final bool explode;

  /// Determines whether the parameter value should allow reserved characters,
  /// as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without
  /// percent-encoding. This property only applies to parameters
  /// with an in value of query. The default value is false.
  final bool allowReserved;

  /// The schema defining the type used for the parameter.
  final ParameterSchemaObject? schema;

  ParameterObject({
    required this.name,
    required this.inField,
    this.description,
    required this.requiredField,
    this.deprecated = false,
    required this.allowEmptyValue,
    this.style,
    this.explode = false,
    this.allowReserved = false,
    this.schema,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'in': inField.name,
      'required': requiredField,
    };
    if (description != null) {
      map['description'] = description!;
    }
    if (deprecated) {
      map['deprecated'] = deprecated;
    }
    if (allowEmptyValue) {
      map['allowEmptyValue'] = allowEmptyValue;
    }

    if (style != null) {
      map['style'] = style!.name.paramCase;
    }

    if (explode) {
      map['explode'] = explode;
    }

    if (allowReserved) {
      map['allowReserved'] = allowReserved;
    }

    if (schema != null) {
      map['schema'] = schema!.toJson();
    }

    return map;
  }

  factory ParameterObject.fromParameterDefinition(
      ParameterDefinition parameterDefinition) {
    return ParameterObject(
      name: parameterDefinition.name,
      inField: ParameterLocation.body,
      requiredField: parameterDefinition.required,
      allowEmptyValue: false,
      schema: ParameterSchemaObject(
        parameterDefinition.type,
      ),
    );
  }
}
