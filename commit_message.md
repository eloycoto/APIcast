Policy: logging add custom access log options

Some users requested different ways to log access log with more metadata,
different formats or conditional logging based on multiple request values. 

This policy address this, two new variables are now set, where allow or disallow
to print a custom log message, and another one `extened_access_log` just store
all the information to print that. 

Policy has multiple options, here a few examples:

Custom log format
```
{
  "name": "apicast.policy.logging",
  "configuration": {
    "enable_access_logs": false
    "custom_logging": "\"{{request}}\" to service {{service.id}} and {{service.name}}",
  }
}
```

Only log the entry if status is 200

```
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

This commit fixed #1082 and THREESCALE-1234 and THREESCALE-2876

