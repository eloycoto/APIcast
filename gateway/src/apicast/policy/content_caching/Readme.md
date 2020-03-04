# APICast Policy caching

This policy allows to enable/disable caching based on a custom conditions. These
conditions can only be applied on the client request, where upstream responses
cannot be used in this policy.


## Example configuration

```
{
  "name": "apicast.policy.content_caching",
  "version": "builtin",
  "configuration": {
    "rules": [
      {
        "cache": true,
        "header": "X-Cache-Status-POLICY",
        "condition": {
          "combine_op": "and",
          "operations": [
            {
              "left": "{{method}}",
              "left_type": "liquid",
              "op": "==",
              "right": "GET"
            }
          ]
        }
      }
    ]
  }
}
```

## Recommended configuration

- For POST/PUT/DELETE method, the recommendation is not have this enabled.
- If one condition matches, and it enables the cache, the execution will be
  stopped and it'll be not disabled. Sort by priority is important here.

## Upstream response headers

At the moment, nginx [`proxy_cache_valid`
directive](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache_valid)
information can only be set globally, with the `APICAST_CACHE_STATUS_CODES` and
`APICAST_CACHE_MAX_TIME`. If your upstream need to have a different behavior
regarding timeouts, the [`Cache-control`
header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control)
can be used and users can take advantage of that.

