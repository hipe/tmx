module Skylab::Snag
  class CLI
    extend MetaHell::Autoloader::Autovivifying::Recursive # used below
    include Headless::NLP::EN::Methods

  protected                       # (DSL happens at bottom half)

    # hide the old way / new way dichotomy in here ..
    def initialize *sin_sout_serr
      @program_name = nil
      if block_given?
        super
      else
        up, pay, info = sin_sout_serr
        pay or
          raise ::ArgumentError.new "missing required paystream (2nd) arg"
        info or
          raise ::ArgumentError.new "missing required infostream (3rd) arg"
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

    def api_invoke normalized_name, param_h=nil
      res = nil
      begin
        a = api.build_action( normalized_name ) or break( res = a )
        a = a.wire!(& wire) # [#010] how i long for you
        res = a.invoke param_h
      end while nil
      res
    end

    def error msg # away at [#010]
      porcelain.runtime.emit :error, "#{ program_name } says: #{ msg }"
      false
    end

    define_method :escape_path, &Headless::CLI::PathTools::FUN.pretty_path

    def info msg # away at [#010]
      porcelain.runtime.emit :info, "#{ program_name } wants you to know: #{
      }#{ msg }"
      nil
    end

    def invite api_or_cli_action_instance
      nan = if ::Array === api_or_cli_action_instance  # no CLI::Actions yet
        api_or_cli_action_instance
      else
        api_or_cli_action_instance.send :normalized_action_name
      end
      full = [ program_name, * nan, '-h' ].join ' '
      msg = "#{ kbd full } might have more information"
      runtime.emit :help, msg     # kill it with fire
      nil # we processed the false so don't propagate it
    end

    def invoke argv               # modify at [#010]
      Headless::CLI::PathTools.clear # see
      res = super argv            # (handles invites when parsing goes wrong)
      if false == res             # (but otherwise when we result in false..)
        # in the future: emit :help, invite_lite
        porcelain.runtime.stack.first.issue
        res = nil
      end
      res
    end
    public :invoke

    def program_name
      @program_name || ::File.basename( $PROGRAM_NAME ) # etc kill it with fire
    end

    attr_writer :program_name
    public :program_name=

    # --*--

    extend Porcelain                           # now entering DSL zone

    desc "Add an \"issue\" line to #{ Snag::API.manifest_file_name }" #[#hl-025]
    desc "Lines are added to the top and are sequentially numbered."

    desc ' arguments:' #                      DESC # should be styled [#hl-025]

    argument_syntax '<message>'
    desc '   <message>                        a one line description of the issue'

    option_syntax do |param_h|                 # (away at [#010] these two lines
      o = self                                 #  to `option_parser do |o|`.
                                               #  This is repeated in this file)
      o.on '-n', '--dry-run', "don't actually do it" do
        param_h[:dry_run] = true
      end
      o.on '-v', '--verbose', 'verbose output' do
        param_h[:verbose] = true
      end
    end

    def add message, param_h
      api_invoke [:nodes, :add],
        { message: message }.merge( param_h )
    end

    # --*--

    desc "show the details of issue(s)"

    action.aliases 'ls', 'show'

    option_syntax do |param_h|
      o = self
      o.on '-a', '--all', 'show all (even invalid) issues' do
        param_h[:all] = true
      end
      # @todo we would love to have -1, -2 etc
      o.on '-n', '--max-count <num>', "limit output to N nodes" do |n|
        param_h[:max_count] = n
      end
      o.on '-v', '--[no-]verbose',
        "`verbose` means yml-like output (default: verbose)" do |v|
        param_h[:verbose] = v
      end
      o.on '-V', '(same as `--no-verbose`)' do
        param_h[:verbose] = false
      end
    end

    argument_syntax '[<identifier>]'

    def list identifier=nil, param_h
      action = api.build_action( [:nodes, :reduce] ).wire!(&wire)
      client = runtime # this is a part we don't like
      # @todo: for:#102.901.3.2.2 : wiring should happen between
      # the api action objects and the "client" (interface) instance that
      # invoked the api action.
      # all.rb does this confusing thing by having non-configurable core clients


      action.on_invalid_node do |e|
        client.emit :info, '---'
        client.emit :error, "error on line #{ e.line_number }-->#{ e.line }<--"

        e.message = "failed to parse line #{ e.line_number } because #{
          }#{ e.invalid_reason_string } (in #{ escape_path e.pathname })"

      end

      action.invoke( {
        identifier: identifier,
        verbose: true
      }.merge! param_h )
    end

    # --*--

    namespace :node, -> { CLI::Actions::Node }

    # --*--

    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    # @todo: bug with "tmx issue number -h"
    def numbers
      api_invoke [:nodes, :numbers, :list]
    end

    # --*--

    desc "when no arguments provided, list open issues"
    desc "when one argument provided, is used as first line of new issue"
    desc "that will be tagged #open"

    option_syntax do |param_h|
      o = self
      o.on '-n', '--max-count <num>',
        "limit output to N nodes (list only)" do |n|
        param_h[:max_count] = n
      end
      o.on '--dry-run', "don't actually add the node (add only)" do
        param_h[:dry_run] = true
      end
      o.on '-v', '--verbose', 'verbose output' do
        param_h[:verbose] = true
      end
    end

    argument_syntax '[<message>]'

    def open message=nil, param_h
      res = nil
      msg = -> is_opening do                   # i hope you enjoyed this
        a_b = ['opening issues', 'listing open issues']
        a_b.reverse! if is_opening
        "sorry - #{ and_( a = param_h.keys ) } #{ s a, :is } #{
        }used for #{ a_b.first }, not #{ a_b.last }"
      end
      if message
        dry_run = param_h.delete :dry_run
        verbose = param_h.delete :verbose
        if param_h.empty?
          res = api_invoke( [:nodes, :add], {
            do_prepend_open_tag: true,
            dry_run: dry_run,
            message: message,
            verbose: verbose } )
        else
          res = error msg[ true ]
        end
      else
        max_count = param_h.delete :max_count
        verbose = param_h.delete( :verbose ) || false # we decide here the dflt
        if param_h.empty?
          res = api_invoke( [:nodes, :reduce], {
            max_count: max_count,
            query_sexp: [:and, [:has_tag, :open]],
            verbose: verbose } )
        else
          res = error msg[ false ]
        end
      end
      if false == res
        res = invite [:open]
      end
      res
    end

    # --*--

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
      action = api.build_action( [:to_do, :report] ).wire!(&wire)
      action.on_number_found do |e|
        info "(found #{ e.count } item#{ s e.count })"
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

  protected                       # (below was left in the bottom half b/c
                                  # it is the evil that shall not be touched
                                  # until [#010])

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

  module CLI_PenMethods           # here just for compartmentalization
                                  # and clarity

    include Headless::CLI::Pen::InstanceMethods

  protected

    def ick x                     # for rendering invalid values
      x.to_s.inspect
    end
  end

  class CLI
    include CLI_PenMethods
  end
end
