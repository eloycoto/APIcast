local policy = require('apicast.policy')
local _M = policy.new('JWT check policy')

local TemplateString = require 'apicast.template_string'
local Operation = require('apicast.conditions.operation')
-- local Condition = require('apicast.conditions.condition')

local new = _M.new
local inspect = require("inspect")

local default_error_message = "Request block due JWT claim policy"

local function deny_request(error_msg)
  ngx.status = ngx.HTTP_FORBIDDEN
  ngx.say(error_msg)
  ngx.exit(ngx.status)
end


function verdict(check_type, status)
  -- Default whitelist mode, if not valid using whitelist
  if check_type == "blacklist" then
    return not status
  end

  return status
end

function _M.new(config)
  local self = new(config)
  local conf = config or {}
  self.error_message = config.error_message or default_error_message

  self.conditions = {}
  for _,condition in ipairs(config.operations) do
    table.insert(self.conditions, {
      op = Operation.new(condition.match, condition.match_type or "liquid", condition.op, condition.value, 'liquid'),
      check_type = condition.check_type})
  end
  return self
end


function _M:access(context)
  for _,policy in ipairs(self.conditions) do
    local result = policy.op:evaluate(context.jwt)
    if not verdict(policy.check_type, result) then
      return deny_request(self.error_message)
    end
  end
end

return _M
