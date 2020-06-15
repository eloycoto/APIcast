local custom_metrics =  require("apicast.policy.custom_metrics")
local ngx_variable = require 'apicast.policy.ngx_variable'
local backend_client = require('apicast.backend_client')
local Usage = require('apicast.usage')


describe('custom metrics policy', function()
  local context = {}
  local usage = {}

  before_each(function()
    ngx.var = {}
    ngx.header = {}

    stub(ngx_variable, 'available_context', function(context) return context end)
    stub(ngx.req, 'get_headers', function() return {} end)
    stub(ngx.resp, 'get_headers', function() return {} end)

    context = { usage = {} }
    stub(context.usage, 'merge', function() return end)

    usage = Usage.new()
    usage:add("foo", 1)
  end)

  it('if Auth cache is disabled, report the usage', function()
      local config = {
        rules = {
          {
            metric = "foo",
            increment = "1",
            condition = {
              combine_op = "and",
              operations = {
                { left = "foo", op = "==", right = "foo" }
              }
            }
          }
        }
      }

      local policy = custom_metrics.new(config)

      stub(policy, "report", function(context, usage) return end)

      policy:post_action(context)
      assert.spy(policy.report).was_called()
      assert.spy(policy.report).was.called_with(context, usage)
  end)

  it('if Auth cache is enabled, usage is incremented', function()
    ngx.var.cached_key = true

    local config = {
      rules = {
        {
          metric = "foo",
          increment = "1",
          condition = {
            combine_op = "and",
            operations = {
              { left = "foo", op = "==", right = "foo" }
            }
          }
        }
      }
    }

    local policy = custom_metrics.new(config)

    stub(policy, "report", function(context, usage) return end)
    policy:post_action(context)
    assert.spy(policy.report).was_not_called()
    assert.spy(context.usage.merge).was_called()

    assert.spy(context.usage.merge).was_called_with(context.usage, usage)

  end)
end)
