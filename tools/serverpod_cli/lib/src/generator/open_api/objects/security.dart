part of '../open_api_objects.dart';

/// Defines a security scheme that can be used by the operations.
abstract class SecuritySchemeObject {
  final String? description;
  SecuritySchemeObject({
    this.description,
  });
  Map<String, dynamic> toJson();
}

class HttpSecurityScheme extends SecuritySchemeObject {
  /// The name of the HTTP Authorization scheme to be used in the Authorization
  /// header as defined in RFC7235. Applies to [http]
  /// `basic` `bearer`
  final String scheme;

  /// A hint to the client to identify how the bearer token
  /// is formatted.  Applies to [http] ("bearer")
  /// example ```
  /// "bearerFormat": "JWT",
  /// ```
  final String? bearerFormat;
  HttpSecurityScheme({
    required this.scheme,
    super.description,
    this.bearerFormat,
  })  : assert(
          (scheme == 'basic') || (scheme == 'bearer'),
          '`scheme` must be one of `basic or bearer`.',
        ),
        assert(
            (scheme == 'basic') || (scheme == 'bearer' && bearerFormat != null),
            'When `scheme` is bearer `bearerFormat` should not be null');

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['type'] = SecuritySchemeType.http.name;
    if (description != null) map['description'] = description!;
    map['scheme'] = scheme;
    if (bearerFormat != null) map['bearerFormat'] = bearerFormat;
    return map;
  }
}

class ApiKeySecurityScheme extends SecuritySchemeObject {
  /// The name of the header, query or cookie parameter to be used. Applies to
  /// [apiKey]
  final String name;

  /// The location of the API key. Valid values are "query", "header" or
  /// "cookie". Applies to [apiKey]
  final String inField;
  ApiKeySecurityScheme({
    super.description,
    required this.name,
    required this.inField,
  }) : assert(
          ['query', 'header', 'cookie'].contains(inField),
          'inField only accept query,header and cookie',
        );

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['type'] = SecuritySchemeType.apiKey.name;
    if (description != null) map['description'] = description!;
    map['name'] = name;
    map['in'] = inField;
    return map;
  }
}

class OauthSecurityScheme extends SecuritySchemeObject {
  final Set<OauthFlowObject> flows;
  OauthSecurityScheme({
    super.description,
    required this.flows,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['type'] = SecuritySchemeType.oauth2.name;
    if (description != null) map['description'] = description!;
    Map<String, dynamic> oauthFlows = {};
    for (var flow in flows) {
      oauthFlows.addAll(flow.toJson());
    }
    map['flows'] = oauthFlows;
    return map;
  }
}

class OpenIdSecurityScheme extends SecuritySchemeObject {
  /// OpenId Connect URL to discover OAuth2 configuration values.
  /// This must be in the form of a URL. The OpenID Connect standard requires
  /// the use of TLS.
  final String openIdConnectUrl;
  OpenIdSecurityScheme({
    super.description,
    required this.openIdConnectUrl,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['type'] = SecuritySchemeType.openIdConnect.name;
    if (description != null) map['description'] = description!;
    map['openIdConnectUrl'] = openIdConnectUrl;
    return map;
  }
}

/// Allows configuration of the supported OAuth Flows.
class OauthFlowObject {
  /// Fixed Fields [implicit, password, clientCredentials, authorizationCode]
  final OauthFlowField fieldName;

  /// The authorization URL to be used for this flow
  /// Applies to oauth2 ("implicit", "authorizationCode")
  final Uri? authorizationUrl;

  /// The token URL to be used for this flow.
  /// Applies to oauth2 ("password", "clientCredentials", "authorizationCode")
  final Uri? tokenUrl;

  /// The URL to be used for obtaining refresh tokens
  final Uri refreshUrl;

  /// The available scopes for the OAuth2 security scheme. A map between
  /// the scope name and a short description for it.
  final Map<String, String> scopes;

  /// The extensions properties are implemented as patterned fields that are
  /// always prefixed by "x-".
  final Map<String, dynamic> specificationExtensions;
  OauthFlowObject({
    required this.fieldName,
    this.authorizationUrl,
    this.tokenUrl,
    required this.refreshUrl,
    required this.scopes,
    required this.specificationExtensions,
  });
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map[fieldName.name] = {};
    if (tokenUrl != null) {
      map[fieldName.name] = tokenUrl.toString();
    }
    if (authorizationUrl != null) {
      map[fieldName.name] = authorizationUrl.toString();
    }

    map[fieldName.name] = refreshUrl.toString();
    map[fieldName.name] = scopes;
    if (specificationExtensions.isEmpty) {
      for (var ext in specificationExtensions.entries) {
        if (ext.key.startsWith('x-')) {
          map[fieldName.name][ext.key] = ext.value;
        }
      }
    }
    return {};
  }
}

enum OauthFlowField {
  implicit,
  password,
  clientCredentials,
  authorizationCode,
}

class SecurityRequirementObject {
  final String name;
  final SecuritySchemeObject securitySchemes;
  SecurityRequirementObject({
    required this.name,
    required this.securitySchemes,
  });
  Map<String, dynamic> toJson([bool ref = false]) {
    Map<String, dynamic> map = {};
    map[name] = ref
        ? _getScopeFromSecurityScheme(securitySchemes)
        : securitySchemes.toJson();
    return map;
  }

  dynamic _getScopeFromSecurityScheme(SecuritySchemeObject securitySchemes) {
    if (securitySchemes is OauthSecurityScheme) {
      /// eg  - googleOAuth: ['openid', 'profile']
      return securitySchemes.flows.first.scopes.keys.toList();
    }
    return [];
  }
}

/// WIP
SecurityRequirementObject googleAuth = SecurityRequirementObject(
  name: 'googleOauth',
  securitySchemes: OauthSecurityScheme(description: 'Google Auth 2.0', flows: {
    OauthFlowObject(
      fieldName: OauthFlowField.authorizationCode,
      refreshUrl: Uri.parse('https://accounts.google.com/o/oauth2/token'),
      scopes: {
        'openid': 'OpenID Connect',
        'profile': 'User profile information'
      },
      specificationExtensions: {},
    ),
  }),
);

SecurityRequirementObject serverpodAuth = SecurityRequirementObject(
  name: 'serverpodAuth',
  securitySchemes: HttpSecurityScheme(
    scheme: 'bearer',
    bearerFormat: 'JWT',
  ),
);
