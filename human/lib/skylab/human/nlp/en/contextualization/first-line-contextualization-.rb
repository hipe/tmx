module Skylab::Human

  class NLP::EN::Contextualization

    class First_Line_Contextualization_

      # this whole node is primarily to get [br] to transition off of doing
      # its own c15n. when dust settles we may DRY it up with its siblings.
      # (because for one thing, as it is it is not configurable.)

      class << self

        def [] kns

          x = kns.trilean.value_x

          _cls = if x
            ev = kns.event
            if ev
              ev = ev.to_event
              if ev.has_member :is_completion and ev.is_completion
                _is_comp = true
              end
            end
            if _is_comp
              Here_::As_Completion___
            else
              Here_::As_While_
            end
          elsif x.nil?
            As_Is___
          else
            Here_::As_Negative___
          end

          _cls.new_ kns
        end

        def new_ kns
          new.__init kns
        end
        alias_method :new_empty_c15n__, :new
        private :new
      end  # >>

      def __init kns
        @knowns_ = kns
        @on_pre_articulation_ = nil
        self
      end

      attr_writer(
        :line,
        :on_pre_articulation_,
      )

      def build_line

        @prefix_ = nil ; @suffix_ = nil
        ___unparenthesize_the_line
        __downcase_the_first_letter
        __do_something_special
        "#{ @_open }#{ @prefix_ }#{ @content_ }#{ @suffix_ }#{ @close_ }"
      end

      def ___unparenthesize_the_line
        _line = remove_instance_variable :@line
        @_open, @content_, @close_ =
          Home_.lib_.basic::String.unparenthesize_message_string( _line )
        NIL_
      end

      def __downcase_the_first_letter
        Mutate_by_downcasing_first___[ @content_ ]
      end

      def __do_something_special
        p = @on_pre_articulation_
        if p
          p[]
        else
          ___when_event_or_when_emission
        end
        NIL_
      end

      attr_writer(  # typically called during the above hook
        :prefix_,
        :suffix_,
        :close_,
      )

      attr_reader(
        :close_,  # used to be private to this concern..
      )

      def ___when_event_or_when_emission

        ev = @knowns_.event
        if ev
          @event_ = ev
          when_event_
        else
          when_emission_
        end
        NIL_
      end

      # --

      class As_Is___ < self

        def when_emission_
          NIL_
        end

        def when_event_
          NIL_
        end
      end

      # --

      def do_as__ m, cls  # ick/wow

        o = cls.new_empty_c15n__
        instance_variables.each do |i|
          UNDERSCORE_ == i[ 1 ] and next  # experiment
          o.instance_variable_set i, instance_variable_get( i )
        end
        o.send m
        @prefix_ = o.prefix_  # (always nil to date)
        @content_ = o.content_  # (always same object to date)
        NIL_
      end

      def looks_like_one_word_
        LOOKS_LIKE_ONE_WORD_RX___ =~ @content_
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
