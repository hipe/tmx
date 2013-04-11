module Skylab::Cull

  class CLI::Client < Face::CLI

    include CLI::Namespace::InstanceMethods

    option_parser do |o|
      o.banner = "#{ hi 'description:' } wanktasktic awesomenesswat"
      o.separator @command.usage_line
      o.separator "#{ hi 'options:' }"

      @param_h[:is_dry_run] = nil
      o.on '-n', '--dry-run', 'dry-run.' do
        @param_h[:is_dry_run] = true
      end

      @param_h[:is_verbose] = nil
      o.on '-v', '--verbose', 'verbose.' do
        @param_h[:is_verbose] = true
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

  protected

    def initialize( * )
      super
      @last_norm_name = nil
      @pth = -> pn do
        if @action.is_verbose
          pn.to_s
        else
          Headless::CLI::PathTools::FUN.pretty_path[ pn ]
        end
      end
    end

    attr_reader :pth

    def api_client
      @api_client ||= API::Client.new
    end

    def set_behaviors action
      @action = action  # no
      action.pth = @pth
      nil
    end

    def handle_events action
      action.with_specificity do
        STREAM_A_.each do |stream_name|
          if action.emits? stream_name
            action.on stream_name, method( STREAM_H_.fetch( stream_name ) )
          end
        end
      end
      nil
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
    # provide a message function so we don't yet have to botehr with
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

    STREAM_H_ = { }
    rx = /^on_(.+)/
    STREAM_A_ = protected_instance_methods.reduce [] do |m, i|
      if rx =~ i
        stream_name = $~[1].intern
        m << stream_name
        STREAM_H_[ stream_name ] = i
      end
      m
    end

    def last_child_invocation_string
      if @last_norm_name
        "#{ invocation_string } #{ @last_norm_name * ' ' }"
      else
        super
      end
    end

    def visit_normalized_name a
      @last_norm_name = a
      nil
    end
  end
end
