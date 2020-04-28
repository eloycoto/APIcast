# Custom metrics policies

This policy adds the availability to add metrics after the Upstream API
response.  The main use case for this policy is to add metrics based on response
code status, headers or different Nginx variables.

## Caveats:

Due to this needs some information from the upstream API, if the authrep with
backend happens before the upstream call (Is not cached) the metric will not be
incremented. This policy only increments metrics when the authrep is cached.

This policy does not work with batching policy.

## Configuration examples

This policy increments the metric error, by the header increment, if the
Upstream API returns a 400 status:

```
{
  "name": "apicast.policy.custom_metrics",
  "configuration": {
    "rules": [
      {
        "metric": "error",
        "increment": "{{ resp.headers['increment'] }}",
        "condition": {
          "operations": [
            {
              "right": "{{status}}",
              "right_type": "liquid",
              "left": "400",
              "op": "=="
            }
          ],
          "combine_op": "and"
        }
      }
    ]
  }
}
```

Increment the `hits` metric with the information status_code information if the
Upstream API return a 200 status:

```
{
  "name": "apicast.policy.custom_metrics",
  "configuration": {
    "rules": [
      {
        "metric": "hits_{{status}}",
        "increment": "1",
        "condition": {
          "operations": [
            {
              "right": "{{status}}",
              "right_type": "liquid",
              "left": "200",
              "op": "=="
            }
          ],
          "combine_op": "and"
        }
      }
    ]
  }
}
```


