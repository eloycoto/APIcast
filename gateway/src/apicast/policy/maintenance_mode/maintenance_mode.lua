-- This is a simple policy. It allows you reject incoming requests with a
-- specified status code and message.
-- It's useful for maintenance periods or to temporarily block an API

local _M = require('apicast.policy').new('Maintenance mode', 'builtin')

local tonumber = tonumber
local new = _M.new

local default_status_code = 503
local default_message = "Service Unavailable - Maintenance"

function _M.new(configuration)
  local policy = new(configuration)

  policy.status_code = default_status_code
  policy.message = default_message

  if configuration then
    policy.status_code = tonumber(configuration.status) or policy.status_code
    policy.message = configuration.message or policy.message
  end

  return policy
end

function _M:rewrite()
  ngx.status = self.status_code
  ngx.say(self.message)

  return ngx.exit(ngx.status)
end

return _M
