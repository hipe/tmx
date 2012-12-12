module Skylab::TanMan
  class Services::Tree
    # experimentally holds parse trees in memory for different controllers
    # to use! #experimental
    # (thread safety is a boggling thought.)

    def fetch normalized_pathname, &block
      @cache.fetch normalized_pathname.to_s do |k|
        if ! block
          raise ::KeyError.exception "key not found #{ k.inspect }"
        end
        block[ k, self ]
      end
    end

    def has? normalized_pathname
      @cache.key? normalized_pathname.to_s
    end

    def remove normalized_pathname
      has?( normalized_pathname ) or fail "didn't have #{ normalized_pathname }"
      @cache.delete normalized_pathname.to_s
    end

    def set! normalized_pathname, value
      k = normalized_pathname.to_s
      @cache.key?(k) and raise ::KeyError.new("won't clobber existing : #{ k }")
      @cache[k] = value
      nil
    end

  protected

    def initialize
      @cache = { }
    end
  end
end
