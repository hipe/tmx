module Skylab::Cull

  class CLI::Client < Face::CLI

    include CLI::Namespace::InstanceMethods

    Headless::Plugin::Host.enhance self do
      service_names %i| pth |
    end

    option_parser do |o|
      o.separator "#{ hi 'description:' } wanktasktic awesomeness"

      o.separator "#{ hi 'options:' }"

      dry_run_option o

      o.banner = @command.usage_line
    end

    def init path=nil
      path ||= api_client.config_file_default_init_path
      api path
    end

    option_parser do |o|
      o.separator "#{ hi 'description:' } display status of config file"

      o.separator "#{ hi 'option:' }"
      @param_h[:do_list_file] = false
      o.on '-l', '--list-file', 'only write the file to stdout.' do
        @param_h[:do_list_file] = true
      end
      o.banner = @command.usage_line
    end

    def status
      api
    end

    namespace :'data-source', -> do
      CLI::Actions::DataSource
    end, aliases: [ 'ds' ]

    def initialize( * )
      super
      @pth = -> pn do
        if @action.be_verbose
          pn.to_s
        else
          Headless::CLI::PathTools::FUN.pretty_path_safe[ pn ]
        end
      end
    end

    attr_reader :pth
    private :pth

  private

    def invoked( * )
      res = super
      if false == res
        @y << "try #{ hi "#{
            last_child_invocation_string || invocation_string
          } -h" } for help."  # a hack for now.. one day we will unify this
        res = nil  # probably ignored anyway..
      end
      res
    end

    def on_payload_line e
      @out.puts e.payload_a.fetch( 0 )
      nil
    end

    def on_payload_lines e
      e.payload_lines.each do |line|
        @out.puts line
      end
      nil
    end

    def on_info_line e
      @err.puts e.payload_a.fetch( 0 )
      nil
    end

    def on_normalization_failure_line e
      @y << "#{ last_child_invocation_string }: #{ e.payload_a.fetch 0 }"
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

    def on_entity_event e
      str = instance_exec( & e.payload_a.fetch( 0 ).message_function )
      @y << "#{ last_child_invocation_string }: #{ str }"
      nil
    end
  end
end
