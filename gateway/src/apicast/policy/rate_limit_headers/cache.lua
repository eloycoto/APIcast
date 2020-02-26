local lrucache = require("resty.lrucache")
local cache_entry = require("apicast.policy.rate_limit_headers.cache_entry")

local _M = {}

local mt = { __index = _M }
local default_namespace = "rate_limit_namespace"


function _M.new(size, namespace)
  local cache_size = tonumber(size) or 1000
  local self = setmetatable({}, mt)
  local cache, err = lrucache.new(cache_size)
  if err then
      ngx.log(ngx.ERR, "Cannot start cache for usage metrics, err=", err)
      return err
  end
  self.cache = cache
  self.namespace = namespace or default_namespace
  return self
end

function _M:get_key(usage)
  return self.namespace .. "::".. usage:encoded_format()
end

function _M:decrement_usage_metric(usage)
    if not usage then
        return cache_entry.Init_empty(usage)
    end

    local key = self:get_key(usage)
    local data = self.cache:get(key)

    if not data then
        -- If it's here should not, because this should be called in the
        -- post_action, so return an empty one0
        return cache_entry.Init_empty(usage)
    end
    -- data:decrement(delta)
    -- Take care here, delta can be from usage.delta

    data:decrement(1)
    self.cache:set(key, data)
    return data
end

function _M:reset_or_create_usage_metric(usage, max, remaining, reset)
    local key = self:get_key(usage)
    local data = cache_entry.new(usage, max, remaining, reset)
    self.cache:set(key, data)
    return data
end

return _M
