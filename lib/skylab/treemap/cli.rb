require_relative 'api'

module Skylab::Treemap

  class CLI < Skylab::Porcelain::Bleeding::Runtime
    desc "experiments with R."

    Bleeding = Skylab::Porcelain::Bleeding # pls don't ask

    extend Skylab::Autoloader
    extend Bleeding::DelegatesTo
    extend Skylab::PubSub::Emitter

    emits Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all, error: :all
    event_class API::Event

    delegates_to :stylus, :do_stylize=, :em, :pre

    def api
      @api ||= API::Client.new
    end

    PARENS = %r{\A(?<open>\()(?<message>.*)(?<close>\))\z}

    def format prefix, e
      msg = e.message
      parens = msg.match(PARENS) and msg = parens[:message]
      msg = "#{prefix} #{msg}"
      if Hash === e.payload and e.payload[:path]
        msg = "#{msg}: #{e.path.pretty}"
      end
      parens and msg = "#{parens[:open]}#{msg}#{parens[:close]}"
      msg
    end

    def initialize
      namespace_init
      @stylus = Stylus.new
      yield self
    end

    def porcelain # @todo 100.200 not here
      self.class
    end

    actions_module { CLI::Actions }

    attr_reader :stylus

    def wire_action action
      verb = action.class.inflection.stems.verb
      inflected = action.class.inflection.inflected
      action.on_info_line { |e| emit(:info, e) }
      action.on_payload { |e| emit(e) }
      action.on_info do |e|
        emit(:info, format("#{em 'o'} #{inflected.noun} #{verb.progressive}", e))
      end
      action.on_error do |e|
        emit(:error, format("#{stylize 'o', :red} couldn't #{verb} #{inflected.noun}:", e))
      end
    end
  end
  module CLI::Actions
  end
  class CLI::Action
    extend CLI::Bleeding::Action
    extend CLI::Bleeding::DelegatesTo
    delegates_to :runtime, :api
    def wire
      @wire ||= ->(action) { wire_action(action) }
    end
    def wire_action api_action
      runtime.wire_action api_action
      api_action.stylus = runtime.stylus
      runtime.stylus.wire! self.class, api_action
      api_action
    end
  end
  class CLI::Actions::Install < CLI::Action
    desc "for installing R"

    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
  class CLI::Actions::Render < CLI::Action
    delegates_to :runtime, :info, :stylus
    delegates_to :stylus, :param
    desc "render a treemap from a text-based tree structure"
    fml = ->(ctx) do
      ctx.kind_of?(OptionParser) or return []
      s = CLI::Stylus.new.wire!(self, API::Actions::Render)
      stop, impl = [:stops_after, :stop_implied].map { |x| s.action_attributes.with(x) }
      ["(can appear after #{s.and( (stop.keys - impl.keys).map { |k| s.param k } )}) " <<
        "(implied after #{s.and( impl.keys.map{ |k| s.param k } )})" ]
    end
    option_syntax do |o|
      o[:char] = '+'
      o[:exec] = true
      on('-c', '--char <CHAR>', %{use CHAR (default: #{o[:char]})}) { |v| o[:char] = v }
      on('--tree', 'show the text-based structure in a tree (debugging)') { o[:show_tree] = true }
      on('--csv', 'output the csv to stdout instead of tempfile, stop.') { o[:csv_stream] = :payload }
      on('--r-script', 'output to stdout the generated r script, stop.') { o[:r_script_stream] = :payload }
      on('--stop', 'stop execution after the previously indicated step', *fml[self]) { o[:stop] = true }
      on('-F', '--force', 'force overwriting of an exiting file') { o[:force] = true }
      on('--[no-]exec', "the default is to open the file with exec") { |v| o[:exec] = v }
    end
    attr_reader :api_action
    def execute path, opts
      action = @api_action = api.action(:render).wire!(&wire)
      parse_opts(opts) or return
      do_exec = opts.delete(:exec)
      action.on_treemap do |e|
        if do_exec and e.path.exist? and ! action.stop_before?(:exec_open_file)
          action.info("calling exec() to open the pdf!")
          exec("open #{e.path}")
        end
      end
      ok = action.invoke(opts.merge!(path: path))
      false == ok and help_invite
      ok
    end
    def parse_opts opts
      opts[:stop] and (parse_opts_stop(opts) or return)
      true
    end
    def parse_opts_stop opts
      opt_to_event = api_action.attributes.with(:stops_after)
      event_to_opt = opt_to_event.invert
      order = api_action.order.map{ |e| event_to_opt[e] }.compact
      given = (opts.keys & [:stop, *order])
      given.pop while :stop != given.last
      if 1 == given.size
        api_action.error("#{param :stop} must come somewhere after at least one of " <<
          "#{oxford_comma(order.map{|x| param x}, ' or ')}")
        help_invite
        nil
      else
        opts[:stop_after] = opt_to_event[given[-2]] or fail('logic error')
        opts.delete(:stop)
        true
      end
    end
  end
  class << CLI
    def build_client_instance runtime, slug
      new do |c|
        c.program_name = slug
        c.on_error   { |e| runtime.emit(:error, e) }
        c.on_help    { |e| runtime.emit(:help,  e) }
        c.on_info    { |e| runtime.emit(:info, e) }
        c.on_payload { |e| runtime.emit(:payload, e) }
        c.do_stylize = runtime.err.tty?
        runtime_instance_settings and runtime_instance_settings.call(c) # @todo #100.200
      end
    end
    def porcelain # @todo #100.200 not here
      self
    end
    attr_accessor :runtime_instance_settings
  end
  class CLI::Stylus
    include Skylab::Porcelain::Bleeding::Styles
    def initialize
      @active = true
    end
    attr_reader :action_attributes
    attr_reader :active
    alias_method :and, :oxford_comma
    def bad_value value
      pre value.inspect
    end
    def do_stylize= bool
      if @active != (b = !! bool)
        singleton_class.send(:alias_method, :stylize, b ? :orig_stylize : :plain)
        @active = b
      end
      bool
    end
    alias_method :orig_stylize, :stylize
    def option_syntax= os
      @option_syntax_options = nil
      @option_syntax = os
    end
    def option_syntax_options
      @option_syntax_options ||= begin
        unless @option_syntax.respond_to?(:options)
          @option_syntax.extend CLI::OptionSyntaxReflection
        end
        @option_syntax.options
      end
    end
    def or a
      oxford_comma(a, ' or ')
    end
    def param name
      s =
      if option_syntax_options.key?(name)
        option_syntax_options[name].long_name
      elsif action_attributes.key?(name)
        action_attributes[name].label
      else
        name
      end
      pre s
    end
    def plain(s, *a)
      s
    end
    def wire! cli_action_meta, api_action_meta
      @action_attributes = api_action_meta.attributes
      self.option_syntax = cli_action_meta.option_syntax
      self
    end
  end
end

