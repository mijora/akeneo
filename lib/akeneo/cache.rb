# frozen_string_literal: true

require 'redis'

module Akeneo
  module Cache
    DEFAULT_EXPIRES_IN = 5 * 60

    @@disabled = false # rubocop:disable Style/ClassVars

    def self.disabled=(value)
      @@disabled = value # rubocop:disable Style/ClassVars
    end

    module ClassMethods
      def redis
        @redis ||= Redis.new
      end
    end

    def self.prepended(base)
      base.extend(ClassMethods)
    end

    def get_request(path, options = {})
      return super if disabled?

      key = path.downcase
      key << options[:query].to_s if defined? options[:query]

      cached_response = read(key)
      return cached_response unless cached_response.nil?

      response = super

      write(key, response)
      response
    rescue Redis::CannotConnectError
      super
    end

    private

    def read(key)
      serialized_response = self.class.redis.get("akeneo:#{key}")
      load_response(serialized_response) if serialized_response
    end

    def write(key, response)
      self.class.redis.set("akeneo:#{key}", serialize_response(response), ex: expires_in)
    end

    def serialize_response(response)
      Marshal.dump(response)
    end

    def load_response(serialized_response)
      Marshal.load(serialized_response) # rubocop:disable Security/MarshalLoad
    end

    def disabled?
      @@disabled
    end

    def expires_in
      ENV.fetch('AKENEO_CACHE_EXPIRES_IN', DEFAULT_EXPIRES_IN)
    end
  end
end
