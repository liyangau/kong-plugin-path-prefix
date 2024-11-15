# kong-plugin-path-prefix

A Kong plugin that rewrites the upstream request path. This can be useful if you have routes associated to a single service that all share the same path prefix.

For example if you OAS has below paths

```yaml
paths:
  /api/v1/customers/{userID}:
    get:
      description: Returns GET data.
      operationId: /get
      responses: {}
  /api/v1/customers/{userID}/balance:
    post:
      description: Returns POST data.
      operationId: /post
      responses: {}
```

If you use `strip_path=true`, the upstream api services receive `/` for both requests `/api/v1/customers/123456` `/api/v1/customers/123456/balance`

If you use `strip_path=false` the upstream api services receives the full path.

With this plugin, the strip_path on routes is ignored. You can use `config.path_prefix` to strip whatever you like. In this use case, you can configure `config.path_prefix=/api/v1`. You upstream API will get `/customers/123456` and `/customers/123456/balance`.

## Usage

This plugin can be enabled on either a service or routes.

### Schema

| field              | explanation                                                  | default |
| ------------------ | ------------------------------------------------------------ | ------- |
| `path_prefix`      | The prefix shared by all routes associated with the service. | N/A     |
| `escape`           | Whether any hyphens in the path prefix should be escaped     | `true`  |
| `forwarded_header` | Add 'X-Forwarded-Prefix' with 'path_prefix' value            | `false` |

### Versions

The version of Kong that this plugin was last tested against is 3.8.0

## Development

Run `docker compose up` to stand up an instance of Kong with the plugin with a sample kong config `kong.yml`. httpbin.org is used as the upstream.

Some tests has been added in `spec/path-prefix/` folder. To add in more features and tests, please use [Pongo](https://github.com/Kong/kong-pongo).
