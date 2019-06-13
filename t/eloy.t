use lib 't';
use Test::APIcast 'no_plan';

$ENV{APICAST_CONFIGURATION_LOADER} = 'lazy';

run_tests();

__DATA__

=== TEST 1: load invalid json
should correctly route the request
--- main_config
env THREESCALE_PORTAL_ENDPOINT=http://127.0.0.1:$TEST_NGINX_SERVER_PORT/;
env APICAST_CONFIGURATION_LOADER=lazy;
--- http_config
  include $TEST_NGINX_UPSTREAM_CONFIG;
  lua_package_path "$TEST_NGINX_LUA_PATH";
--- config
  include $TEST_NGINX_APICAST_CONFIG;
  include $TEST_NGINX_BACKEND_CONFIG;

  location = /admin/api/nginx/spec.json {
    try_files /config.json =404;
  }

  location /api/ {
    echo "all ok";
  }
--- request
GET /t?user_key=fake
--- error_code: 404
--- user_files
>>> config.json
{Hello, world}
--- no_error_log
[error]
