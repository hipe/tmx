module Skylab::MetaHell

  module Parse

    module Functions_::Trueish_Mapper

      # pass to the user proc the input stream. if the result is true-ish,
      # assume this is a mixed output value and that the use proc advanced
      # the input scanner.

      class << self

        def new_via_iambic_stream_passively st
          new_via_proc st.gets_one
        end

        def new_via_proc p
          -> in_st do
            x = p[ in_st ]
            if x
              Parse_::Output_Node_.new x
            end
          end
        end
      end
    end
  end
end
