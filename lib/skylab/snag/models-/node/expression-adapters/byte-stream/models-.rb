module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream  # [#038]

      Models_ = ::Module.new

      class Models_::Substring

        def initialize begin_, end_, string
          @begin = begin_
          @end = end_
          @s = string
        end

        attr_reader :begin, :end, :s

        def is_mutable
          false
        end

        def to_mutable
          BS_::Mutable_Models_::Substring.new @begin, @end, @s.dup
        end

        def detect_index_of_equivalent_object_ obj

          d = -1
          st = to_object_stream_
          sym = obj.category_symbol

          begin
            o = st.gets
            o or break
            d += 1
            if sym == o.category_symbol
              if obj == o
                found_d = d
                break
              end
            end
            redo
          end while nil

          found_d
        end

        def to_simple_stream_of_objects_

          # for one line of one node, produce the strings and tags. this
          # will be used in whole-collection searched for tags, so etc..

          BS_::Actors_::Flyweighted_object_stream_via_substring[ self ]
        end

        alias_method :to_object_stream_, :to_simple_stream_of_objects_
          # we can do the above only while we using [#008] structured tags,
          # which result in a common stream as a by-product; else :+#tombstone

      end

      class Models_::Body < Row_Based_Body_

        class << self
          def via_range_and_substring_array r, sstr_a
            new r, sstr_a
          end
          private :new
        end  # >>

        def initialize r, sstr_a
          @r = r
          @sstr_a = sstr_a
        end

        def receive_extended_content_adapter__ x
          @extended_content_adapter_ = x
          NIL_
        end

        attr_reader :extended_content_adapter_

        def reinitialize r
          @r = r
          NIL_
        end

        def initialize_copy _
          @sstr_a = @sstr_a.dup
          NIL_
        end

        def is_mutable
          false
        end

        def to_mutable
          BS_::Mutable_Models_::Body.
            via_range_and_substring_array__( @r, @sstr_a.dup )
        end

        def express_N_units_into_under_ d, y, expag

          :Byte_Stream == expag.modality_const or self._DO_ME

          stay = if d && -1 != d
            if 0 > d
              d = 0
            end
            -> do
              if d.nonzero?
                d -= 1
                true
              end
            end
          else
            MONADIC_TRUTH_
          end

          @sstr_a.each do | substring_o |
            stay[] or break
            y << substring_o.s
          end

          ACHIEVED_
        end

        def to_business_row_stream_

          a = @sstr_a

          Callback_::Stream.via_range @r do | d |
            a.fetch d
          end
        end

        MONADIC_TRUTH_ = -> { true }
      end
    end
  end
end
