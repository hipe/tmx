module Skylab::TreetopTools

  class Parser::InputAdapters::File < Parser::InputAdapters::Stream

    attr_reader :pathname

    def type
      Parser::InputAdapter::Types::FILE
    end

    def default_entity_noun_stem
      'input file'
    end

    def whole_string
      ok = true

      if :initial == @state
        ok = whn_initial_state_move_state
      end

      if ok && :pathname == @state
        ok = whn_pathname_state_move_state
      end

      ok && super
    end

    def whn_initial_state_move_state

      if @upstream.respond_to? :ascii_only?
        pn = ::Pathname.new @upstream
      elsif @upstream.respond_to? :relative_path_from
        pn = @upstream
      end

      if pn
        @pathname = pn
        @upstream = nil
        @state = :pathname
        PROCEDE_
      else
        raise "expecting pathname string or pathmame, had #{ upstream.class }"
      end
    end

    def whn_pathname_state_move_state

      io = TreetopTools_::Lib_::System[].filesystem.normalization.upstream_IO(
        :path, @pathname.to_path,

        :on_event_selectively, -> * i_a, & ev_p do
          @block[ * i_a, & ev_p ]
        end )

      io and begin
        @upstream = io
        @state = :open
        PROCEDE_
      end
    end
  end
end
