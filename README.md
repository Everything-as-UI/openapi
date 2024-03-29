# openapi

Code generation tool for OpenAPI based on SwiftLangUI.

__Parameters:__
- <openapi_spec> - path/url to openapi specification file;  
- [--config <file_path>] - path to json/yaml configuration file;

__Configuration file:__

```yaml
filter: Bool # generate only defined models, default: `false`
accessLevel: String? # access control modifier for generated models, default is `public`
imports: [String] # modules that need import in generated file 
models:
  rename: String? # rename model type name
  filter: Bool # generate only defined properties, default: `false`
  commentFiltered: Bool # render other properties as comment, default: `false`
  accessLevel: String? # access control modifier for generated properties, default is `public`
  conformances: [String] # protocols that need to conform, default: `["Codable"]`
  properties:
    rename: String? # rename property
    renameType: String? # rename property type
    optional: Bool? # override optionality
  customProperties: # properties are not defined in specification, format is the same as in `properties`
```
