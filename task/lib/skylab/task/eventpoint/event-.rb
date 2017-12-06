class Skylab::Task

  module Eventpoint::Event_

    # #todo - de-orphanize this file

    # :NOTE: the original main content of this file was an ANCIENT
    # alphabetical list of what we now call "expressive micro-agents".
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
    # but as for the expressive micro-agents that remain,
    # they aren't getting a deeper refactor because emissions are an
    # auxiliary side to our central function

    # during the modernification, we became less concerned with keeping all
    # EN in one file so the responsibility of this file shrank. now it's
    # meant to be only expression support and *reusable* expression micro-
    # agents. those m.a's that were only used for one kind of event have
    # been pushed out to where they are used.

    # ==

    module ExpressionMethods   # re-opens

      def init_for_wonderful_expression_hack_ y, d_a=nil, up
        if d_a
          @offsets = d_a
        end
        @up = up ; @y = y ; self
      end

      def say_pending_execution_ickily_ exe
        @up.say_plugin_by[ exe.mixed_task_identifier, :ick, self ]
      end

      def say_current_state_
        say_state_ @up.current_state_symbol
      end

      def scanner_ x_a
        Scanner_[ x_a ]
      end
    end

    smart_quote = nil

    Say_state = -> sym do
      "the #{ smart_quote[ sym ] } state"
    end

    smart_quote = -> sym do

      s = sym.id2name.gsub UNDERSCORE_, SPACE_
      if s.include? SPACE_
        %("#{ s }")
      else
        s
      end
    end

    module ExpressionMethods   # re-open

      define_method :say_state_, Say_state
    end

    # ==

  end
end
# #tombstone-C: BYE BYE née "grid frame" (then "sentence phrase") AND "joiner buffer"
# :#history-B: "grid" thing (now "sentence phrase") emigrates from core
# #history: begin massive rewrite (used to be "expressions")
