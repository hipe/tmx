module Skylab::Parse

  # ->

    module Input_Stream_

      class << self

        def via_array x
          Home_::Input_Streams_::Array.new x
        end
      end  # >>

      class Token

        def initialize x
          @value = x
          freeze
        end

        attr_reader :value
      end
    end
    # <-
end
