part of '../open_api_objects.dart';

/// The [InfoObject] is used to provide metadata and information about the API.
/// eg.
/// ```
///     {
///       "title": "Sample Pet Store App",
///       "summary": "A pet store manager.",
///       "description": "This is a sample server for a pet store.",
///       "termsOfService": "https://example.com/terms/",
///       "contact": {
///         "name": "API Support",
///         "url": "https://www.example.com/support",
///         "email": "support@example.com"
///       },
///       "license": {
///         "name": "Apache 2.0",
///         "url": "https://www.apache.org/licenses/LICENSE-2.0.html"
///       },
///       "version": "1.0.1"
///     }
/// ```
class InfoObject {
  final String title;

  /// A short summary of the API.
  final String? summary;

  /// A description of the API.
  /// CommonMark syntax may be used for rich text representation.
  final String? description;

  /// A URL to the Terms of Service for the API.
  final Uri? termsOfService;

  /// Contact information for the exposed API.
  final ContactObject? contact;

  /// License information for the exposed API.
  final LicenseObject? license;

  /// The version of the OpenAPI document
  /// (which is distinct from the OpenAPI Specification version or
  /// the API implementation version).
  final String version;
  InfoObject({
    required this.title,
    this.summary,
    this.description,
    this.termsOfService,
    this.contact,
    this.license,
    required this.version,
  });

  factory InfoObject.fromJson(Map<String, dynamic> map) {
    return InfoObject(
      title: map['title'],
      version: map['version'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'title': title,
      'version': version,
    };
    if (summary != null) {
      map['summary'] = summary;
    }
    if (description != null) {
      map['description'] = description;
    }
    if (contact != null) {
      map['contact'] = contact?.toJson();
    }
    if (license != null) {
      map['license'] = license?.toJson();
    }
    if (termsOfService != null) {
      map['termsOfService'] = termsOfService?.toString();
    }
    return map;
  }
}

/// Information about the license governing the use of the API.
/// example
///```json
///  {
///   "name": "Apache 2.0",
///   "identifier": "Apache-2.0"
///  }
///```
class LicenseObject {
  /// The license name used for the API.
  final String name;

  /// A URL to the license used for the API.
  /// This must be in the form of a URL.
  /// The url field is mutually exclusive of the identifier field.
  final Uri? url;
  LicenseObject({
    required this.name,
    this.url,
  });

  Map<String, String> toJson() {
    var map = {
      'name': name,
    };
    if (url != null) {
      map['url'] = url.toString();
    }
    return map;
  }

  factory LicenseObject.fromJson(Map<String, dynamic> map) {
    return LicenseObject(
      name: map['name'] as String,
      url: map['url'] != null ? Uri.parse(map['url']) : null,
    );
  }
}

/// Information about the organization or individual responsible for the API.
/// example.
///```json
/// {
///     "name": "API Support",
///     "url": "https://www.example.com/support",
///     "email": "support@example.com"
/// }
///
///```
///
class ContactObject {
  /// The identifying name of the contact person/organization.
  final String name;

  /// The URL pointing to the contact information.
  final Uri url;

  /// The email address of the contact person/organization.
  final String email;
  ContactObject({
    required this.name,
    required this.url,
    required this.email,
  });

  Map<String, String> toJson() {
    return {
      'name': name,
      'url': url.toString(),
      'email': email,
    };
  }

  factory ContactObject.fromJson(Map<String, dynamic> map) {
    return ContactObject(
      name: map['name'] as String,
      url: Uri.parse(map['url'] as String),
      email: map['email'] as String,
    );
  }
}

/// Allows referencing an external resource for extended documentation.
/// ```json
/// {
///   "description": "Find more info here",
///   "url": "https://example.com"
/// }
/// ```
class ExternalDocumentationObject {
  final String? description;
  final Uri url;
  ExternalDocumentationObject({
    this.description,
    required this.url,
  });

  Map<String, String> toJson() {
    var map = {'url': url.toString()};
    if (description != null) {
      map['description'] = description!;
    }
    return map;
  }

  factory ExternalDocumentationObject.fromJson(Map<String, dynamic> map) {
    return ExternalDocumentationObject(
      url: Uri.parse(map['url'] as String),
      description:
          map['description'] != null ? map['description'] as String : null,
    );
  }
}
