module Skylab::SearchAndReplace::TestSupport

  module SES::A_B_Partitioner

    def self.[] tcc
      tcc.include self
    end

    # -
      # -- setup

      def _A * matches
        @A_stream = _stream_via :A, matches
      end

      def _B * matches
        @B_stream = _stream_via :B, matches
      end

      def _stream_via _A_or_B_sym, matches
        Common_::Stream.via_nonsparse_array matches do |pair|
          Match___.new( * pair, _A_or_B_sym )
        end
      end

      # -- assert

      def want_chunks * x_a

        st = _to_chunk_stream
        d = 0
        x_a.each_slice 2 do | _A_or_B_sym, chunk_exp |
          d += 1
          chunk = st.gets
          if ! chunk
            fail __say_no_chunk d
          end

          chunk_exp.each_with_index do | span_exp, d_ |

            if 2 == span_exp.length
              use_pair = span_exp
              use_sym = _A_or_B_sym
            else
              (use_sym, * use_pair) = span_exp
            end

            want_span chunk.fetch( d_ ), * use_pair, use_sym
          end
        end

        chunk = st.gets
        if chunk
          fail __say_extra_chunk chunk
        end
        NIL_
      end

      def want_span match, beg, ending, sym

        match._category_symbol_.should eql sym
        match._category_symbol_ == sym or fail

        match.charpos == beg or fail
        match.end_charpos == ending or fail
      end

      def __say_no_chunk d
        "expected chunk at chunk offset #{ d }, had none"
      end

      def __say_extra_chunk chunk
        "extra chunk [..]"
      end

      def flush_chunks  # mostly for debuging
        _to_chunk_stream.to_a
      end

      def _to_chunk_stream
        o = subject_class_.new @A_stream, @B_stream
        mutate_chunk_streamer o
        o.execute
      end

      def mutate_chunk_streamer o
        NIL_
      end

      def A_B_partitioner_base_class
        Home_::StringEditSession_::A_B_Partitioner___
      end

    # -
    # ==

    class Match___

      def initialize d, d_, cat_sym
        @_category_symbol_ = cat_sym
        @charpos = d
        @end_charpos = d_
      end

      attr_reader(
        :_category_symbol_,
        :charpos,
        :end_charpos,
      )
    end
  end
end
