module Skylab::TestSupport

  module Regret

    module API
      API = self
      DEFAULT_CORE_BASENAME_ = "core#{ Autoloader_::EXTNAME }"
      Lib_ = TestSupport_::Lib_
      Library_ = TestSupport_::Library_
      MetaHell = TestSupport_::Library_::MetaHell
      Plugin_ = TestSupport_::Lib_::Heavy_plugin[]
      Regret = Regret
      TestSupport = TestSupport_
      WRITEMODE_ = 'w'.freeze

      module RegretLib_
        Basic__ = Lib_::Basic__
        Box = Lib_::Box
        CLI_stylify = -> a, x do
          Headless__[]::CLI::Pen::FUN::Stylify[ a, x ]
        end
        Dev_null = -> do
          Headless__[]::IO::DRY_STUB
        end
        EN = -> p do
          Headless__::NLP::EN.calculate( & p )
        end
        EN_add_methods = -> mod, * x_a do
          Headless__[]::SubClient::EN_FUN.via_iambic_on_mod x_a, mod
        end
        Headless__ = Lib_::Headless__
        Name_normal_to_slug = -> i do
          Headless__[]::Name::FUN::Slugulate[ i ]
        end
        Name_slug_to_const = -> s do
          s_ = Headless__[]::Name::FUN::Metholate[ s ]
          s_[ 0 ] = s_[ 0 ].upcase
          s_.intern
        end
        Name_symbol_to_label = -> i do
          Headless__[]::Name::FUN::Labelize[ i ].downcase
        end
        List = -> do
          Basic__[]::List
        end
        Levenshtein = -> sep, p, d, a, s do
          Headless__[]::NLP::EN::Levenshtein::
            With_conj_s_render_p_closest_n_items_a_item_x[ sep, p, d, a, s ]
        end
        Oxford_or = TestSupport_::Callback_::Oxford_or
        Path_tools_clear = -> do
          Headless__[]::CLI::PathTools.clear
        end
        Pathname_union = -> a do
          Basic__[]::Pathname::Union[ * a ]
        end
        Pretty_path_proc = -> do
          Headless__[]::CLI::PathTools::FUN.pretty_path
        end
        Scanner = -> x do
          Basic__[]::List::Scanner[ x ]
        end
        Struct = Lib_::Struct
        SubTree__ = TestSupport_::Autoloader_.
          build_require_sidesystem_proc :SubTree
        Text_patch = -> do
          Headless__[]::Text::Patch
        end
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
