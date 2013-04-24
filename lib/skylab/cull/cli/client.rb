module Skylab::Cull

  class CLI::Client < Face::CLI

    include CLI::Namespace::InstanceMethods

    option_parser do |o|
      o.banner = "#{ hi 'description:' } wanktasktic awesomenesswat"
      o.separator @command.usage_line
      o.separator "#{ hi 'options:' }"

      dry_run_option o

      @param_h[:be_verbose] = nil
      o.on '-v', '--verbose', 'verbose.' do
        @param_h[:be_verbose] = true
      end
    end

    def init path=nil
      api path
    end

    option_parser do |o|
      o.banner = "#{ hi 'description:' } display status of config file"
      o.separator @command.usage_line
    end

    def status
      api
    end

    namespace :'data-source', -> do
      CLI::Actions::DataSource
    end, aliases: [ 'ds' ]

  private

    def initialize( * )
      super
      @pth = -> pn do
        if @action.be_verbose
          pn.to_s
        else
          Headless::CLI::PathTools::FUN.pretty_path[ pn ]
        end
      end
    end

    def set_behaviors action
      @action = action  # no
      action.pth = @pth
      nil
    end

    def pth
      @pth  # for reading from model events
    end

    def on_payload_line e
      @out.puts e.payload_a.fetch( 0 )
      nil
    end

    def on_info_line e
      @err.puts e.payload_a.fetch( 0 )
      nil
    end

    def on_payload_data e
      @out.write e.payload_a.fetch( 0 )
      nil
    end

    def on_before e
      @err.write "#{ e.payload_a.fetch( 0 ).message_function[] } .."
      nil
    end

    def on_after e
      @err.puts " done (#{ e.payload_a.fetch( 0 ).bytes } bytes)."
      nil
    end

    # (during development life is easier if all structrual events
    # provide a message function so we don't yet have to bother with
    # custom per-action wiring.)

    def on_structural e
      @err.puts e.message_function.call
      nil
    end

    def on_all e
      @y << "#{ last_child_invocation_string } #{ e.stream_name }: #{
        }#{ e.payload_a.first }"
      nil
    end

    def on_model_event e
      str = instance_exec( & e.payload_a.fetch( 0 ).message_function )
      @y << "#{ last_child_invocation_string }: #{ str }"
      nil
    end
  end
end
