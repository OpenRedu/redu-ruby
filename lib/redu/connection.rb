require 'faraday'
require 'faraday_middleware'

module Redu
  class Connection
    attr_accessor :oauth_token

    def initialize(opts={})
      @oauth_token = opts[:oauth_token]
    end

    %w[get post put delete].each do |meth|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{meth}(url = nil, params = {})
          run_request(:#{meth}, url, params)
        end
      RUBY
    end

    def run_request(method, url, params={})
      connection.send(method, url, params)
    end

    protected

    def connection
      @connection ||= Faraday.new(url: 'http://openredu.com/api/') do |c|
        c.request  :json
        c.use FaradayMiddleware::ParseJson, content_type: /\bjson$/
        c.adapter  Faraday.default_adapter
        c.headers = { 'Authorization' => "OAuth #{oauth_token}",
                      'Content-type' => 'application/json' }
      end
    end
  end
end
