module Skylab::MetaHell

  module Parse

    class Functions_::Keyword < Parse_::Function_::Field

      class << self
        def new_via_iambic_stream_passively st
          new do
            @formal_string = st.gets_one  # magic first token
            process_iambic_stream_passively st  # always OK
          end
        end
      end  # >>

      edit_actor_class :properties,
        :minimum_number_of_characters

      def initialize

        @minimum_number_of_characters = 1

        super

        @moniker_symbol = @formal_string.intern
        @formal_length = @formal_string.length
        @does_need_hotstring = true
        @ss = nil
      end

      def receive_sibling_sandbox ss
        @ss = ss ; nil
      end

      def to_matcher
        p = self
        -> input_token_s do
          output_token = p.call Parse_::Input_Streams_::Single_Token.new input_token_s
          if output_token
            output_token.value_x  # sanity
            true
          end
        end
      end

      def call in_st
        if @does_need_hotstring
          if @ss
            Resolve_hotstrings__[ @ss ]
          else
            __resolve_hotstring_via_ivars
            @does_need_hotstring = false
          end
        end

        # a token string that is longer than the formal string is not a match.
        #
        # the keyword's "hotstring" is the keyword's shortest anchored-to-the-
        # beginning substring that can still express this constituent uniquely
        # among its siblings. note the hotstring can't be determined until the
        # parent is finished establishing its constituency because how long or
        # short it is (or whether it exists at all) is a function of the other
        # siblings and what their strings are:
        #
        # this constituent will be told that it has no hotstring IFF there are
        # siblings in front of it with an identical formal string, hence it is
        # unreachable IFF it has no hotstring.
        #
        # so for a token string to match this function this function must have
        # a hotstring and (b) the hotstring must occur at the beginning of the
        # token string. any remainder of the token string that goes "over" the
        # hotstring must match the appropriate substring of the formal string.

        tok_s = in_st.current_token_object.value_x
        tok_d = tok_s.length

        if @hotstring
          if tok_d <= @formal_length
            if @hotstring == tok_s[ 0, @hotstring_length ]

              if @hotstring_length == tok_d ||
                 ( @formal_string[ @hotstring_length ... tok_d ] ==
                            tok_s[ @hotstring_length .. -1 ] )

                in_st.advance_one
                Parse_::Output_Node_.new @moniker_symbol

              end
            end
          end
        end
      end

      def __resolve_hotstring_via_ivars
        if @minimum_number_of_characters && -1 != @minimum_number_of_characters
          @hotstring = @formal_string[ 0, @minimum_number_of_characters ]
        else
          @hotstring = @formal_string
        end
        @hotstring_length = @hotstring.length
        nil
      end

      Resolve_hotstrings__ = -> ss do

        f_a = ss.to_reflective_function_stream.reduce_by do | f |
          :keyword == f.function_category_symbol
        end.to_a

        MetaHell_.lib_.basic::String.
          shortest_unique_or_first_headstrings(
            f_a.map( & :formal_string )
          ).each_with_index do | s, d |
            f_a.fetch( d ).receive_hotstring s
          end

        nil
      end

      attr_reader :formal_string

      def receive_hotstring s
        @does_need_hotstring = false
        @hotstring = s
        if s
          @hotstring_length = s.length
        else
          @hotstring_length = 0
        end
        nil
      end

    end
  end
end
