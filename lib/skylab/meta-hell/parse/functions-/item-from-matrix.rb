module Skylab::MetaHell

  module Parse

    class Functions_::Item_From_Matrix

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

      class << self
        def new_with * x_a
          new = allocate
          new.instance_exec do
            process_iambic_fully x_a
            freeze
          end
          new
        end
      end  # >>

      Callback_::Actor.call self, :properties,
        :item_stream_proc

      def initialize & p
        @item_stream_proc = p
        freeze
      end

      def output_node_via_input_stream in_st, & oes_p

        current_column_offset = 0
        exact_a = []
        in_progress_a = []
        input_index_at_beginning = in_st.current_index
        input_index_at_last_exact_match = nil
        item_st_p = @item_stream_proc
        next_exact_a = []
        next_in_progress_a = []

        tick = -> do
          item_st_p = -> do
            Callback_::Stream.via_nonsparse_array in_progress_a
          end
          tick = EMPTY_P_
        end

        begin  # with each input token

          if in_st.no_unparsed_exists
            in_st.current_index = input_index_at_beginning
            x = __when_end_of_input current_column_offset, item_st_p, & oes_p
            break
          end

          item_st = item_st_p[]
          s = in_st.current_token

          begin  # of the items in progress, classify each of them

            item = item_st.gets
            item or break

            if current_column_offset == item.name_symbol.length

              input_index_at_last_exact_match = in_st.current_index
              next_exact_a.push item

            elsif s == item.name_symbol.fetch( current_column_offset )

              next_in_progress_a.push item

            end

            redo
          end while nil

          # we only maintain the most recent exact match

          if next_exact_a.length.nonzero?
            swp = exact_a
            swp.clear
            exact_a = next_exact_a
            next_exact_a = swp
          end

          if next_in_progress_a.length.zero?  # then we are done looking

            x = case 1 <=> exact_a.length
            when 0
              exact_a.fetch 0
            when 1
              s = in_st.current_token
              in_st.current_index = input_index_at_beginning
              __when_no_match( s, current_column_offset, item_st_p, & oes_p )
            when -1
              exact_a  # you input table is the problem
            end
            break
          end

          # memo the most recent "in progress" array as well as the previous

          swp = in_progress_a
          swp.clear
          in_progress_a = next_in_progress_a
          next_in_progress_a = swp

          current_column_offset += 1
          in_st.advance_one
          tick[]

          redo

        end while nil
        x
      end

      def __when_end_of_input cc_d, item_st_p, & on_event_selectively

        on_event_selectively.call :error, :expecting do

          _build_expecting_event cc_d, item_st_p

        end
      end

      def __when_no_match s, cc_d, item_st_p, & on_event_selectively

        on_event_selectively.call :error, :expecting do

          _build_expecting_event s, cc_d, item_st_p
        end
      end

      def _build_expecting_event token_s=nil, cc_d, item_st_p

        Callback_::Event.inline_not_OK_with :expecting,
            :token, token_s,
            :column_index, cc_d,
            :item_stream_proc, item_st_p do | y, o |

          a = []
          d = o.column_index
          done = false
          h = {}
          max = 3  # whatever
          st = o.item_stream_proc.call

          begin
            x = st.gets
            x or break
            s = x.name_symbol.fetch d
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

          if x and st.gets
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
  end
end
