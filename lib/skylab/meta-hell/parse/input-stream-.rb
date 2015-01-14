module Skylab::MetaHell

  module Parse

    module Input_Stream_

      class Token

        def initialize x
          @value_x = x
          freeze
        end

        def members
          [ :value_x ]
        end

        attr_reader :value_x
      end
    end
  end
end
