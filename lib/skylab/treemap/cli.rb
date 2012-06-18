require_relative 'api'
require 'skylab/porcelain/bleeding'

module Skylab::Treemap

  class CLI < Skylab::Porcelain::Bleeding::Runtime
    Bleeding = Skylab::Porcelain::Bleeding # pls don't ask

    extend Skylab::PubSub::Emitter

    emits Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all, error: :all
    event_class API::Event

    desc "experiments with R."

    def api
      @api ||= API::Client.new
    end

    PARENS = %r{\A(?<open>\()(?<message>.*)(?<close>\))\z}

    def format prefix, e
      msg = e.message
      parens = msg.match(PARENS) and msg = parens[:message]
      msg = "#{prefix}: #{msg}"
      if Hash === e.payload and e.payload[:path]
        msg = "#{msg}: #{e.path.pretty}"
      end
      parens and msg = "#{parens[:open]}#{msg}#{parens[:close]}"
      msg
    end

    def initialize
      namespace_init
      yield self if block_given?
      $stdout.tty? or def self.stylize(s, *a) ; s end # no color
    end

    def porcelain # @todo 100.200 not here
      self.class
    end

    actions_module { CLI::Actions }

    def wire
      @wire ||= ->(action) { wire_action(action) }
    end

    def wire_action action
      verb = action.class.inflection.stems.verb
      inflected = action.class.inflection.inflected
      action.on_info_line { |e| emit(:info, e) }
      action.on_payload { |e| emit(e) }
      action.on_info do |e|
        emit(:info, format("#{em 'o'} while #{verb.progressive} #{inflected.noun}", e))
      end
      action.on_error do |e|
        emit(:error, format("#{stylize 'o', :red} couldn't #{verb} #{inflected.noun}", e))
      end
    end
  end
  module CLI::Actions
  end
  class CLI::Action
    extend CLI::Bleeding::Action
    extend CLI::Bleeding::DelegatesTo
    delegates_to :runtime, :api, :wire
  end
  class CLI::Actions::Install < CLI::Action
    desc "for installing R"

    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
  class CLI::Actions::Render < CLI::Action
    desc "render a treemap from a text-based tree structure"
    option_syntax do |o|
      o[:char] = '+'
      o[:exec] = true
      on('-c', '--char <CHAR>', %{use CHAR (default: #{o[:char]})}) { |v| o[:char] = v }
      on('--tree', 'show the text-based structure in a tree (debugging)') { o[:show_tree] = true }
      on('--csv', 'output the csv to stdout instead of tempfile, stop.') { o[:show_csv] = true }
      on('--r-script', 'output to stdout the generated r script, stop.') { o[:show_r_script] = true }
      on('--stop', 'stop execution after the previously indicated step (where avail.)') { o[:stop] = true }
      on('-F', '--force', 'force overwriting of an exiting file') { o[:force] = true }
      on('--[no-]exec', "the default is to open the file with exec") { |v| o[:exec] = v }
    end
    def execute path, opts
      if opts[:stop] and (order = opts.keys & [:stop, :show_tree, :show_csv, :show_r_script]).any?
        # shed the ones that come after stop
        (bad = []).tap{|a| a.push(order.pop) while :stop != order.last }
        if order.size == 1
          emit(:info, "warning: no stoppable options came before --stop. ignoring.")
        else
          opts[:stop_after] = order[-2]
        end
      end
      opts.delete(:stop)
      do_exec = opts.delete(:exec)
      api.action(:render).wire!(&wire).tap do |action|
        action.on_treemap do |e|
          if ! opts[:stop_after] and e.path.exist? and do_exec
            info("calling exec() to open the pdf")
            exec("open #{e.path}")
          end
        end
      end.invoke(opts.merge!(path: path))
    end
  end
  class << CLI
    def build_client_instance runtime, slug
      new.tap do |c|
        c.program_name = slug
        c.on_error   { |e| runtime.emit(:error, e) }
        c.on_help    { |e| runtime.emit(:help,  e) }
        c.on_info    { |e| runtime.emit(:info, e) }
        c.on_payload { |e| runtime.emit(:payload, e) }
        runtime_instance_settings and runtime_instance_settings[c] # @todo #100.200
      end
    end
    def porcelain # @todo #100.200 not here
      self
    end
    attr_accessor :runtime_instance_settings
  end
end

