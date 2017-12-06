module Skylab::Parse

  # ->

    class Functions_::Item_From_Matrix  # :[#002]:

      # build the function around a list of items, each item having as a name
      # a list of one or more words. when called against the input stream the
      # function produces any exactly one of these items whose name is unique
      # in matching tokens off the head of the input stream, with any longest
      # match winning. in all cases where exactly one item cannot be produced
      # a potential event is emitted describing the case.
      #
      # because there is no partial matching, a table of uniquely named items
      # can never produce ambiguous results: either one or more exact matches
      # was found or it wasn't, and in cases where multiple exact matches are
      # found, none will be of the same length of words; i.e one will be longest.
      #
      # how this behaves with items with non-unique names may be undefined.

      Attributes_actor_.call( self,
        :item_stream_proc,
      )

      class << self

        def via_item_stream_proc & p
          with :item_stream_proc, p
        end

        private :new
      end  # >>

      def initialize & p
        # (one important external lib doesn't play nice with our above setup..)
        if p
          @_listener = p
        end
      end

      def output_node_via_input_stream in_st, & p

        dup.__init( in_st, & p ).__parse
      end

      def __init in_st, & p
        if p
          @_listener = p
        end
        @_in_st = in_st
        self
      end
      protected :__init

      def __parse

        # maintain a diminishing list of candidate rows. on the surface this
        # list is interacted with variously as a stream or as an array. down
        # deep it is at the first pass a stream and at each successive pass
        # an array. at each pass: if you are out of tokens from the input
        # stream, your result is determined by the number of rows remaining
        # in this [#ba-061] diminishing pool; with the 0, one and many cases
        # having the expected semantics. also at each pass: if you are down
        # to zero rows in the running, finish with the expected semantics.

        __prepare_to_parse

        begin  # for each token

          if @_in_st.no_unparsed_exists
            x = __when_end_of_input
            break
          end

          s = @_in_st.head_as_is

          # build a new list of candidates

          current_end_length = @_current_column + 1

          exact_match_a = nil
          partial_match_a = nil

          row_st = @_build_row_stream[]
          begin  # for each row in the running

            pair = row_st.gets
            pair or break

            # assume every row has the current cel, otherwise by now it would
            # have been eliminated. we furthermore assume no zero-width rows

            row = pair.association

            _yes = s == row.fetch( @_current_column )

            if ! _yes  # IFF here, life is easy: the row does not match at all
              redo
            end

            if current_end_length == row.length  # IFF here, exact match

              exact_match_a ||= []
              exact_match_a.push pair
              redo
            end

            # IFF here, the row matches so far but there is still more left

            partial_match_a ||= []
            partial_match_a.push pair

            redo
          end while nil

          # now that we have finished classifying each member of the pool
          # for this token; even if you have exact matches, if you have
          # partial matches you have to keep looking (unless..)

          if exact_match_a

            # typically you need to pursue partial matches even when you have
            # exact matches. the only time this is not the case is when you
            # have reached (or more correctly are about to reach) the end
            # of the input. in such cases you *must* go with the exact match,
            # and disregard the partial matches, otherwise (for e.g) in the
            # case of 'magnetics' vs. 'magnetics-viz', the former is unreachable.

            _pursue_partial_matches = if partial_match_a
              ! @_in_st._IS_ON_FINAL_TOKEN
            end

            if _pursue_partial_matches
              @_last_exact_matches = exact_match_a
              @_last_exact_match_index = @_in_st.current_index
            else
              @_in_st.advance_one
              x = _result_via_exact_matches exact_match_a
              break
            end
          end

          if partial_match_a
            @_last_partial_matches = partial_match_a
            @_in_st.advance_one
            @_current_column += 1
            redo
          end

          if @_last_exact_matches
            @_in_st.current_index = @_last_exact_match_index + 1
            x = _result_via_exact_matches @_last_exact_matches
            break
          end

          x = __when_unrecognized
          break

        end while nil
        x
      end

      def __prepare_to_parse

        @_previous_build_row_stream = @item_stream_proc

        @_build_row_stream = -> do

          # the first time it is called, change it so it will be different
          # (but the same) on each successive call:

          p = -> do
            Stream_[ @_last_partial_matches ]
          end

          @_build_row_stream = -> do

            # tricky: with this other ivar, it is the same idea but always
            # one step behind (until 3rd and subsequent passes, when all same)

            @_previous_build_row_stream = p

            @_build_row_stream = p
            p[]
          end

          @item_stream_proc.call
        end

        @_current_column = 0

        @_last_exact_matches = nil

        @__very_first_index = @_in_st.current_index

        NIL_
      end

      def _result_via_exact_matches node_a  # assume nonzero length

        if 1 == node_a.length

          node_a.fetch 0
        else

          self._IMPLEMENT_ME_when_ambiguous node_a
        end
      end

      def __when_end_of_input

        _same @_build_row_stream
      end

      def __when_unrecognized

        _same @_previous_build_row_stream
      end

      def _same p

        if @_in_st.unparsed_exists
          _was_token = @_in_st.head_as_is
        end

        @_in_st.current_index = @__very_first_index

        @_listener.call :error, :expecting do

          _build_expecting_event _was_token, p

        end
        UNABLE_
      end

      def _build_expecting_event was_token, p

        Common_::Event.inline_not_OK_with( :expecting,

            :token, was_token,
            :column_index, @_current_column,
            :item_stream_proc,p

        ) do | y, o |

          a = []
          d = o.column_index
          done = false
          h = {}
          max = 3  # whatever
          st = o.item_stream_proc.call

          begin
            kn = st.gets
            kn || break
            s = kn.association.fetch d
            h.fetch s do
              h[ s ] = true
              a.push val s
              if max == a.length
                done = true
              end
              NIL_
            end
            done and break
            redo
          end while nil

          if kn and st.gets
            ellipsis = true
            a.push '[..]'
          end

          _tail = if ellipsis
            a * ', '
          else
            or_ a
          end

          s = o.token
          _head = if s
            "uninterpretable token #{ ick s }. "
          else
            "at end of input "
          end

          y << "#{ _head }expecting #{ _tail }"
        end
      end
    end
    # <-
end
