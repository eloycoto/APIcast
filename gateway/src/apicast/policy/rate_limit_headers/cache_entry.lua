local now = ngx.now

local counter = require "resty.counter"
local countdown_counter =  require("apicast.policy.rate_limit_headers.countdown_counter")

local _M = {}
local mt = { __index = _M }

function _M.new(usage, max, remaining, reset)
  local self = setmetatable({}, mt)

  self.usage = usage
  self:reset(max, remaining, reset)

  return self
end

function _M.Init_empty(usage)
  local self = setmetatable({}, mt)

  self.usage = usage
  self:reset(0, 0, now())
  return self
end

function _M:decrement(delta)
    self.remaining:decrement(delta)
end

function _M:dump_data()
    return {
        limit = self.limit:__tostring(),
        remaining = self.remaining:__tostring(),
        reset = self.reset:remaining_secs_positive(now()),
    }
end

function _M:reset(max, remaining, reset)
  self.limit = counter.new(max)
  self.remaining = counter.new(remaining)
  self.reset = countdown_counter.new(reset, now())
end

return _M
