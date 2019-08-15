use lib 't';
use Test::APIcast::Blackbox 'no_plan';

$ENV{TEST_NGINX_HTML_DIR} ||= "$Test::Nginx::Util::ServRoot/html";

run_tests();

__DATA__

=== TEST 1: tls accepts configuration
--- env eval
(
    'APICAST_HTTPS_PORT' => "$Test::Nginx::Util::ServerPortForClient",
)
--- configuration
{
  "services": [
    {
      "proxy": {
        "policy_chain": [
          {
            "name": "apicast.policy.tls",
            "configuration": {
              "certificates": [
                {
                  "certificate_path": "$TEST_NGINX_HTML_DIR/server.crt",
                  "certificate_key_path": "$TEST_NGINX_HTML_DIR/server.key"
                }
              ]
            }
          },
          {
            "name": "apicast.policy.upstream",
            "configuration": {
              "rules": [
                {
                  "regex": "/",
                  "url": "http://echo"
                }
              ]
            }
          }
        ]
      }
    }
  ]
}
--- test env
lua_ssl_trusted_certificate $TEST_NGINX_HTML_DIR/server.crt;
content_by_lua_block {
  local function request(path)
    local sock = ngx.socket.tcp()
    sock:settimeout(2000)

    local ok, err = sock:connect(ngx.var.server_addr, ngx.var.apicast_port)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end

    ngx.say("connected: ", ok)

    local sess, err = sock:sslhandshake(nil, "localhost", true)
    if not sess then
        ngx.say("failed to do SSL handshake: ", err)
        return
    end

    ngx.say("ssl handshake: ", type(sess))
    sock:send("GET " .. path .. "?user_key=123 HTTP/1.1\r\nHost: localhost\r\n\r\n")
    local data = sock:receive()
    ngx.say(data)
  end

  request('/')
}
--- response_body
connected: 1
ssl handshake: userdata
HTTP/1.1 200 OK
--- no_error_log
[error]
--- user_files
>>> server.crt
-----BEGIN CERTIFICATE-----
MIIBRzCB7gIJAPHi8uNGM8wDMAoGCCqGSM49BAMCMCwxFjAUBgNVBAoMDVRlc3Q6
OkFQSWNhc3QxEjAQBgNVBAMMCWxvY2FsaG9zdDAeFw0xODA2MDUwOTQ0MjRaFw0y
ODA2MDIwOTQ0MjRaMCwxFjAUBgNVBAoMDVRlc3Q6OkFQSWNhc3QxEjAQBgNVBAMM
CWxvY2FsaG9zdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABI3IZUvpJsaQbiLy
/yfthJDd/+BIaKzAbgMAimth4ePOi3a/YICwsHyq6sBxbgvMeTwxNJIHpe3td4tB
VZ5Wr10wCgYIKoZIzj0EAwIDSAAwRQIhAPRkfbxowt0H7p5xZYpwoMKanUXz9eKQ
0sGkOw+TqqGXAiAMKJRqtjnCF2LIjGygHG6BlgjM4NgIMDHteZPEr4qEmw==
-----END CERTIFICATE-----
>>> server.key
-----BEGIN EC PARAMETERS-----
BggqhkjOPQMBBw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIH22v43xtXcHWJyH3BEB9N30ahrCOLripkoSWW/WujUxoAoGCCqGSM49
AwEHoUQDQgAEjchlS+kmxpBuIvL/J+2EkN3/4EhorMBuAwCKa2Hh486Ldr9ggLCw
fKrqwHFuC8x5PDE0kgel7e13i0FVnlavXQ==
-----END EC PRIVATE KEY-----


=== TEST 2: tls failed on invalid certificate.
--- env eval
(
    'APICAST_HTTPS_PORT' => "$Test::Nginx::Util::ServerPortForClient",
)
--- configuration
{
  "services": [
    {
      "proxy": {
        "policy_chain": [
          {
            "name": "apicast.policy.tls",
            "configuration": {
              "certificates": [
                {
                  "certificate_path": "$TEST_NGINX_HTML_DIR/server.crt_invalid",
                  "certificate_key_path": "$TEST_NGINX_HTML_DIR/server.key"
                }
              ]
            }
          },
          {
            "name": "apicast.policy.upstream",
            "configuration": {
              "rules": [
                {
                  "regex": "/",
                  "url": "http://echo"
                }
              ]
            }
          }
        ]
      }
    }
  ]
}
--- test env
lua_ssl_trusted_certificate $TEST_NGINX_HTML_DIR/server.crt;
content_by_lua_block {
  local function request(path)
    local sock = ngx.socket.tcp()
    sock:settimeout(2000)

    local ok, err = sock:connect(ngx.var.server_addr, ngx.var.apicast_port)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end

    ngx.say("connected: ", ok)

    local sess, err = sock:sslhandshake(nil, "localhost", true)
    if not sess then
        ngx.say("failed to do SSL handshake: ", err)
        return
    end

    ngx.say("ssl handshake: ", type(sess))
    sock:send("GET " .. path .. "?user_key=123 HTTP/1.1\r\nHost: localhost\r\n\r\n")
    local data = sock:receive()
    ngx.say(data)
  end

  request('/')
}
--- response_body
connected: 1
failed to do SSL handshake: handshake failed
--- error_log
ssl3_read_bytes:sslv3 alert handshake failure:SSL
sslv3 alert handshake failure
--- user_files
>>> server.crt
-----BEGIN CERTIFICATE-----
MIIBRzCB7gIJAPHi8uNGM8wDMAoGCCqGSM49BAMCMCwxFjAUBgNVBAoMDVRlc3Q6
OkFQSWNhc3QxEjAQBgNVBAMMCWxvY2FsaG9zdDAeFw0xODA2MDUwOTQ0MjRaFw0y
ODA2MDIwOTQ0MjRaMCwxFjAUBgNVBAoMDVRlc3Q6OkFQSWNhc3QxEjAQBgNVBAMM
CWxvY2FsaG9zdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABI3IZUvpJsaQbiLy
/yfthJDd/+BIaKzAbgMAimth4ePOi3a/YICwsHyq6sBxbgvMeTwxNJIHpe3td4tB
VZ5Wr10wCgYIKoZIzj0EAwIDSAAwRQIhAPRkfbxowt0H7p5xZYpwoMKanUXz9eKQ
0sGkOw+TqqGXAiAMKJRqtjnCF2LIjGygHG6BlgjM4NgIMDHteZPEr4qEmw==
-----END CERTIFICATE-----
>>> server.key
-----BEGIN EC PARAMETERS-----
BggqhkjOPQMBBw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIH22v43xtXcHWJyH3BEB9N30ahrCOLripkoSWW/WujUxoAoGCCqGSM49
AwEHoUQDQgAEjchlS+kmxpBuIvL/J+2EkN3/4EhorMBuAwCKa2Hh486Ldr9ggLCw
fKrqwHFuC8x5PDE0kgel7e13i0FVnlavXQ==
-----END EC PRIVATE KEY-----
