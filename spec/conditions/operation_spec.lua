local Operation = require('apicast.conditions.operation')
local ngx_variable = require('apicast.policy.ngx_variable')

describe('Operation', function()
  before_each(function()
    -- avoid stubbing all the ngx.var.* and ngx.req.* in the available context
    stub(ngx_variable, 'available_context', function(context) return context end)
  end)

  describe('.new', function()
    it('raises error with an unsupported operation', function()
      local res, err = pcall(Operation.new, '1', 'plain', '<>', '1', 'plain')

      assert.is_falsy(res)
      assert.is_truthy(err)
    end)
  end)

  describe('.evaluate', function()
    it('evaluates ==', function()
      assert.is_true(Operation.new('1', 'plain', '==', '1', 'plain'):evaluate({}))
      assert.is_false(Operation.new('1', 'plain', '==', '2', 'plain'):evaluate({}))
    end)

    it('evaluates !=', function()
      assert.is_true(Operation.new('1', 'plain', '!=', '2', 'plain'):evaluate({}))
      assert.is_false(Operation.new('1', 'plain', '!=', '1', 'plain'):evaluate({}))
    end)

    it('evaluates "matches"', function()
      assert.is_true(
        Operation.new('something_abc_something', 'plain', 'matches', '.*_abc_.*', 'plain')
                 :evaluate({})
      )

      assert.is_false(
        Operation.new('something_abc_something', 'plain', 'matches', 'abc_$', 'plain')
                 :evaluate({})
      )

      assert.is_true(
        Operation.new('12345', 'plain', 'matches', '^123', 'plain')
                 :evaluate({})
      )

      assert.is_false(
        Operation.new('abc', 'plain', 'matches', '^123', 'plain')
                 :evaluate({})
      )
    end)

    it('evaluates values as plain text by default', function()
      assert.is_true(Operation.new('1', nil, '==', '1', nil):evaluate({}))
      assert.is_false(Operation.new('1', nil, '==', '2', nil):evaluate({}))
    end)

    it('evaluates liquid when indicated in the types', function()
      local context = { var_1 = '1', var_2 = '2' }

      local res_true = Operation.new(
        '{{ var_1 }}', 'liquid', '==', '1', 'plain'
      ):evaluate(context)

      assert.is_true(res_true)

      local res_false = Operation.new(
        '{{ var_1 }}', 'liquid', '==', '{{ var_2 }}', 'liquid'
      ):evaluate(context)

      assert.is_false(res_false)
    end)

    it('evaluates comparison ops without differentiating types', function()
      local context = { var_1 = 1 }

      local eq_int_and_string = Operation.new(
        '{{ var_1 }}', 'liquid', '==', '1', 'plain'
      ):evaluate(context)

      assert.is_true(eq_int_and_string)

      local not_eq_int_and_string = Operation.new(
        '{{ var_1 }}', 'liquid', '!=', '1', 'plain'
      ):evaluate(context)

      assert.is_false(not_eq_int_and_string)
    end)
  
    describe("numerics operations", function()
      local context = {
          a="1",
          b="2",
          c="3",
          invalid="invalid"
      }

      it("validate greater than operation", function()
        local expected_results = {
          {"1" , "2", false},
          {"1" , "1", false},
          {"2" , "1", true},
          {"xx" , "2", false},
          {"2" , "xx", true},
          {"{{a}}" , "1", false},
          {"{{b}}" , "2", false},       
          {"{{c}}" , "2", true},
          {"{{invalid}}", 2, false}
        }

        
        for _,x in ipairs(expected_results) do
           local op = Operation.new(x[1], "liquid", ">", x[2], "liquid")
           assert.are.same(op:evaluate(context), x[3], "issue comparing interaction ".. x[1] .." > " ..x[2])
        end
      end)

      it("validate greater or equal than operation", function()
        local expected_results = {
          {"1" , "2", false},
          {"1" , "1", true},
          {"2" , "1", true},
          {"xx" , "2", false},
          {"2" , "xx", true},
          {"0" , "xx", true},
          {"{{a}}" , "0", true},
          {"{{a}}" , "1", true},       
          {"{{c}}" , "2", true},
          {"{{invalid}}", "2", false},
          {"{{invalid}}", 0, true}
        }

        
        for _,x in ipairs(expected_results) do
           local op = Operation.new(x[1], "liquid", ">=", x[2], "liquid")
           assert.are.same(op:evaluate(context), x[3], "issue comparing interaction ".. x[1] .." >=" ..x[2])
        end
      end)

      it("validate less than operation", function()
        local expected_results = {
          {"1" , "2", true},
          {"1" , "1", false},
          {"2" , "1", false},
          {"xx" , "2", true},
          {"2" , "xx", false},
          {"{{a}}" , "2", true},
          {"{{a}}" , "1", false},       
          {"{{c}}" , "1", false},
          {"{{invalid}}" , "2", true},
          {"{{invalid}}" , "-2", false},
        }

        
        for _,x in ipairs(expected_results) do
           local op = Operation.new(x[1], "liquid", "<", x[2], "liquid")
           assert.are.same(op:evaluate(context), x[3], "issue comparing interaction ".. x[1] .." < " ..x[2])
        end
      end)

      it("validate less or equal than operation", function()
        local expected_results = {
          {"1" , "2", true},
          {"1" , "1", true},
          {"2" , "1", false},
          {"xx" , "2", true},
          {"2" , "xx", false},
          {"{{a}}" , "2", true},
          {"{{a}}" , "1", true},       
          {"{{c}}" , "1", false},
          {"{{invalid}}", 2, true},
          {"{{invalid}}", -2, true},
        }
        
        for _,x in ipairs(expected_results) do
           local op = Operation.new(x[1], "liquid", "<=", x[2], "liquid")
           assert.are.same(op:evaluate(context), x[3], "issue comparing interaction ".. x[1] .." <=" ..x[2])
        end
      end)
    end)

  end)
end)
