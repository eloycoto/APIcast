local LoggingPolicy = require('apicast.policy.logging')
local ngx_variable = require('apicast.policy.ngx_variable')

describe('Logging policy', function()
  describe('.log', function()
    before_each(function()
      ngx.var = {}
    end)

    context('when access logs are enabled', function()
      it('sets ngx.var.access_logs_enabled to "1"', function()
        local logging = LoggingPolicy.new({ enable_access_logs = true })

        logging:log()

        assert.equals('1', ngx.var.access_logs_enabled)
      end)
    end)

    context('when access logs are disabled', function()
      it('sets ngx.var.enable_access_logs to "0"', function()
        local logging = LoggingPolicy.new({ enable_access_logs = false })

        logging:log()

        assert.equals('0', ngx.var.access_logs_enabled)
      end)
    end)

    context('when access logs are not configured', function()
      it('enables them by default by setting ngx.var.enable_access_logs to "1"', function()
        local logging = LoggingPolicy.new({})

        logging:log()

        assert.equals('1', ngx.var.access_logs_enabled)
      end)
    end)
  end)

  describe("Extened log", function()
    local ctx = { service = {id=123} }
    before_each(function()
      ngx.var = {foo = "fooValue"}
      stub(ngx.req, 'get_headers', function() return { } end)
      stub(ngx.resp, 'get_headers', function() return { } end)
      stub(ngx_variable, 'available_context', function(ctx) return ctx end)
    end)

    it("Default access log is disabled when is defined", function()
      local logging = LoggingPolicy.new({custom_logging="foo"})
      logging:log(ctx)
      assert.equals(0, ngx.var.access_logs_enabled)
      assert.equals(1, ngx.var.extended_access_logs_enabled)
      assert.equals("foo", ngx.var.extended_access_log)
    end)

    it("log message render information from context and ngx.var", function()

      local logging = LoggingPolicy.new({
        custom_logging=">>{{foo}}::{{service.id}}"
      })
      logging:log(ctx)
      assert.equals(0, ngx.var.access_logs_enabled)
      assert.equals(1, ngx.var.extended_access_logs_enabled)
      assert.equals(">>fooValue::123", ngx.var.extended_access_log)
    end)

    describe("Conditions", function()    
      
      it("Conditions only log if matches", function()
        local logging = LoggingPolicy.new({
          custom_logging = "foo",
          condition = {
            operations={{op="==", match="{{ foo }}", match_type="liquid", value="fooValue", value_type="plain"}},
            combine_op="and"
          }})
        logging:log(ctx)
        assert.equals(0, ngx.var.access_logs_enabled)
        assert.equals(1, ngx.var.extended_access_logs_enabled)
        assert.equals("foo", ngx.var.extended_access_log)
      end)

      it("Validate default combine_op", function()
        local logging = LoggingPolicy.new({
          custom_logging = "foo",
          condition = {
            operations={{op="==", match="{{ foo }}", match_type="liquid", value="fooValue", value_type="plain"}}
          }})
        logging:log(ctx)
        assert.equals(0, ngx.var.access_logs_enabled)
        assert.equals(1, ngx.var.extended_access_logs_enabled)
        assert.equals("foo", ngx.var.extended_access_log)
      end)

      it("Or combination match one", function()
        local logging = LoggingPolicy.new({
          custom_logging = "foo",
          condition = {
            operations={
              {op="==", match="{{ invalid }}", match_type="liquid", value="fooValue", value_type="plain"},
              {op="==", match="{{ foo }}", match_type="liquid", value="fooValue", value_type="plain"}
            },
            combine_op="or"
          }})
        logging:log(ctx)
        assert.equals(0, ngx.var.access_logs_enabled)
        assert.equals(1, ngx.var.extended_access_logs_enabled)
        assert.equals("foo", ngx.var.extended_access_log)
      end) 

      it("No Match combination", function()
        local logging = LoggingPolicy.new({
          custom_logging = "foo",
          condition = {
            operations={{op="==", match="{{ invalid }}", match_type="liquid", value="fooValue", value_type="plain"}},
            combine_op="and"
          }})
        logging:log(ctx)
        assert.equals(0, ngx.var.access_logs_enabled)
        assert.equals(0, ngx.var.extended_access_logs_enabled)
        assert.is_nil(ngx.var.extended_access_log)
      end)
    end)



  end)
end)
