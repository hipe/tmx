module Skylab::Git::TestSupport

  module One_Off_As_Operation

    def self.[] tcc
      tcc.send :define_singleton_method, :given, Given___
      tcc.include self
    end

      Given___ = -> & p do

        yes = true ; x = nil
        define_method :ooao_state_ do
          if yes
            yes = false
            x = __ooao_init_state p
          end
          x
        end
      end

    # -

      # -- DSL & setup

      def __ooao_init_state p

        @_ooao_DSL_values = DSL_Values___.new
        instance_exec( & p )
        _sct = remove_instance_variable :@_ooao_DSL_values
        argv = _sct.argv
        if do_debug
          debug_IO.puts "running: #{ argv.inspect }"
        end

        _cli_class = subject_one_off_CLI_

        g = TestSupport_::IO.spy.group.new

        g.do_debug_proc = -> do
          do_debug
        end

        g.debug_IO = debug_IO

        g.add_stream :o
        g.add_stream :e

        _sout, _serr = g.values_at :o, :e

        system_once = -> do
          system_once = -> do
            fail
          end
          the_system_conduit_
        end

        _cli = _cli_class.new nil, _sout, _serr, PN_S_A___ do |o|
          o.system_by do
            system_once[]
          end
        end

        _es = _cli.invoke argv

        _lines = g.release_lines

        State___.new _lines, _es
      end

      def argv * s_a
        @_ooao_DSL_values.argv = s_a ; nil
      end

      def require_oneoff_as_operation_ entry
        Require[ entry ]
      end

      # -- assertions

      def succeeds
        d = ooao_state_.exitstatus
        if d.nonzero?
          d.should eql 0
        end
      end

      def build_screen_index__
        TS_::CommonTabularScreenIndex.new lines
      end

      def expect_part_ part
        x = _ooao_part_stream.gets
        if part != x
          x.should eql part
        end
      end

      def expect_no_more_output_lines_
        x = _ooao_part_stream.gets
        if x
          fail "unexpected extra output line (with: #{ x.inspect })"
        end
      end

      def _ooao_part_stream
        @___ooao_part_stream ||= __ooao_build_part_stream
      end

      def __ooao_build_part_stream
        Common_::Stream.via_nonsparse_array lines do |line|
          FOURTH_CEL_RX___.match( line.string )[ :cel ]
        end
      end

      def lines
        ooao_state_.lines
      end

    # -
    # ==

    cache = {}  # only because you can't `require` an executable file
    Require = -> entry do
      cache.fetch entry do
        x = Load_oneoff_as_operation___[ entry ]
        cache[ entry ] = x
        x
      end
    end

    rx = /\Atmx-git-(?<stem>[-a-z]+)\z/

    Load_oneoff_as_operation___ = -> entry do

      _ = Sidesystem_path__[]
      load ::File.join _, 'bin', entry

      # go from this: tmx-git-ferllew-ferwerd
      # to this:      Skylab_Git__ferllew_ferwerd__one_off

      md = rx.match entry
      _const_stem = md[ :stem ].gsub( DASH_, UNDERSCORE_ )
      _const = :"Skylab_Git__#{ _const_stem }__one_off"
      ::Object.const_get _const, false
    end

    Sidesystem_path__ = Lazy_.call do
      ::File.expand_path '../../..', Home_.dir_pathname.to_path
    end

    # ==

    DSL_Values___ = ::Struct.new :argv
    State___ = ::Struct.new :lines, :exitstatus

    # ==

    FOURTH_CEL_RX___ = /(?:\A(?:[^ ]+)(?:[ ][^ ]+){2}[ ])(?<cel>.+)/
    PN_S_A___ = %w( gizzy )
  end
end
