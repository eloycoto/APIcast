--- Logging policy

local _M  = require('apicast.policy').new('Logging Policy')
local new = _M.new

local Condition = require('apicast.conditions.condition')
local LinkedList = require('apicast.linked_list')
local Operation = require('apicast.conditions.operation')
local TemplateString = require('apicast.template_string')

-- Defined in ngx.conf.liquid and used in the 'access_logs' directive.
local ngx_var_access_logs_enabled = 'access_logs_enabled'
local ngx_var_extended_access_logs_enabled = 'extended_access_logs_enabled'
local ngx_var_extended_access_log = 'extended_access_log'

local default_enable_access_logs = true
local default_template_type = 'plain'

-- Returns the value for the ngx var above from a boolean that indicates
-- whether access logs are enabled or not.
local val_for_ngx_var ={
  [true] = '1',
  [false] = '0'
}

function _M.new(config)
  local self = new(config)

  local enable_access_logs = config.enable_access_logs
  if enable_access_logs == nil then -- Avoid overriding when it's false.
    enable_access_logs = default_enable_access_logs
  end

  if not enable_access_logs then
    ngx.log(ngx.DEBUG, 'Disabling access logs')
  end

  self.enable_access_logs_val = val_for_ngx_var[enable_access_logs]
  self.custom_logging = config.custom_logging
  if config.condition then
    ngx.log(ngx.DEBUG, 'Enabling extended log with conditions')
    local operations = {}
    for _, operation in ipairs(config.condition.operations) do
      table.insert( operations,
        Operation.new(
          operation.match, operation.match_type,
          operation.op,
          operation.value, operation.value_type or default_template_type))
    end
    self.condition = Condition.new( operations, config.condition.combine_op)
  end

  return self
end

function get_request_context(context)
  local ctx = { }
  ctx.req = {
    headers=ngx.req.get_headers(),
  }

  ctx.resp = {
    headers=ngx.resp.get_headers(),
  }

  ctx.service = context.service or {}
  return LinkedList.readonly(ctx, ngx.var)
end

function _M:log(context)
  ngx.var[ngx_var_access_logs_enabled] = self.enable_access_logs_val
  if not self.custom_logging then
    return
  end

  -- Extended log is now enaled, disable the default access_log
  ngx.var[ngx_var_access_logs_enabled] = 0
  
  local extended_context = get_request_context(context or {})
  if self.condition and not self.condition:evaluate(extended_context) then
    -- Access log is disabled here, request does not match, so log is disabled
    -- for this request
    ngx.var[ngx_var_extended_access_logs_enabled] = 0
    return
  end

  ngx.var[ngx_var_extended_access_logs_enabled] = 1
  local tmpl = TemplateString.new(self.custom_logging, "liquid")
  ngx.var[ngx_var_extended_access_log] = tmpl:render(extended_context)
end

return _M
