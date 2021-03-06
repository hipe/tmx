
module Skylab::Parse

  # ->

    class Functions_::Keywords

      class << self

        def via_argument_scanner_passively st
          new st.gets_one
        end

        private :new
      end  # >>

      def initialize s_a

        last = s_a.length - 1

        @p = -> in_st do

          orig_d = in_st.current_token_object
          d = 0

          begin

            s = s_a.fetch d

            if in_st.no_unparsed_exists
              break
            end

            if s == in_st.head_as_is

              in_st.advance_one

              if last == d
                x = Home_::OutputNode.for :_some_keywords_
                break
              end

              d += 1

              redo
            end
            break
          end while nil

          if ! x
            in_st.current_index = orig_d
          end

          x
        end
      end

      def output_node_via_input_stream in_st
        @p[ in_st ]
      end
    end
    # <-
end
