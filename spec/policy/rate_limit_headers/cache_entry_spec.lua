local Usage = require('apicast.usage')
local cache_entry = require("apicast.policy.rate_limit_headers.cache_entry")

describe("Cache key", function()
  local usage

  before_each(function()
    usage = Usage.new()
    usage:add("a", 3)
  end)

  it("New works as expected", function()
    local key = cache_entry.new(usage, 1, 2, 3)
    assert.same(key.limit:__tostring(), "1")
    assert.same(key.remaining:__tostring(), "2")
    assert.True(key.reset.limit_time > 0)
  end)

  it("decrements works as expected", function()

    local key = cache_entry.new(usage, 1, 10, 3)
    key:decrement(1)
    assert.same(key.remaining:__tostring(), "9")

    key:decrement(10)
    assert.same(key.remaining:__tostring(), "-1")
  end)


end)
