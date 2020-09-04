# Response/Request content limits policy

This policy enables response and request content limits based on the
Content-size header.


If the values are 0, means that no limit is applied.

## Examples:

Limit request content size to 1000 bytes.

```
  {
    "name": "apicast.policy.limits",
    "configuration": {
      "request": 1000,
      "response": 0
    }
  },
```
