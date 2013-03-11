module Skylab::Headless

  module Services::String
    module Lines
    end
  end

  class Services::String::Lines::Producer

    # minimal abstract enumeration and scanning of the lines of a string.
    #   + quacks like subset of File::Lines::Producer
    #   + better than plain old ::Enumerator b.c you can call `next` (gets)
    #       without catching the ::StopIteration.
    #   + Future-proof: maybe it uses ::StringScanner internally, maybe not.)

    class << self
      private :new
    end

    def self.factory string
      if string.length > Headless::CONSTANTS::MAXLEN
        fail 'implement me - fun!'
      else
        new string
      end
    end

    def gets
      if @current < @length
        x = @lines[ @current ]
        @current += 1
        x
      end
    end

  protected

    def initialize string
      @lines = string.split "\n"
      @length = @lines.length
      @current = 0
      nil
    end
  end
end
