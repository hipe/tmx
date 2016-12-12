module Skylab::Tabular

  class Magnetics::MixedTupleStream_via_LineStream_and_Inference <
      Common_::Actor::Dyadic

    # -

      def initialize line_st, inf
        @inference = inf
        @line_upstream = line_st
      end

#==BEGIN coded just for mocking

      # NOTE in the real world we must assume that each line of input is
      # absolutely anything and we will have to parse it accordingly. but
      # at this phase in the development we mock this so that once we see
      # what the "secret mock key" is in the first line, we then dereference
      # a hard-coded regex that we will use to turn each line of input into
      # a mixed tuple (or similar approach).

      def execute
        first_line = @line_upstream.gets
        if first_line
          __when_one_line first_line
        else

          # (we could preserve the empty-streamed-ness here by resuling in
          # NOTHING_, but we don't because the fact that we have this
          # peek-ed-ness is probably just a by-product of our mock-ed-ness)

          Common_::Stream.the_empty_stream
        end
      end

      def __when_one_line first_line

        _matchdata = SECRET_MOCK_KEY_RX_.match first_line

        key = _matchdata[ :key ].intern

        @inference.SECRET_MOCK_KEY = key

        wee = send MOCKS__.fetch key

        p = -> do
          p = -> do
            line = @line_upstream.gets
            if line
              wee[ line ]
            end
          end
          wee[ first_line ]
        end

        Common_.stream do
          p[]
        end
      end

      MOCKS__ = {
        :"1" => :__mock_line_converter_for_case_family_one,
      }

      def __mock_line_converter_for_case_family_one

        rx = /\A([^ ]+)[ ](\d+)\z/

        -> line do
          md = rx.match line
          md || self._MOCKING_FAILED
          [ md[1], md[2].to_i ]
        end
      end
    # -
#==END coded just for mocking
  end
end
# #born for infer table (as mock at first)
