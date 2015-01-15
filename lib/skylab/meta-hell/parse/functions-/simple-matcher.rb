module Skylab::MetaHell

  module Parse

    module Functions_::Simple_Matcher

      class << self

        def new_via_iambic_stream_passively st
          new_via_proc st.gets_one
        end

        def new_via_proc p
          -> in_st do
            if p[ in_st.current_token_object.value_x ]
              tok = in_st.current_token_object
              in_st.advance_one
              tok
            end
          end
        end
      end
    end
  end
end
