module Skylab::Cull

  class CLI::Client < Face::CLI::Client

    # (see i.m's `prepend`'ed at the end!)

    def initialize( * )
      super
      @param_h = { }  # neither core lib nor n.s facet does this for you
      @pth = -> pn do
        if @mechanics.last_api_executable.be_verbose
          pn.to_s
        else
          Cull_._lib.pretty_path_safe pn
        end
      end
    end

    use :hi, :api, [ :last_hot, :as, :command ],
      [ :normal_last_invocation_string, :as, :last_invocation_string ]

    with_dsl_off do
      def invoke( * )
        res = super
        if false == res
          @y << "try #{ hi "#{ last_invocation_string } -h" } for help."
          res = nil
        end
        res
      end
    end                           # (reminder: this won't run when under tmx)

    set :node, :ping, :invisible

    def ping
      @y << "hello from cull."
      :hello_from_cull
    end

    option_parser do |o|
      o.separator "#{ hi 'description:' } wanktasktic awesomeness"

      o.separator "#{ hi 'options:' }"

      dry_run_option o

      o.banner = command.usage_line
    end

    def init directory=nil
      api directory
    end

    option_parser do |o|
      o.separator "#{ hi 'description:' } display status of config file"

      o.separator "#{ hi 'option:' }"
      @param_h[:do_list_file] = false
      o.on '-l', '--list-file', 'only write the file to stdout.' do
        @param_h[:do_list_file] = true
      end
      o.banner = command.usage_line
    end

    def status
      api
    end

    namespace :'data-source', -> { CLI::Actions::DataSource }, aliases: [ 'ds' ]

  private
  dsl_off  # (don't bother tracking the order in which methods are added)
           # (note that one day `private` might get hacked to do this
           # automatically but that feels so bad and wrong.)

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

    def on_normalization_failure_line_notify e
      @y << "#{ last_invocation_string }: #{ e.payload_a.fetch 0 }"
      nil
    end

    def on_payload_data e
      @out.write e.payload_a.fetch( 0 )
      nil
    end

    def on_before e
      _native_ev = e.payload_a.first
      _ev = _native_ev.renderable
      scan = _ev.scan_for_render_lines_under expression_agent
      while s = scan.gets
        @err.write "#{ s } .."
      end
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
      @err.puts e.message_proc.call
      nil
    end

    def on_all e
      @y << "#{ last_invocation_string } #{ e.stream_symbol }: #{
        }#{ e.payload_a.first }"
      nil
    end

    def on_entity_event e
      ev = e.payload_a.fetch 0
      p = ev.message_proc
      _expag = expression_agent
      _str = if p.arity.zero?
        _expag.calculate( & p )
      else
        _expag.calculate( * ev.to_a, & p )
      end
      @y << "#{ last_invocation_string }: #{ _str }"
      nil
    end

    prepend CLI::Namespace::InstanceMethods  # at end because of [#ri-002]

    Face::Plugin::Host::Proxy.enhance self do  # ditto [#ri-002]
      services [ :pth, :ivar ]  # api actions want to know how to render a path
                                # and we get a private method `plugin_host`
    end

    def expression_agent
      @expag ||= Expression_agent_class__[].new @pth
    end

    Expression_agent_class__ = Callback_.memoize do

      class Expag__

        def initialize pth
          @pth = pth
        end

        include Cull_::Lib_::HL__[]::SubClient::InstanceMethods  # :+#experimental

        alias_method :calculate, :instance_exec

        def escape_path x
          @pth[ x ]
        end

        def pth x
          @pth[ x ]
        end

        self
      end
    end
  end
end
