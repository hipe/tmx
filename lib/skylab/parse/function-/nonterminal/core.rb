module Skylab::MetaHell

  module Parse

    module Function_::Nonterminal

      class Sibling_Sandbox

        def initialize a
          @_function_a = a
        end

        def to_reflective_function_stream
          Callback_::Stream.via_nonsparse_array @_function_a
        end
      end
    end
  end
end
