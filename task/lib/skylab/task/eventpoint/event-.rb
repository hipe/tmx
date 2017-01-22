class Skylab::Task

  module Eventpoint::Event_

    # #NOTE: these guys are ANCIENT and shoehorned into a newer paradigm.
    # they aren't getting a deeper refactor because emissions are an
    # auxiliary side to our central function

    # as they are the look to be like a dictionary (alphabetical, once)
    # of phrase-specific expression micro-agents

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

        Ambiguity = o[ -> ep, pred_a do
          "express transitions of the same strength from #{
            }#{ The_state_[ ep ] }"
        end ]

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

      "#{ _v } the system from #{ The_state__[ current_state_symbol ] }#{
        } to a finished state"
    end


        Client__ = -> client_x do
          "#{ client_x.intern }"
        end

        Client = o[ Client__ ]

        Exist = -> do
          h = {
            present: -> n { 1 == n ? 'is' : 'are' },
            past: -> n { 1 == n ? 'was' : 'were' }
          }.freeze
          o[ -> tense_i, a do
            "there #{ h.fetch( tense_i )[ a.length ] }"
          end ]
        end.call

        Got_passed = o[ -> ep, a do
          if 1 == a.length
            "failed to get passed #{ The_state_[ ep ] }"
          else
            "got passed #{ The_state_[ ep ] }"
          end
        end ]

        Had_no_effect = o[ -> ep_a do

          _ = Common_::Oxford_or[ ep_a.map( & The_state_ ) ]

          "will have no effect because the system does not reach #{ _ }"
        end ]

        Reach = o[ -> ep do
          self._FLAGGED
          "cannot reach #{ The_state_[ ep ] }"
        end ]

        Signature = o[ -> sig do
          Client__[ sig.client ]
        end ]

        Unmet_Reliance = o[ -> ep do
          "cannot operate without reaching #{ The_state_[ ep ] }"
        end ]


    # == n

    Nothing = new.call(){ "nothing" }

    # == v

    # == conjunctive

    Therefor = new.call() { "so" }

    # == support

    The_state__ = -> ep do
      "the #{ Ep__[ ep ] } state"
    end

    Ep__ = -> sym do

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
