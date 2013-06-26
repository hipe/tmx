class Skylab::TestSupport::Regret::API::Actions::DocTest

  Specer_::Block = MetaHell::Function::Class.new :accept, :flush
  class Specer_::Block

    # what this mess does: within a block of comments there can be N code
    # sections ("snippets"), each snippet preceded by zero or one
    # non-code line. interceding non-code lines are ignored. the first snippet
    # either does or does not have a non-code line before it, but each
    # subsequent snippet must have one non-code line preceding it,
    # by virtue of this grammar.

    def is_not_empty
      @snippet_a.length.nonzero?
    end

    def snippet_a
      @snippet_a
    end

    attr_reader :first_other

  private

    State_ = ::Struct.new :_name, :h

    -> do  # `initialize`

      define_method :initialize do |snitch|
        state = last_other = state_h = nil
        ign = -> _ { }
        store_contentful_hybrid_other = -> md do
          if md[:content]
            set_first_other md[:content]
            last_other = md[:content]
            state = state_h.fetch :watching
          end
        end
        store_contentful_last_other = -> md do
          if md[:content]
            last_other = md[:content]
          end
        end
        a = [ ]
        code_one = -> md do
          a << md[:content]
          state = state_h.fetch :code
        end
        code = -> md do
          a << md[:content]
        end
        ctx = nil
        shut = -> md do
          shut last_other, a, ctx
          last_other = md[:content]
          a = [ ]
          state = state_h.fetch :watching
        end
        o = State_
        state_h = {
          start: o[ :_start,
            other: store_contentful_hybrid_other,
            nbcode: code_one,
            blank: ign ],
          watching: o[ :_watching,
            other: store_contentful_last_other,
            nbcode: code_one,
            blank: ign ],
          code: o[ :_code,
            bcode: code,
            nbcode: code,
            other: shut ]
        }
        state = state_h.fetch :start
        @accept = -> transition do
          ctx = transition.comment_line
          state.h.fetch( transition.i ).call transition.md
          nil
        end
        @flush = -> do
          if a.length.nonzero?
            shut last_other, a, ctx
          end
          # (the outcome of `flush` is that @snippet_a is resolved.)
          nil
        end
        @snippet_a = [] ; @snitch = snitch
      end
    end.call

    def set_first_other x
      @first_other = x
      nil
    end

    def shut last_other, a, ctx
      # strip trailing blank lines
      a.pop while a.length.nonzero? and a.last.length.zero?
      if a.length.nonzero?
        sn = Specer_::Block::Snippet_.new last_other, a, ctx
        if sn.validate @snitch
          @snippet_a << sn
        end
      end
      nil
    end
  end

  class Specer_::Block::Snippet_

    def initialize last_other, a, ctx
      @last_other, @line_a, @context_x = last_other, a, ctx
    end

    attr_reader :last_other, :line_a

    -> do  # `validate`
      sep_rx = /#{ ::Regexp.escape SEP }/
      define_method :validate do |snitch|
        ln = @line_a.detect do |l|
          sep_rx =~ l
        end
        if ln then true else
          loc_desc = " (in block ending on line #{ @context_x.no })"
          snitch.event :medium, Event_[ -> do
            "(warning (?) - code snippet without magic #{
              }separator #{ SEP.inspect }#{ loc_desc })"
          end, @line_a ]
          nil
        end
      end
    end.call

    Event_ = ::Struct.new :message_function, :lines
  end
end
