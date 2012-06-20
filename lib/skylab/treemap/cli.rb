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

    context = mores = stylus = nil # doc hax
    more = ->(which) do
      context.kind_of?(OptionParser) or return []
      stylus ||= CLI::Stylus.new.wire!(self, API::Actions::Render)
      mores[which].respond_to?(:call) and mores[which] = stylus.instance_exec(&mores[which])
      mores[which]
    end
    mores = {
      a: ->() do
        aa = ['which treemap rendering adapter to use.']
        a = API::Actions::Render.adapters.names
        aa << ("(#{s a, :no}known adapter#{s a} #{s a, :is} #{self.and a.map{|x| pre x}})" <<
          " (default: #{pre action_attributes[:adapter_name][:default]})")
        aa << "(use in conjunction with #{param :help, :short} for adapter-specific options)"
        aa
      end,
      s: ->() do
        stop, impl = [:stops_after, :stop_implied].map { |x| action_attributes.with(x) }
        ["(can appear after #{self.and( (stop.keys - impl.keys).map { |k| param k } )}) " <<
         "(implied after #{self.and( impl.keys.map{ |k| param k } )})" ]
      end
    }

    option_syntax do |o|
      context = self
      o[:char] = '+'
      o[:exec] = true
      on('-a <NAME>', '--adapter <NAME>', * more[:a]){ |v| o[:adapter_name] = v }
      on('-c', '--char <CHAR>', %{use CHAR (default: #{o[:char]})}) { |v| o[:char] = v }
      on('--tree', 'show the text-based structure in a tree (debugging)') { o[:show_tree] = true }
      on('--csv', 'output the csv to stdout instead of tempfile, stop.') { o[:csv_stream] = :payload }
      on('--r-script', 'output to stdout the generated r script, stop.') { o[:r_script_stream] = :payload }
      on('--stop', 'stop execution after the previously indicated step', * more[:s]) { o[:stop] = true }
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
end

