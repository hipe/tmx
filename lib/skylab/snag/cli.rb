module Skylab::Snag
  class CLI
    extend MetaHell::Autoloader::Autovivifying::Recursive # used below

    include CLI::Action::InstanceMethods

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

    def emit name, pay
      porcelain.runtime.emit name, pay
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

    namespace :node, -> { CLI::Actions::Node }

    namespace :nodes, -> { CLI::Actions::Nodes }

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

    namespace :todo, -> { CLI::Actions::Todo }

    # --*--

  protected                       # (below was left in the bottom half b/c
                                  # it is the evil that shall not be touched
                                  # until [#010])

    # this nonsense wires your evil foreign (frame) runtime to the big deal parent
    def wire! runtime, parent
      runtime.event_class = Snag::API::MyEvent
      runtime.on_error { |e| parent.emit(:error, e.touch!) }
      runtime.on_info  { |e| parent.emit(:info, e.touch!) }
      runtime.on_all   { |e| parent.emit(e.type, e) unless e.touched? }
    end
                                  # (also this kind of thing can be nice in
    def wire_action action        # constructors for cli actions)
      if action.emits? :payload
        action.on_payload do |e|
          runtime.emit :payload, e
        end
      end
      wire_action_for_info  action if action.emits? :info
      wire_action_for_error action if action.emits? :error
      nil
    end

    render = -> me, e do
      msg = nil
      if e.payload.respond_to? :render_for
        msg = e.payload.render_for me
      else
        msg = e.message
      end
      msg
    end

    define_method :wire_action_for_error do |action|
      action.on_error do |e|
        rendered = render[ self, e ]
        e.message = "failed to #{ e.verb } #{ e.noun } - #{ rendered }"
        runtime.emit :error, e
        nil
      end
      nil
    end

    define_method :wire_action_for_info do |action|
      action.on_info do |e|
        unless e.touched?
          rendered = render[ self, e ]
          md = %r{\A\((.+)\)\z}.match( rendered ) and rendered = md[1]
          e.message = "while #{ e.verb.progressive } #{ e.noun }, #{ rendered }"
          md and e.message = "(#{ e.message })" # so ridiculous
          runtime.emit :info, e
        end
        nil
      end
      nil
    end
  end

  module CLI_PenMethods           # here just for compartmentalization
                                  # and clarity

    include Headless::CLI::Pen::InstanceMethods

  protected

    def ick x                     # for rendering invalid values
      x.to_s.inspect
    end

    def val x                     # how do you decorate a special value?
      em x
    end
  end

  class CLI
    include CLI_PenMethods
  end
end
