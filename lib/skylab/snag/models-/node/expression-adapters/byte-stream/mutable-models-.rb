module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream

      Mutable_Models_ = ::Module.new

      class Mutable_Models_::Body

        class << self

          def via_range_and_substring_array__ r, row_a
            new r, row_a
          end
        end  # >>

        def initialize r, row_a
          @r = r
          @row_a = row_a
        end

        def is_mutable
          true
        end

        def modality_const  # #experimental mechanic
          :Byte_Stream
        end

        def r_
          @r
        end

        def row_a_
          @row_a
        end

        def prepend_object obj, & oes_p

          o_a = _mutable_row_at_index( @r.begin ).o_a_
          if o_a.length.nonzero?
            o = o_a.first
            if :space == o.category_symbol
              if WS__ !~ o.to_s[ 0 ]
                self._REDO
                o.to_s[ 0, 0 ] = SPACE_  # you can just
              end
            else
              o_a.unshift Snag_::Models::Hashtag::String_Piece.new SPACE_
            end
          end
          o_a.unshift obj
          ACHIEVED_
        end

        def append_object obj, & oes_p

          o_a = _mutable_row_at_index( @r.end - 1 ).o_a_
          if o_a.length.nonzero?
            o = o_a.last
            if :space == o.category_symbol
              if WS__ !~ o.to_s[ -1 ]
                self._REDO
                o.to_s.concat SPACE_  # you can just
              end
            else
              o_a.push Snag_::Models::Hashtag::String_Piece.new SPACE_
            end
          end
          o_a.push obj
          ACHIEVED_
        end

        def _mutable_row_at_index d

          x = @row_a.fetch d
          if x.is_mutable
            x
          else
            __convert_to_mutable_row d, x
          end
        end

        def __convert_to_mutable_row d, ss

          _a = ss.to_object_stream_.map_by do | o |  # because :+#flyweight
            o.dup
          end.to_a

          mutable = Row___.new _a

          @row_a[ d ] = mutable
          mutable
        end

        class Row___

          def initialize o_a
            @o_a_ = o_a
          end

          attr_reader :o_a_

          def is_mutable
            true
          end

          def to_object_stream_
            Callback_::Stream.via_nonsparse_array @o_a_
          end

          alias_method :to_simple_stream_of_objects_, :to_object_stream_
        end
      end
    end
  end
end
