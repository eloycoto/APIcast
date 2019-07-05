{
  "$schema": "http://apicast.io/policy-v1/schema#manifest#",
  "name": "logging",
  "summary": "Enable or disable default or custom access log",
  "description": [
    "This policy allows the service to write custom acess log for the specific",
    "service, where the variables need to be written using liquid format and log",
    "entries can be disabled based on conditional operations"
  ],
  "version": "builtin",
  "configuration": {
    "definitions": {
      "value_type": {
        "$id": "#/definitions/value_type",
        "type": "string",
        "oneof": [
          {
            "enum": [
              "plain"
            ],
            "title": "evaluate as plain text."
          },
          {
            "enum": [
              "liquid"
            ],
            "title": "evaluate as liquid."
          }
        ]
      }
    },
    "type": "object",
    "properties": {
      "enable_access_logs": {
        "title": "Enable access logs",
        "description": "This option enables the output of the default access log for this service",
        "type": "boolean"
      },
      "custom_logging": {
        "title": "Custom logging format",
        "description": "A string variable that uses liquid templating to render a custom access log entry. All Nginx variables can be used plus per service entries",
        "type": "string"
      },
      "condition": {
        "type": "object",
        "properties": {
          "operations": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "op": {
                  "description": "Match operation to compare match field with the provided value",
                  "type": "string",
                  "enum": [
                    "==",
                    "!=",
                    "matches"
                  ]
                },
                "match": {
                  "description": "String to get request information to match",
                  "type": "string"
                },
                "match_type": {
                  "description": "How to evaluate 'match' value",
                  "$ref": "#/definitions/value_type"
                },
                "value": {
                  "description": "Value to compare the retrieved match",
                  "type": "string"
                },
                "value_type": {
                  "description": "How to evaluate 'jwt_claim' value",
                  "$ref": "#/definitions/value_type"
                }
              },
              "required": [
                "op",
                "match",
                "match_type",
                "value",
                "value_type"
              ]
            }
          },
          "combine_op": {
            "type": "string",
            "enum": [
              "and",
              "or"
            ],
            "default": "and"
          }
        }
      }
    }
  }
}
