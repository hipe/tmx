module Skylab::Snag
  class CLI
    extend Porcelain
    include Headless::NLP::EN::Methods

    desc "Add an \"issue\" line to doc/issues.md" # used to by dynamic [#hl-025]
    desc "Lines are added to the top and are sequentially numbered."

    desc ' arguments:' #                      DESC # should be styled [#hl-025]

    argument_syntax '<message>'
    desc '   <message>                        a one line description of the issue'

    option_syntax do |ctx|
      on('-n', '--dry-run', "don't actually do it") { ctx[:dry_run] = true }
      on '-v', '--verbose', 'verbose output' do ctx[:verbose] = true end
    end

    def add message, ctx
      api.action(:node, :add).wire!(&wire).invoke(ctx.merge( message: message ))
    end


    desc "show the details of issue(s)"

    action.alias 'list'

    option_syntax do |ctx|
      # @todo we would love to have -1, -2 etc
      on('-l', '--last <num>', '--limit <num>',
         "shows the last N issues") { |n| ctx[:last] = n }
    end

    argument_syntax '[<identifier>]'

    def show identifier=nil, ctx
      action = api.action(:node, :show).wire!(&wire)
      client = runtime # this is a part we don't like
      # @todo: for:#102.901.3.2.2 : wiring should happen between
      # the api action objects and the "client" (interface) instance that
      # invoked the api action.
      # all.rb does this confusing thing by having non-configurable core clients


      action.on_error_with_manifest_line do |e|

        client.emit :info, '---'
        client.emit :error, "error on line #{ e.line_number }-->#{ e.line }<--"

        e.message = "failed to parse line #{ e.line_number } because #{
          }#{ e.invalid_reason } (in #{ escape_path e.pathname })"

      end

      h = { identifier: identifier }.merge! ctx
      action.invoke h
    end


    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    # @todo: bug with "tmx issue number -h"
    def numbers
      api.action(:issue, :number, :list).wire!(&wire).invoke
    end


    desc "a report of the @todo's in a codebase"

    option_syntax do |o|
      d = Snag::API::Actions::ToDo::Report.attributes.with :default

      on('-p', '--pattern <PATTERN>',
        "the todo pattern to use (default: '#{d[:pattern]}')"
        ) { |p| o[:pattern] = p }
      on('--name <NAME>',
        "the filename patterns to search, can be specified",
        "multiple times to broaden the search (default: '#{d[:names] * "', '"}')"
        ) { |n| (o[:names] ||= []).push n }
      on('--cmd', 'just show the internal grep / find command',
         'that would be used (debugging).') { o[:show_command_only] = true }
      on('-t', '--tree', 'experimental tree rendering') { o[:show_tree] = true }

    end

    argument_syntax '<path> [<path> [..]]'

    def todo *paths, opts
      res = nil
      action = api.action( :to_do, :report ).wire!(&wire)
      action.on_number_found do |e|
        runtime.emit :info, "(found #{ e.count } item#{ s e.count })"
      end
      show_tree = opts.delete( :show_tree )
      if show_tree
        tree = CLI::ToDo::Tree.new action, runtime
      end
      res = action.invoke opts.merge( paths: paths )
      if show_tree
        res = tree.render
      end
      res
    end

  protected

    # hide the old way / new way dichotomy in here ..
    def initialize *sin_sout_serr
      @program_name = nil
      if block_given?
        super
      else
        up, pay, info = sin_sout_serr
        pay or raise ::ArgumentError.new "missing required paystream (2nd) arg"
        info or raise ::ArgumentError.new "missing required infostream (3rd) arg"
        wiring = -> o do
          o.on_payload { |e| pay.puts  e.message }
          o.on_error   { |e| info.puts e.message }
          o.on_info    { |e| info.puts e.message }
          o.invocation_slug = @program_name
        end
        super(& wiring)
      end
    end

    def api
      @api ||= Snag::API::Client.new self
    end

    define_method :escape_path, &Headless::CLI::PathTools::FUN.pretty_path

    def invite api_action
      full = [ program_name, * api_action.normalized_action_name ]
      full[ -1, 0 ] = [ '-h' ]    # wonderhack - you want penult
      full = full.join ' '
      msg = "try #{ full }."
      runtime.emit :help, msg     # kill it with fire
      nil # we processed the false so don't propagate it
    end

    def invoke argv
      Headless::CLI::PathTools.clear
      super argv
    end

    def program_name
      @program_name || ::File.basename( $PROGRAM_NAME ) # etc kill it with fire
    end

    attr_writer :program_name

    def wire
      @wire ||= ->(action) { wire_action(action) }
    end

    # this nonsense wires your evil foreign (frame) runtime to the big deal parent
    def wire! runtime, parent
      runtime.event_class = Snag::API::MyEvent
      runtime.on_error { |e| parent.emit(:error, e.touch!) }
      runtime.on_info  { |e| parent.emit(:info, e.touch!) }
      runtime.on_all   { |e| parent.emit(e.type, e) unless e.touched? }
    end

    def wire_action action        # #todo this is nice in constructors for
      action.on_payload { |e| runtime.emit(:payload, e) }   # cli actions
      action.on_error do |e|
        e.message = "failed to #{ e.verb } #{ e.noun } - #{ e.message }"
        runtime.emit :error, e
      end
      action.on_info do |e|
        unless e.touched?
          md = %r{\A\((.+)\)\z}.match(e.message) and e.message = md[1]
          e.message = "while #{e.verb.progressive} #{e.noun}, #{e.message}"
          md and e.message = "(#{e.message})" # so ridiculous
          runtime.emit(:info, e)
        end
      end
    end
  end
end
