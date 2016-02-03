module Skylab::Zerk

  module API

    class Compound_Frame___

      # our custom frame for our custom stack.

      def initialize qk

        @qualified_knownness = qk

        @_has_last_written = false
      end

      # -- write

      def accept_component_change__ qk

        _rw = reader_writer

        _p = ACS_::Interpretation::Accept_component_change.call(
          qk,
          _rw,
        )

        @_has_last_written = true
        @_last_written_qkn = qk

        _p
      end

      # -- read

      def to_node_stream_

        _rw = reader_writer

        sr = _rw.to_node_streamer

        x = __mask__
        if x
          self._ETC
        end
        _st = sr.call
        _st
      end

      def qualified_knownness_as_invocation_result__

        # (implement the relevant half of the graph of [#012]/figure-2)

        if @_has_last_written
          @_last_written_qkn
        else
          @qualified_knownness
        end
      end

      def qualified_knownness_of_association__ asc

        # NOTE custodianship of this assoc to our compound component is not validated

        _rw = reader_writer
        _rw.qualified_knownness_of_association asc
      end

      def component_association_via_token__ x

        _rw = reader_writer
        _rw.read_association x
      end

      def __mask__
        NOTHING_  # #during [#013]
      end

      # --

      def reader_writer

        # (this one spot is the crux of the whole redesign near r/w)

        @___rw ||= ACS_::Reader_Writer.for_componentesque self.ACS
      end

      def ACS
        @qualified_knownness.value_x
      end

      # -- for sub-clients

      def name  # for our "when"'s - contextualized normalization failure expression
        @qualified_knownness.name
      end
    end
  end
end
