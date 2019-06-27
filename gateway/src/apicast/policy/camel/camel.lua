local policy = require('apicast.policy')
local _M = policy.new('camel')

local http_ng = require "resty.http_ng"
local resty_env = require('resty.env')
local resty_url = require 'resty.url'

local new = _M.new

function _M.new(config)
  self = new(config)
  
  -- merda, err = resty_url.parse(config.all_proxy)
  -- ngx.log(ngx.ERR, "ELOY---------------------------------")
  -- ngx.log(ngx.ERR, "config proxy", config.all_proxy)
  -- ngx.log(ngx.ERR, "MERDA", require("inspect").inspect(merda))
  -- ngx.log(ngx.ERR, "err", require("inspect").inspect(err))
  -- ngx.log(ngx.ERR, "ELOY---------------------------------")

  self.proxies = {
    all_proxy = resty_url.parse(config.all_proxy),
    http = resty_url.parse(config.http_proxy) or resty_url.parse(config.all_proxy),
    https = resty_url.parse(config.https_proxy) or config.all_proxy,
  }
  return self
end

function _M:find_proxy(scheme)
  -- return nil
  return self.proxies[scheme] end

function _M:export()
  return  {
    has_hhtp_proxy = function(context, uri)
      if not uri.scheme then
        return nil
      end
      return self:find_proxy(uri.scheme)
    end
  }
end

return _M
