module Skylab::Parse

  # ->

    class Functions_::Regex

      class << self

        def new_via_polymorphic_stream_passively st

          rx = st.gets_one
          if st.unparsed_exists && :becomes_symbol == st.current_token
            st.advance_one
            sym = st.gets_one
          end
          new sym, rx
        end

        private :new
      end  # >>

      def initialize sym=nil, rx

        @becomes_symbol = sym
        @rx = rx
      end

      def output_node_via_input_stream in_st

        if in_st.unparsed_exists

          _x = in_st.current_token_object.value_x

          s = ::String.try_convert _x
          if s

            md = @rx.match s

            if md

              in_st.advance_one
              Home_::Output_Node_.new( @becomes_symbol || md )
            end
          end
        end
      end
    end
    # <-
end
