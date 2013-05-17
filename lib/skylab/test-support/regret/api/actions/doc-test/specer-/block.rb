class Skylab::TestSupport::Regret::API::Actions::DocTest

  Specer_::Block = MetaHell::Function::Class.new :accept, :flush
  class Specer_::Block

    # what this mess does: within a block of comments there can be N code
    # sections ("snippets"), each snippet preceded by zero or one
    # non-code line. interceding non-code lines are ignored. the first snippet
    # either does or does not have a non-code line before it, but each
    # subsequent snippet must have one non-code line preceding it,
    # by virtue of this grammar.

    -> do

      o = ::Struct.new :h

      define_method :initialize do |notice|
        state = last_other = state_h = nil ; ign = -> _ { }
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
        shut = -> md do
          _shut last_other, a
          last_other = md[:content]
          a = [ ]
          state = state_h.fetch :watching
        end
        state_h = {
          watching: o[
            { other: store_contentful_last_other,
              nbcode: code_one,
              blank: ign
            } ],
          code: o[ { bcode: code, nbcode: code, other: shut } ]
        }
        state = state_h.fetch :watching
        @accept = -> i, md do
          state.h.fetch( i ).call md
          nil
        end
        @flush = -> do
          if a.length.nonzero?
            _shut last_other, a
          end
        end
        @a = [] ; @notice = notice
      end
    end.call

    attr_reader :a

    def _shut last_other, a
      # strip trailing blank lines
      a.pop while a.length.nonzero? and a.last.length.zero?
      if a.length.nonzero?
        sn = Specer_::Block::Snippet.new last_other, a
        if sn.validate @notice
          @a << sn
        end
      end
      nil
    end
    private :_shut

    def is_not_empty
      @a.length.nonzero?
    end
  end

  class Specer_::Block::Snippet

    def initialize last_other, a
      @last_other, @a = last_other, a
    end

    attr_reader :last_other, :a

    -> do
      sep_rx = /#{ ::Regexp.escape SEP }/
      define_method :validate do |notice|
        ln = @a.detect do |l|
          sep_rx =~ l
        end
        if ln then true else
          notice[ Event_[ -> do
            "code snippet without magic separator #{ SEP.inspect }"
          end, @a ] ]
          nil
        end
      end
    end.call

    Event_ = ::Struct.new( :message_function, :lines )
  end
end
