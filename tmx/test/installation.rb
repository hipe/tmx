module Skylab::TMX::TestSupport

  module Installation

    # ==

    class StubInstallation < Home_::SimpleModel_

      def initialize
        @_fake_sidesystem_entry_strings = []
        yield self
        @_fake_sidesystem_entry_strings.freeze
      end

      # -- write

      def add_fake_sidesystem s
        @_fake_sidesystem_entry_strings.push s
      end

      # -- read

      def to_sidesystem_load_ticket_stream
        _cached_box.to_value_stream
      end

      def load_ticket_via_normal_symbol_softly sym
        lt = _cached_box[ sym ]
        if lt
          lt
        else
          NIL  # covered - needs to be hit to activate fuzzy
        end
      end

      def _cached_box
        @___cached_box ||= __build_cached_box
      end

      def __build_cached_box
        bx = Common_::Box.new
        Require_mocked_load_ticket___[]
        @_fake_sidesystem_entry_strings.each do |string|
          _guy = __Build_load_ticket_from_fake_sidesys_entry_string string
          bx.add string.intern, _guy
        end
        bx.freeze
      end

      def __Build_load_ticket_from_fake_sidesys_entry_string entry_string

        _ = Home_::Models_::GemNameElements.define do |gne|
          __define_gem_name_elements gne, entry_string
        end
        DummyLoadTicket___.new _
      end

      def __define_gem_name_elements gne, entry_string
        gne.entry_string = entry_string
        gne.gem_path = :_NOT_USED_tmx_
        gne.gem_name = "#{ ZIM_ZUM_ }#{ entry_string }"
        gne.const_head_path = CPH___
        gne.exe_prefix = "EXE_PREFIX"
      end

      def participating_gem_prefix
        ZIM_ZUM_
      end

      def participating_exe_prefix
        MEH___
      end

      CPH___ = %i( ZimZum ).freeze
      MEH___ = 'PARTICI_EXE_PFX_NO_SEE-'
      ZIM_ZUM_ = 'zim_zum-'.freeze
    end

    # ==
    # NOTE - most of the below work is to mock out a conventional, minimal CLI
    # ==

    Require_mocked_load_ticket___ = Lazy_.call do

      class DummyLoadTicket___ < Home_::Models_::LoadTicket

        def __induce_sidesystem_module
          _names = Names___.new _const_path_array_guess_, @gem_name_elements
          DummySidesystemModule___.new _names
        end
      end
      NIL
    end

    # ==

    class DummySidesystemModule___

      # for now we aren't going to cover all the different ways a sidesystem
      # can fail to play along with being mounted by a tmx, so:

      def initialize names
        @names = names
      end

      def const_get const, _=nil
        :CLI == const || fail
        DummyCLIClass___.new @names
      end
    end

    # ==

    class DummyCLIClass___

      def initialize names
        @names = names
      end

      def new * _the_CLI_five
        DummyCLI___.new( * _the_CLI_five, @names )
      end
    end

    # ==

    class DummyCLI___

      def initialize argv, sin, sout, serr, pnsa, names
        @argv = argv
        @names = names
        @program_name_string_array = pnsa
        @serr = serr
        @sout = sout
      end

      def to_bound_call
        Common_::Bound_Call[ nil, self, :execute ]
      end

      def execute
        if @argv.length.zero?
          __when_zero
        elsif Home_::CLI::HELP_RX =~ @argv.first
          __when_help
        else
          self.__WHEN_not_zero_not_help
        end
      end

      def __when_help
        if 1 == @argv.length
          @serr.puts "i am help for #{ _program_name }"
          NOTHING_
        else
          self.__HELP_WITH_ARGUMENTS
        end
      end

      def __when_zero
        @serr.puts "hello from #{ _moniker }"
        NOTHING_
      end

      def _program_name
        @program_name_string_array * Home_::SPACE_
      end

      def _moniker
        "dummy #{ [ * @names.const_path_array_guess, :CLI ] * '::' }"
      end
    end

    # ==

    Names___ = ::Struct.new :const_path_array_guess, :gem_name_elements

    # ==
  end
end
# #history: full rewrite, clobbering [br]-era "mocks"
