module Skylab::Snag

  class Models_::Node

    Expression_Adapters = ::Module.new

    module Expression_Adapters::Byte_Stream

      class << self

        def express_into_under_of_ y, expag, node
          express_N_units_into_under_of_ nil, y, expag, node
        end

        def express_N_units_into_under_of_ d, y, expag, node

          body = node.body

          if body.is_mutable
            if :Byte_Stream == body.modality_const
              Sessions_::Delineate[ d, y, expag, node ]
            else
              Sessions_::Delineate.new_with( d, y, expag, node ).execute_agnostic
            end
          else
            self.__TODO_express_immutable_body
          end
        end
      end  # >>

      Autoloader_[ Sessions_ = ::Module.new ]

      class Sessions_::Expag___  # will integrate

        def initialize d, d_, d__

          @identifier_integer_width = d__
          @sub_margin_width = d_
          @width = d
          @modality_const = :Byte_Stream
        end

        attr_reader :identifier_integer_width, :modality_const,
          :sub_margin_width, :width
      end

      Actors_ = ::Module.new

      Actors_::Flyweighted_object_stream_via_substring = -> do

        conventional_st_via_simple_st = -> st do
          Callback_.stream do

            o = st.gets
            if o
              if :tag == o.business_category_symbol
                x = st.peek_for_value
                if x
                  self._DO_ME
                end
              end
            end
            o
          end
        end

        convential_stream = -> sstr do

          simple_st = Snag_::Models::Hashtag.interpret_simple_stream_from__(
            sstr.begin, sstr.end, sstr.s,
            Snag_::Models_::Tag.new( nil )  # one #flyweight to rule them all
          ).flush_to_value_peeking_stream

          convential_stream = -> sstr_ do
            simple_st.reinitialize sstr_.begin, sstr_.end, sstr_.s
            conventional_st_via_simple_st[ simple_st ]
          end

          conventional_st_via_simple_st[ simple_st ]
        end

        -> sstr do
          convential_stream[ sstr ]
        end
      end.call
    end
  end
end
