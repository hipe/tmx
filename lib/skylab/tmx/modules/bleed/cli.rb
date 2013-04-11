class Skylab::TMX::CLI
  namespace :bleed, -> do
    ::Skylab::TMX::Modules::Bleed::CLI
  end
end

module Skylab

  class TMX::Modules::Bleed::CLI < Face::CLI

    # summary "run a bleeding edge version of tmx"  # #todo - later or never

    default_argv :load

    tmxconfig = -> do
      TMX::Models::Config::PATH
    end

    option_parser do |o|
      o.banner = "Inits a #{ tmxconfig[] }"
    end

    def init
      api :init do |o|
        handle o, :head, :tail, :error, :info
      end
    end

    option_parser do |o|
      o.banner = @command.usage_line

      o.separator "\n#{ hi 'description:' } Gets or sets path to the #{
        }bleeding-edge tmx codebase.\n#{
        }note this does not change your PATH or what the tmx executable\n#{
        }points to (see 'load'))"
    end

    def path path=nil
      path ? set_path( path ) : get_path
    end

    def set_path path
      api [ :path, :set ], path do |o|
        handle o, :head, :tail, :error, :notice, :info
      end
    end
    protected :set_path

    def get_path
      api [ :path, :get ] do |o|
        handle o, :path, :error, :notice
      end
    end
    protected :get_path

    option_parser do |o|
      o.banner = "#{ hi 'description:' } outputs to stdout the bash #{
        }commands to hack your path"
      o.separator "to use the bleeding edge version of tmx per #{ tmxconfig[] }"
    end

    def load
      api :load do |o|
        handle o, :bash, :error, :notice
      end
    end

    option_parser do |o|
      o.banner = "#{ hi 'description:' } outputs to stdout the bash #{
        }commands to unhack your path"
      o.separator "(the opposite of `bleed`)"
    end

    def unbleed
      api :unbleed do |o|
        handle o, :bash, :error, :notice
      end
    end

  private

    def api *a, &b
      @api ||= TMX::Modules::Bleed::API::Client.new
      @api.invoke( *a, &b )
    end

    def handle o, *event_a
      event_a.each do |event_stream_name|
        if ! o.emits? event_stream_name
          raise "#{ event_stream_name.inspect } is not emitted by #{ o.class }"
        else
          o.on event_stream_name, method( "handle_#{ event_stream_name }" )
        end
      end
      o.if_unhandled_non_taxonomic_streams :raise
      nil
    end

    def handle_head e
      @err.write "#{ invocation_str }: #{ atom e }"
      nil
    end

    alias_method :invocation_str, :last_child_invocation_string

    def atom e
      e.payload_a.fetch 0
    end

    def handle_tail e
      @err.puts atom( e )
      nil
    end

    def handle_error e
      @err.puts "#{ invocation_str } error: #{ atom e }"
      false
    end

    def self.define_protected_method a, &b
      define_method a, &b
      protected a
    end

    [ :notice, :info ].each do |event_stream_name|
      define_protected_method "handle_#{ event_stream_name }" do |e|
        @err.puts "#{ invocation_str } #{ event_stream_name }: #{ atom e }"
        nil
      end
    end

    [ :bash, :path ].each do |event_stream_name|
      define_protected_method "handle_#{ event_stream_name }" do |e|
        @out.puts atom( e )
        nil
      end
    end
  end
end
