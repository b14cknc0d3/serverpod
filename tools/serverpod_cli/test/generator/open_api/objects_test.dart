import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/analyzer/dart/definitions.dart';
import 'package:serverpod_cli/src/generator/open_api/open_api_definition.dart';
import 'package:serverpod_cli/src/generator/open_api/open_api_objects.dart';

import 'package:test/test.dart';

void main() {
  group('Validation of JSON Serialization for All OpenAPI Objects: ', () {
    var security = {
      SecurityRequirementObject(
        name: 'serverpodAuth',
        securitySchemes: HttpSecurityScheme(
          scheme: 'bearer',
          bearerFormat: 'JWT',
        ),
      ),
    };
    LicenseObject licenseObject = LicenseObject(
      name: 'Apache 2.0',
      url: Uri.parse('http://www.apache.org/licenses/LICENSE-2.0.html'),
    );
    ContactObject contactObject = ContactObject(
      name: 'Ye Lin Aung',
      url: Uri.https('serverpod.dev'),
      email: 'example@email.com',
    );
    ServerObject serverObject = ServerObject(
      url: Uri.http('localhost:8080'),
      description: 'Development Server',
    );
    InfoObject infoObject = InfoObject(
      title: 'Swagger Petstore - OpenAPI 3.0',
      version: '1.0.1',
      termsOfService: Uri.parse('http://swagger.io/terms/'),
      description: 'This is a sample Pet Store Server based on the OpenAPI 3.0',
    );
    TagObject tagObject = TagObject(
      name: 'pet',
      description: 'Everything about your Pets',
    );
    ContentObject contentObject = ContentObject(
      responseType: TypeDefinition(
        className: 'Future',
        nullable: false,
        generics: [
          TypeDefinition(
            className: 'String',
            nullable: false,
          ),
        ],
      ),
    );
    ContentObject contentObjectRequest = ContentObject(
      requestContentSchemaObject: RequestContentSchemaObject(
        params: [
          ParameterDefinition(
              name: 'age',
              type: TypeDefinition(className: 'int', nullable: false),
              required: true),
        ],
      ),
    );
    ExternalDocumentationObject object = ExternalDocumentationObject(
      url: Uri.http('swagger.io'),
      description: 'Find out more',
    );
    OperationObject post = OperationObject(
      security: security,
      parameters: [],
      tags: ['pet'],
      operationId: 'getPetById',
      requestBody: RequestBodyObject(
        parameterList: [
          ParameterDefinition(
              name: 'id',
              type: TypeDefinition(className: 'int', nullable: false),
              required: true),
        ],
      ),
      responses: ResponseObject(
        responseType: TypeDefinition(
          className: 'Pet',
          nullable: true,
        ),
      ),
    );
    PathItemObject pathItemObject = PathItemObject(
      summary: 'Summary',
      description: 'Description',
      postOperation: post,
    );
    PathsObject pathsObject = PathsObject(
      pathName: '/api/v1/',
      path: pathItemObject,
    );
    ComponentsObject componentsObject = ComponentsObject(securitySchemes: {
      serverpodAuth
    }, schemas: {
      ComponentSchemaObject(
        ClassDefinition(
            fileName: 'example.dart',
            sourceFileName: '',
            className: 'Example',
            fields: [
              SerializableEntityFieldDefinition(
                  name: 'name',
                  type: TypeDefinition(className: 'String', nullable: false),
                  scope: EntityFieldScopeDefinition.all,
                  shouldPersist: true)
            ],
            serverOnly: true,
            isException: false),
      )
    });
    test(
      'Validate Info Object',
      () {
        expect(
          {
            'title': 'Swagger Petstore - OpenAPI 3.0',
            'termsOfService': 'http://swagger.io/terms/',
            'version': '1.0.1',
            'description':
                'This is a sample Pet Store Server based on the OpenAPI 3.0'
          },
          infoObject.toJson(),
        );
      },
    );

    test('Validate License Object', () {
      expect(
        {
          'name': 'Apache 2.0',
          'url': 'http://www.apache.org/licenses/LICENSE-2.0.html'
        },
        licenseObject.toJson(),
      );
    });

    test('Validate Contact Object', () {
      expect(
        {
          'name': 'Ye Lin Aung',
          'url': 'https://serverpod.dev',
          'email': 'example@email.com',
        },
        contactObject.toJson(),
      );
    });

    test('Validate ServerObject with null variables', () {
      expect(
        {
          'url': 'http://localhost:8080',
          'description': 'Development Server',
        },
        serverObject.toJson(),
      );
    });

    test('Validate TagObject', () {
      expect({
        'name': 'pet',
        'description': 'Everything about your Pets',
      }, tagObject.toJson());
    });

    test('Validate ExternalDocumentation Object', () {
      expect({'description': 'Find out more', 'url': 'http://swagger.io'},
          object.toJson());
    });

    test(
      'Validate Content Object With Response',
      () {
        expect({
          'application/json': {
            'schema': {'type': 'string'}
          },
        }, contentObject.toJson());
      },
    );
    test(
      'Validate Content Object with Request',
      () {
        expect({
          'application/json': {
            'schema': {
              'type': 'object',
              'properties': {
                'age': {'type': 'integer'}
              },
            },
          },
        }, contentObjectRequest.toJson());
      },
    );

    test('Validate OperationObject', () {
      expect({
        'tags': ['pet'],
        'operationId': 'getPetById',
        'requestBody': {
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
                'properties': {
                  'id': {'type': 'integer'}
                }
              }
            }
          },
          'required': true
        },
        'responses': {
          '200': {
            'description': 'Success',
            'content': {
              'application/json': {
                'schema': {
                  '\$ref': '#/components/schemas/Pet',
                }
              }
            }
          },
          '400': {
            'description':
                'Bad request (the query passed to the server was incorrect).'
          },
          '403': {
            'description':
                "Forbidden (the caller is trying to call a restricted endpoint, but doesn't have the correct credentials/scope)."
          },
          '500': {'description': 'Internal server error '}
        },
        'security': [
          {'serverpodAuth': []}
        ],
      }, post.toJson());
    });

    test('Validate PathItemObject', () {
      expect({
        'summary': 'Summary',
        'description': 'Description',
        'post': {
          'tags': ['pet'],
          'operationId': 'getPetById',
          'requestBody': {
            'content': {
              'application/json': {
                'schema': {
                  'type': 'object',
                  'properties': {
                    'id': {'type': 'integer'}
                  }
                }
              }
            },
            'required': true
          },
          'responses': {
            '200': {
              'description': 'Success',
              'content': {
                'application/json': {
                  'schema': {
                    '\$ref': '#/components/schemas/Pet',
                  }
                }
              }
            },
            '400': {
              'description':
                  'Bad request (the query passed to the server was incorrect).'
            },
            '403': {
              'description':
                  "Forbidden (the caller is trying to call a restricted endpoint, but doesn't have the correct credentials/scope)."
            },
            '500': {'description': 'Internal server error '}
          },
          'security': [
            {'serverpodAuth': []}
          ],
        },
      }, pathItemObject.toJson());
    });

    test('Validate ServerObject', () {
      expect(
        {
          'url': 'http://localhost:8080',
          'description': 'Development Server',
        },
        serverObject.toJson(),
      );
    });
    test('Validate PathsObject', () {
      expect({
        '/api/v1/': {
          'summary': 'Summary',
          'description': 'Description',
          'post': {
            'tags': ['pet'],
            'operationId': 'getPetById',
            'requestBody': {
              'content': {
                'application/json': {
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'id': {'type': 'integer'}
                    }
                  }
                }
              },
              'required': true
            },
            'responses': {
              '200': {
                'description': 'Success',
                'content': {
                  'application/json': {
                    'schema': {
                      '\$ref': '#/components/schemas/Pet',
                    }
                  }
                }
              },
              '400': {
                'description':
                    'Bad request (the query passed to the server was incorrect).'
              },
              '403': {
                'description':
                    "Forbidden (the caller is trying to call a restricted endpoint, but doesn't have the correct credentials/scope)."
              },
              '500': {'description': 'Internal server error '}
            },
            'security': [
              {'serverpodAuth': []}
            ],
          },
        },
      }, pathsObject.toJson());
    });
    test('Validate ComponentObject', () {
      expect(
        {
          'schemas': {
            'Example': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'}
              }
            }
          },
          'securitySchemes': {
            'serverpodAuth': {
              'type': 'http',
              'scheme': 'bearer',
              'bearerFormat': 'JWT'
            }
          }
        },
        componentsObject.toJson(),
      );
    });
    test('Validate OpenApi', () {
      var openApi = OpenApiDefinition(
          info: infoObject,
          servers: {serverObject},
          tags: {tagObject},
          paths: {pathsObject},
          components: componentsObject);
      expect(
        {
          'openapi': '3.0.0',
          'info': {
            'title': 'Swagger Petstore - OpenAPI 3.0',
            'version': '1.0.1',
            'description':
                'This is a sample Pet Store Server based on the OpenAPI 3.0',
            'termsOfService': 'http://swagger.io/terms/'
          },
          'servers': [
            {
              'url': 'http://localhost:8080',
              'description': 'Development Server'
            }
          ],
          'tags': [
            {'name': 'pet', 'description': 'Everything about your Pets'}
          ],
          'paths': {
            '/api/v1/': {
              'summary': 'Summary',
              'description': 'Description',
              'post': {
                'operationId': 'getPetById',
                'tags': ['pet'],
                'requestBody': {
                  'content': {
                    'application/json': {
                      'schema': {
                        'type': 'object',
                        'properties': {
                          'id': {'type': 'integer'}
                        }
                      }
                    }
                  },
                  'required': true
                },
                'security': [
                  {'serverpodAuth': []}
                ],
                'responses': {
                  '200': {
                    'description': 'Success',
                    'content': {
                      'application/json': {
                        'schema': {'\$ref': '#/components/schemas/Pet'}
                      }
                    }
                  },
                  '400': {
                    'description':
                        'Bad request (the query passed to the server was incorrect).'
                  },
                  '403': {
                    'description':
                        'Forbidden (the caller is trying to call a restricted endpoint, but doesn\'t have the correct credentials/scope).'
                  },
                  '500': {'description': 'Internal server error '}
                }
              }
            }
          },
          'components': {
            'schemas': {
              'Example': {
                'type': 'object',
                'properties': {
                  'name': {'type': 'string'}
                }
              }
            },
            'securitySchemes': {
              'serverpodAuth': {
                'type': 'http',
                'scheme': 'bearer',
                'bearerFormat': 'JWT'
              }
            }
          }
        },
        openApi.toJson(),
      );
    });
  });
}
