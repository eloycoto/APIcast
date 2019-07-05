# Logging policy

This policy has two primary purposes: one is to enable and disable access log
output, and the second one is to be able to create a custom access log format
for each service and be able to set conditions to write custom access log. 


## Exported variables

Liquid templating can be used on custom logging, the exported variables are:

- NGINX default log_format directive variables, as example: `{{remote_addr}}`.
[Log format documentation](http://nginx.org/en/docs/http/ngx_http_log_module.html). 

- Response and request headers using `{{req.headers.FOO}}` for getting FOO
header in the request, or `{{res.headers.FOO}}` to retrieve FOO header on
response.
- Service information, as `{{service.id}}` and all service propertias as the
`THREESCALE_CONFIG_FILE` parameter provided

## Caveats

- If `custom_logging` property is enabled, default access log will be dissabled.

## Examples

### Disable access log:

```json
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
  }
}
```

### Enable custom access log:

```json
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
    "custom_logging": "[{{time_local}}] {{host}}:{{server_port}} {{remote_addr}}:{{remote_port}} \"{{request}}\" {{status}} {{body_bytes_sent}} ({{request_time}}) {{post_action_impact}}",
  }
}
```

### Enable custom access log with the service ID:
```json
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
    "custom_logging": "\"{{request}}\" to service {{service.id}} and {{service.name}}",
  }
}
```

### Write access log in JSON format:

```json
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
    "custom_logging": "{\"time_local\": \"{{time_local}}\", \"host\" : \"{{host}}\"}",
  }
}
```

### Write a custom access log only for a successful request.

```json
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
    "custom_logging": "\"{{request}}\" to service {{service.id}} and {{service.name}}",
    "condition": {
      "operations": [
        {"op": "==", "match": "{{status}}", "match_type": "liquid", "value": "200"}
      ],
      "combine_op": "and"
    }
  }
}
```

### Write a custom access log where reponse status match 200 or 500.

```json
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
    "custom_logging": "\"{{request}}\" to service {{service.id}} and {{service.name}}",
    "condition": {
      "operations": [
        {"op": "==", "match": "{{status}}", "match_type": "liquid", "value": "200"},
        {"op": "==", "match": "{{status}}", "match_type": "liquid", "value": "500"}
      ],
      "combine_op": "or"
    }
  }
}
```
