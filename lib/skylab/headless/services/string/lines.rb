module Skylab::Headless

  module Services::String::Lines

    # don't do further development with this without looking at [#ba-004]

    Consumer = -> mutable_string do

      # The first normalized line consumer ([#060]) -
      # produce a new yielder ("normalized consumer") which expects to be
      # given (with `yield` or `<<`) a sequence of zero or more lines
      # that do not contain newlines.

      # does something hacky, the reverse of what `puts` does, for
      # aesthetics. but watch out!

      first = true
      ::Enumerator::Yielder.new do |line|
        if first
          first = false
          mutable_string.concat line
        else
          mutable_string.concat "\n#{ line }"
        end
      end
    end

    def self.Consumer mutable_string
      yield Consumer[ mutable_string ]
    end
  end

  class Services::String::Lines::Producer

    # minimal abstract enumeration and scanning of the lines of a string.
    # + quacks like subset of File::Lines::Producer
    # + better than plain old ::Enumerator b.c you can call `next` (gets)
    #     without catching the ::StopIteration.
    # + Future-proof: maybe it uses ::StringScanner internally, maybe not.)

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
