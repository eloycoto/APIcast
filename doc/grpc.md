# GRPC on APICast

On Apicast 3.8 full HTTP2 protocol is supported, this enable APICast to handle
GRPC connections end to end taking care APICast about Authentication, headers
modification, etc..

HTTP2 is only enabled in the TLS port, and it’s not enabled in the plaintext
port. The main reason why is only enabled in TLS is to make sure that both HTTP
1.1 and HTTP2 protocols are supported. ALPN(Application-Layer Protocol
Negotiation) decides within the TLS hello exchanges what protocol should be
used. HTTP2 always takes precedence.

For authentication, headers authentication or openID (Json Web tokens)  is
highly recommended, so it’ll be more transparent for the GRPC endpoints and it’s
easy to add in the GRPC clients.

The GRPC endpoint server should also listen in TLS, MTLS can be enabled or not,
but the endpoint should finish TLS connections to be able to work as expected.

The only work needed in APICast to enable full GRPC traffic is to enable the
GRPC policy in the given service, so the protocol used will be full HTTP2. This
is because nginx directive does not support ALPN at all.

### Minimal APIcast configuration

```
    {
      "services": [
        {
          "id": 200,
          "backend_version":  1,
          "backend_authentication_type": "service_token",
          "backend_authentication_value": "token-value",
          "proxy": {
            "credentials_location": "headers",
            "hosts": [
              "apicast-service"
            ],
            "api_backend": "https://grpc-service:443",
            "proxy_rules": [
              {
                "pattern": "/",
                "http_method": "GET",
                "metric_system_name": "hits",
                "delta": 1
              },
              {
                "pattern": "/",
                "http_method": "POST",
                "metric_system_name": "hits",
                "delta": 1
              }
            ],
            "policy_chain": [
              {
                "name": "apicast.policy.tls",
                "configuration": {
                  "certificates": [
                    {
                      "certificate_path": "/gateway/apicast-service.crt",
                      "certificate_key_path": "/gateway/apicast-service.key"
                    }
                  ]
                }
              },
              {
                "name": "apicast.policy.grpc"
              },
              {
                "name": "apicast.policy.apicast"
              }
            ]
          }
        }
      ]
    }
```

### GRPC client information

- Server TLS listener

Example using golang:

```
	creds, err := credentials.NewServerTLSFromFile(*cert, *key)
	if err != nil {
		log.Fatalf("Failed to setup TLS: %v", err)
	}

	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer(grpc.Creds(creds))

```

Client header metadata using golang:

This piece adds metadata as headers, the main reason for using this is to send
the credentials in header, so it's easy to read.

```

	md := metadata.Pairs("user_key", *user_key)
	ctx := metadata.NewOutgoingContext(context.Background(), md)
	ctx, cancel := context.WithTimeout(ctx, time.Second)
```
