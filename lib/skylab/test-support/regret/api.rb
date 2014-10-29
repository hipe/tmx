module Skylab::TestSupport

  module Regret

    module API
      API = self
      Autoloader_ = Autoloader_
      Callback_ = Callback_
      CONST_SEP_ = CONST_SEP_
      DEFAULT_CORE_BASENAME_ = "core#{ Autoloader_::EXTNAME }"
      EMPTY_A_ = [].freeze
      EMPTY_P_ = -> {}
      EMPTY_S_ = EMPTY_S_
      Lib_ = TestSupport_::Lib_
      Library_ = TestSupport_::Library_
      NEWLINE_ = TestSupport_::NEWLINE_
      Plugin_ = TestSupport_::Lib_::Heavy_plugin[]
      Regret = Regret
      TestSupport_ = TestSupport_
      WRITE_MODE_ = 'w'.freeze

      module RegretLib_

        sidesys = TestSupport_::Autoloader_.build_require_sidesystem_proc

        Autoloader = -> do
          Autoloader_
        end

        Bsc__ = Lib_::Bsc__

        Basic_Fields = -> * x_a do
          MH__[]::Basic_Fields.via_iambic x_a
        end

        Box = Lib_::Box

        CLI_lib = -> do
          HL__[]::CLI
        end

        Dev_null = -> do
          HL__[]::IO.dry_stub_instance
        end

        EN_calculate = -> & p do
          HL__[].expression_agent.NLP_EN_agent.calcuate( & p )
        end

        EN_add_methods = -> mod, * x_a do
          HL__[].expression_agent.NLP_EN_methods.on_mod_via_iambic mod, x_a
        end

        Field_exponent_proc = -> do
          MH__[]::Parse.fields.exponent
        end

        Hashtag_scanner = -> s do
          Snag__[]::Models::Hashtag.scanner s
        end

        HL__ = Lib_::HL__

        Ick = -> x do
          MH__[].strange x
        end

        Ivars_with_procs_as_methods = -> * a do
          MH__[]::Ivars_with_Procs_as_Methods.via_arglist a
        end

        IT__ = sidesys[ :InformationTactics ]

        Levenshtein = -> do
          IT__[]::Levenshtein
        end

        MH__ = Lib_::MH__

        Name_normal_to_slug = -> i do
          HL__[]::Name.slugulate( i )
        end

        Name_slug_to_const = -> s do
          s_ = HL__[]::Name.metholate( s )
          s_[ 0 ] = s_[ 0 ].upcase
          s_.intern
        end

        Name_symbol_to_label = -> i do
          HL__[]::Name.labelize( i ).downcase
        end

        Oxford_or = TestSupport_::Callback_::Oxford_or

        Parse_alternation = -> do
          MH__[]::Parse.alternation
        end

        Patch_lib = -> do
          System[].patch
        end

        Path_tools_clear = -> do
          HL__[].system.filesystem.path_tools.clear
        end

        Pathname_union = -> a do
          Bsc__[]::Pathname::Union[ * a ]
        end

        Pool = -> mod do
          MH__[]::Pool.enhance mod
        end

        Pretty_path_proc = -> do
          HL__[].system.filesystem.path_tools.pretty_path
        end

        Scanner = Lib_::Scanner

        Snag__ = sidesys[ :Snag ]

        Struct = Lib_::Struct

        System = -> do
          HL__[].system
        end

        SubTree__ = sidesys[ :SubTree ]


        Tree_walker = -> * x_a do
          SubTree__[]::Walker.new x_a
        end
      end
    end

    Lib_::API[][ self ]

    action_name_white_rx( /[a-z0-9]$/ )

    before_each_execution do
      API::RegretLib_::Path_tools_clear[]
    end

    module API

      def self.debug!
        ( @system_api_client ||= Client.new ).do_debug = true
      end

      class Client

        Plugin_::Host.enhance self do
          services :pth, :invitation
        end

        attr_accessor :do_debug

        def pth
          @pth ||= -> p { p }
        end

        def invitation
          # we don't have output resources on hand, so we cannot.
          nil
        end

        def service_provider_for ex  # for raw API calls, development hack -
          # if API.do_debug is on **at the time of the puts operation**
          # write the message to the system's stderr, else disregard the
          # message.
          @system_service_provider ||= begin
            @do_debug ||= nil
            stderr = Lib_::Stderr[]
            System_Services_.new( Dynamic_Puts_Proxy_.new do |s|
              @do_debug and stderr.puts s
            end )
          end
        end

      private

        def raw_request_param_a_notify y
          super
          y << :expression_agent_p << method( :get_expression_agent )
        end

        def get_expression_agent _bound
          Expression_agent_class__[].new
        end
      end

      class System_Services_ < RegretLib_::Struct[ :err ]
        Plugin_::Host.enhance self do
          services :err, :ivar
        end
      end

      class Dynamic_Puts_Proxy_ < ::Proc
        alias_method :puts, :call
      end

      class Action < Lib_::API[]::Action

        def set_vtuple x
          did = false
          @vtuple ||= begin ; did = true ; x end
          did or raise "sanity - vtuple already set"
        end

      private

        def snitch
          @sn ||= bld_snitch
        end

        def bld_snitch
          _vtu = @vtuple or raise say_no_vtuple
          _vtu.make_snitch @err, some_expression_agent
        end

        def say_no_vtuple
          "sanity -  no vtuple for this instance of #{ self.class }"
        end

        def generic_listener
          @generic_listener ||= bld_generic_listener_p
        end

        def bld_generic_listener_p
          Callback_::Listener::Proc_As_Listener.new do |e|
            if @vtuple[ e.volume ]
              @err.puts instance_exec( & e.message_proc )
              true
            end
          end
        end
      end

      Expression_agent_class__ = -> do
        Lib_::API_normalizer[]::Expression_agent_class[]
      end
    end
  end
end
