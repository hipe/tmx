class Skylab::Task

  module Eventpoint::Event_

    # :NOTE: the original main content of this file was an ANCIENT
    # alphabetical list of what we now call "expression micro-agents".
    # "structured expressive agents" (pushed up to [#co-003.1]) are
    # generally the idea that you can have an object that is struct-like
    # but also knows how to express itself into a string under a general
    # modality-specific expression agent.
    #
    # we took this idea to an extreme here combined with another idea that
    # *all* EN for the library should be in this one file, ostensibly to
    # ease some future imagined pain of internationalization. some of our
    # "micro-agents" only existed to express one word! you still see traces
    # of that now.
    #
    # nowadays we find it impractical to hold ourself to this constraint,
    # but as for the expression micro-agents that remain,
    # they aren't getting a deeper refactor because emissions are an
    # auxiliary side to our central function

    # during the modernification, we became less concerned with keeping all
    # EN in one file so the responsibility of this file shrank. now it's
    # meant to be only expression support and *reusable* expression micro-
    # agents. those m.a's that were only used for one kind of event have
    # been pushed out to where they are used.

    o = Common_::Event::StructuredExpressive.method :new  # old way

    new = -> & p do  # new way
      o[ p ]
    end

    PendingExecutions = -> do

          h = {
            inclusive: -> n do
              case n
              when 0 ; 'no'
              when 1 ; 'the only'
              when 2 ; 'both of the'
              else   ; "all #{ Home_.lib_.basic::Number::EN.number n } of"
              end
            end,
            exclusive: -> n do
              case n
              when 0 ; 'no'
              when 1 ; 'the only'
              else   ; "none of the #{ Home_.lib_.basic::Number::EN.number n }"
              end
            end
          }

      new.call do |inclusive_or_exclusive, pending_executions|
        _p = h.fetch inclusive_or_exclusive
        num = pending_executions.length
        "#{ _p[ num ] } pending execution#{ 's' if 1 != num }"
      end
    end.call

    Finish = new.call do |
      current_state_symbol,
      inclusive_or_exclusive,
      pending_executions,
    |

      _v = case 1 <=> pending_executions.length
      when 1
        "brings"  # ick - only because "nothing brings" (compare "no things bring")
      when 0
        if :exclusive == inclusive_or_exclusive
          "does not bring"
        else
          "brings"
        end
      when -1
        "bring"
      end

      "#{ _v } the system from #{ Say_state[ current_state_symbol ] }#{
        } to a finished state"
    end

        Exist = -> do
          h = {
            present: -> n { 1 == n ? 'is' : 'are' },
            past: -> n { 1 == n ? 'was' : 'were' }
          }.freeze
          o[ -> tense_i, a do
            "there #{ h.fetch( tense_i )[ a.length ] }"
          end ]
        end.call



    # == n

    Nothing = new.call(){ "nothing" }

    # == v

    # == conjunctive

    Therefor = new.call() { "so" }

    # == support

    Say_pending_execution = -> pending_exe do
      x = pending_exe.mixed_task_identifier
      if x.respond_to? :id2name
        "'#{ x }'"
      else
        Eventpoint._DESIGN_ME
      end
    end

    smart_quote = nil

    Say_state = -> sym do
      "the #{ smart_quote[ sym ] } state"
    end

    smart_quote = -> sym do

      s = sym.id2name
      if s.include? SPACE_
        %("#{ s }")
      else
        s
      end
    end

    # ==

    # we have tried to modernized and simplify and clarify some names,
    # but mosty this exists to bridge the gap between rignt now and the
    # very old. was a goofy, fun, interesting experment called "grid"
    # and "grid frame". moved here from core at #history-B.

    class SentencePhrase < Common_::SimpleModel

      def initialize
        @conjunctive_phrase = nil
        super
      end

      attr_writer(
        :conjunctive_phrase,
        :noun_phrase,
        :verb_phrase,
      )

      def express_into_under y, expag
        _o = dup.extend SentencePhraseExpressionMethods___
        _o.__express_into_under_ y, expag
      end
    end

    module SentencePhraseExpressionMethods___

      def __express_into_under_ y, expag
        @_joiner_buffer = JoinerBuffer.new SPACE_
        @_expression_agent = expag
        _visit @conjunctive_phrase
        _visit @noun_phrase
        _visit @verb_phrase
        s = @_joiner_buffer.finish
        if s
          y << s
        end
        y
      end

      def _visit expresser
        if expresser
          expresser.express_into_under @_joiner_buffer, @_expression_agent
        end
      end
    end

    # ==

    And_buffer = Lazy_.call do
      JoinerBuffer.new ' and '
    end

    class JoinerBuffer

      # (this has to exist somewhere else in our universe, musn't it?)

      def initialize sep
        @_receive = :__receive_initially_when_raw
        @separator = sep
      end

      def dup_by
        otr = dup
        yield otr
        otr
      end

      def << s
        send @_receive, s
        self
      end

      def __receive_initially_when_raw s
        self.initial_buffer = ""
        send @_receive, s
      end

      def initial_buffer= s
        @_receive = :__receive_initially_normally
        @_buffer = s
      end

      def __receive_initially_normally s
        if s
          @_buffer << s
          @_receive = :__receive_normally
        end
      end

      def __receive_normally s
        if s
          @_buffer << @separator << s
        end
      end

      def finish
        x = remove_instance_variable :@_buffer
        remove_instance_variable :@_receive
        freeze
        x
      end
    end

    # ==
  end
end
# :#history-B: "grid" thing (now "sentence phrase") emigrates from core
# #history: begin massive rewrite (used to be "expressions")
