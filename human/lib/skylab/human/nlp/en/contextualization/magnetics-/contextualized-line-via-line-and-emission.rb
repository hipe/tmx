module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Line_via_Line_and_Emission

      # this whole node is primarily to get [br] to transition off of doing
      # its own c15n. when dust settles we may DRY it up with its siblings.
      # (because for one thing, as it is it is not configurable.)

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @to_pre_articulate_ = nil
      end

      def parameter_store= ps
        @_ = ps
        @event = ps.event
        @trilean = ps.trilean  # be sure this gets it
        ps
      end

      attr_writer(
        :line,
      )

      def execute
        @_function = if @event
          __function_when_event
        end
        __assemble_the_line
      end

      def __function_when_event

        ok = @trilean
        if ok
          ev = @event.to_event
          ev = ev.to_event
          if ev.has_member :is_completion and ev.is_completion
            _is_comp = true
          end
          if _is_comp
            Magnetics_::Line_Parts_via_Line_and_Event_that_is_Completion
          else
            Magnetics_::Line_Parts_via_Line_and_Event_and_Trilean_that_is_Positive
          end
        elsif ok.nil?
          Do_Not_Contextualize_Line___
        else
          Magnetics_::Line_Parts_via_Line_and_Event_and_Trilean_that_is_Negative
        end
      end

      def __assemble_the_line

        @_parts = Parts___.new

        __unparenthesize_the_line

        __downcase_the_first_letter

        __specific_mutations

        remove_instance_variable( :@_parts ).values.join
      end

      Parts___ = ::Struct.new :open, :prefix, :content, :suffix, :close

      def __unparenthesize_the_line

        o = @_parts

        _line = remove_instance_variable :@line

        o.open, o.content, o.close =
          Home_.lib_.basic::String.unparenthesize_message_string _line

        NIL_
      end

      def __downcase_the_first_letter
        Mutate_by_downcasing_first___[ @_parts.content ]
        NIL_
      end

      def __specific_mutations
        p = @to_pre_articulate_
        if p
          p[]
        else
          f = remove_instance_variable :@_function
          if f
            f.via_magnetic_parameter_store self
          end
        end
        NIL_
      end

      # -- ( mini-API for the above clients )

      # [open]

      def prefix_= x
        @_parts.prefix = x
      end

      def content_  # assume client will MUTATE string!
        @_parts.content
      end

      def suffix_= x
        @_parts.suffix = x
      end

      def close_= x
        @_parse.close = x
      end

      attr_reader(
        :event,
      )

      # --

      module Do_Not_Contextualize_Line___
        def self.via_magnetic_parameter_store _
          Home_._COVER_ME_reimplement_me_easy
        end
      end

      # --

      def content_string_looks_like_one_word_
        LOOKS_LIKE_ONE_WORD_RX___ =~ @_parts.content
      end

      LOOKS_LIKE_ONE_WORD_RX___ = /\A[a-z]+$/

      Mutate_by_downcasing_first___ = -> do
        rx = nil
        -> s do
          if s
            rx ||= /\A[A-Z](?![A-Z])/
            s.sub! rx do | s_ |
              s_.downcase!
            end
            NIL_
          end
        end
      end.call
    end
  end
end
# #history: the was extracted from [br] CLI
