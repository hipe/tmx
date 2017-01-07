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

        gne = Real_node__[]::GemNameElements_.new
        gne.entry_string = entry_string
        gne.gem_path = :_NOT_USED_tmx_
        gne.gem_name = "#{ ZIM_ZUM_ }#{ entry_string }"
        gne.const_head_path = CPH___
        gne.exe_prefix = "EXE_PREFIX"
        DummyLoadTicket___.new gne
      end

      def participating_gem_prefix
        ZIM_ZUM_
      end

      CPH___ = %i( ZimZum ).freeze
      ZIM_ZUM_ = 'zim_zum-'.freeze
    end

    # ==
    # NOTE - most of the below work is to mock out a conventional, minimal CLI
    # ==

    Require_mocked_load_ticket___ = Lazy_.call do

      class DummyLoadTicket___ < Real_node__[]::LoadTicket_

        def __induce_sidesystem_module
          _names = Names___.new @const_path_array_guess, @gem_name_elements
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
        @serr = serr
        @sout = sout
      end

      def to_bound_call
        Common_::Bound_Call[ nil, self, :execute ]
      end

      def execute
        if @argv.length.zero?
          __when_zero
        else
          self.__WHEN_not_zero
        end
      end

      def __when_zero
        _ = "#{ [ * @names.const_path_array_guess, :CLI ] * '::' }"
        @serr.puts "hello from dummy #{ _ }"
        NOTHING_
      end
    end

    # ==

    Names___ = ::Struct.new :const_path_array_guess, :gem_name_elements

    # ==

    Real_node__ = -> do
      Home_::Models_::Installation
    end
  end

  Mocks = ::Module.new  # get rid of after rename :#here

end
# #pending-rename: to "installation.rb" from "mocks.rb" (see #here when you do)
# #history: full rewrite, clobbering [br]-era "mocks"
