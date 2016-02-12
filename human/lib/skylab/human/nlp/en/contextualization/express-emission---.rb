module Skylab::Human

  class NLP::EN::Contextualization

    # NOTE - this file is for now the dumping ground for several small
    # "magnetic"-type actors, all of which are currently private to the file
    # but stowaway here rather that being placed inside the file's node, so
    # if/when we need to promote their visibilty it is trivial.

    class Express_Emission___

      class << self

        def [] kns

          kns.when_ :channel, :line_downstream do |kns_|

            # this is a big jump. break this down into shorter steps if
            # clients wants to be able to step in at some intermediate point.
            # on the other hand, the subject is potentially customizable
            # so etc..

            new( kns_ ).execute
          end
        end

        private :new
      end  # >>

      def initialize kns
        @knowns_ = kns
      end

      attr_accessor(
        :line_downstream_via_line_stream,
        :line_stream_via_channel,
      )

      def execute

        _ = self.line_stream_via_channel || Here_::Line_Stream_via_Channel___
        _[ @knowns_ ]

        _ = self.line_downstream_via_line_stream
        _ ||= Here_::Line_Downstream_via_Line_Stream___
        _[ @knowns_ ]

        NIL_
      end
    end

    Line_Downstream_via_Line_Stream___ = -> kns do

      str = Streamer_.new

      str.on_first = -> s do
        o = Here_::First_Line_Contextualization_[ kns ]
        o.line = s
        o.build_line
      end

      str.on_subsequent = IDENTITY_

      _st = str.to_stream_around kns.line_stream

      kns.line_downstream = _st

      NIL_
    end

    Line_Stream_via_Channel___  = -> kns do  # #stowaway

      # side-effect is to resolve a trilean (shh)

      if ! kns.event_proc
        self._COVER_ME_emission_does_not_comply_to_this_modality
      end

      if :expression == kns.channel[ 1 ]  # #[#br-023]. [sli] has 1-item channels

        Line_Stream_via_Expression___[ kns ]
      else
        Line_Stream_via_Event___[ kns ]
      end
    end

    class Line_Stream_via_Expression___ < Here_::Transition_  # #stowaway

      # assume event proc. side-effect is to resolve a trilean (shh)

      def execute
        ___determine_line_stream
        derive_trilean_from_channel_if_necessary_
        NIL_
      end

      def ___determine_line_stream
        kns = @knowns_
        nla = Newline_Adder_.new
        kns.expression_agent.calculate nla.y, & kns.event_proc
        kns.line_stream = nla.to_line_stream
        NIL_
      end
    end

    class Line_Stream_via_Event___ < Here_::Transition_ # #stowaway

      # assume event proc. side-effect is to resolve a trilean and .. (shh)

      def execute

        # just like `to_stream_of_lines_rendered_under` but we add NL
        ___determine_line_stream
        __determine_trilean
        NIL_
      end

      def ___determine_line_stream

        kns = @knowns_
        @_ev = kns.event_proc.call
        kns.event = @_ev
        nla = Newline_Adder_.new

        ev = @_ev.to_event
        kns.expression_agent.calculate nla.y, ev, & ev.message_proc
        kns.line_stream = nla.to_line_stream
        NIL_
      end

      def __determine_trilean

        ev = @_ev.to_event

        if ev.has_member :ok
          tri = ev.ok
        end

        @knowns_.trilean = tri
        NIL_
      end
    end
  end
end
