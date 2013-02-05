module Skylab::Treemap

  class CLI::Actions::Render < CLI::Action

    extend CLI::Option::Ridiculous  # headless cli action m.m and i.m too !
                                  # fully wired for hacking from old and new

    include Treemap::Adapter::InstanceMethods::CLI_Action

    desc "render a treemap from a text-based tree structure"

    option_parser do |o|
      # $stderr.puts "NERK : #{ self.class } : #{ o.class } : #{ @param_h.class }"

      @param_h[:char] = '+'
      @param_h[:exec] = true

      o.on '-a <NAME>', '--adapter <NAME>', * more(:a) do |v|
        @param_h[:adapter_name] = v
      end
      o.on '-c', '--char <CHAR>', "use CHAR (default: {{default}})" do |v|
        @param_h[:char] = v
      end
      o.on '--tree', 'show the text-based structure in a tree (debugging)' do
        @param_h[:do_show_tree] = true
      end
      o.on '--csv', 'output the csv to stdout instead of tempfile, stop.' do
        @param_h[:csv_is_payload] = true
      end
      o.on '--stop', 'stop execution after the previously indicated step',
        * more(:s) do
        @param_h[:stop] = true
      end
      o.on '-F', '--force', 'force overwriting of an exiting file' do
        @param_h[:force] = true
      end
      o.on '--[no-]exec',
        "the default is to open the file with exec ({{default}})" do |v|
        @param_h[:exec] = v
      end
    end

    option_parser.more :a do |y|
      y << 'which treemap rendering adapter to use.'
      a = api_action.adapter_box.names
      o = api_action.formal_attributes.fetch :adapter_name
      y << "(#{ s a, :no }known adapter#{ s a } #{ s a, :is } #{
        }#{ and_ a.map{ |x| pre x } }) (default: #{ pre o[:default] })"
      y << "(to see adapter-specific opts use this in conjunction #{
        }with #{ param :help, :rndr })"
      nil
    end

    option_parser.more :s, do |y|
      fa = api_action.formal_attributes
      stop, impl = [ :stop_at, :stop_is_induced ].map { |x| fa.meta_attribute_value_box x }
      ks = stop.names - impl.names
      y << "(can appear after #{ and_ ks.map { |k| param k } }) #{
          }(implied after #{ and_ impl.names.map { |k| param k } })"
      nil
    end


    def process inpath, opts=nil  # **NOTE** opts is cosmetic here! (even the
      $stderr.puts "OK TO HERE" ; exit 0

      res = nil                   # spelling)
      act = api_action
      begin
        res = post_process_param_h
        res or break
        act.on_treemap do |e|
          if do_exec && e.path.exist? && !
            act.stop_is_requested_before( :exec_open_eventpoint ) then
            act.info "calling exec() to open the pdf!" # #todo bad
            exec "open #{ e.path }"
          end
        end
        res = act.invoke opts.merge!( inpath: inpath )
        if false == res # [#035] - checking for help invite at action level ..
          usage_and_invite
          res = nil
        end
      end while nil
      res
    end

  protected

    def initialize(*)
      super
      _adapter_init
    end

    # def build_option_syntax       # k.i.w.f  # #todo
      # enhance_with_adapter = -> x { self.enhance_with_adapter x }
      # op = self.class.option_syntax.dupe
      # op.parser_class = CLI::Option::Parser
      # op.documentor_class = CLI::Option::Documenter
      # clia = self
      # op[:documentor_visit] = -> doc do # [#014.1]
       #  doc.cli_action = clia
       #  orig_documentor_visit doc
      # end
      # op[:parse] = -> argv, args, help, syn_err do
#        ref = options[:adapter_name].parse! argv     # mutate argv
#        ref or (hlp = options[:help].parse argv)     # do not mutate argv
      # end
      # op
    # end

    def parse_opts argv
      # ok get ready..bc this took me like a month to write and then another
      # month to untangle: *before* we parse the opts like normal, we actually
      # want to see if there are arguments present in `argv` that will affect
      # the options in the option parser itself! So, using some options
      # that we *do know* are there in the parser now, we use some epic
      # hackery to "peek" into argv and pseudo-parse it..

      options = option_parser.options
      aref = options.fetch( :adapter_name ).parse! argv   # (mutate argv)
      aref or ( hlp = options.fetch( :help ).parse argv ) # (do not mutate argv)

      #    ~ ( load *some* adapter now, before we even parse argv ) ~

      res = true                   # if a name was provided, load that, else
      if aref || ! ( 1 == argv.length && hlp )     # ( load the default unless
        res = enhance_with_adapter aref    # help appeared as the only option )
      end                                  # (it's a show-off move ..)
      if res
        res = super
      end
      res
    end

    def post_process_param_h
      $stderr.puts "STOPPING AT STOPS" ; exit 0
#      if opt_h[:stop]
#        parse_opts_stop opt_h
#      else
#        true
      nil
    end
                                  # it's a smell to reach over like this,
                                  # but this crazy syntax has special needs
                                  # all the api wants is a `stop_at` param

    def parse_opts_stop opt_h
      act = api_action
      a2e, e2a = act.attr_name_to_eventpoint, act.eventpoint_to_attr_name
      a_order = act.event_order.reduce [] do |memo, ename|
        memo << e2a[ ename ] if e2a.has? ename
        memo
      end
      given_a = opt_h.keys & [ :stop, *a_order ] # sort first by second!
      given_a.pop while :stop != given_a.last
      if 1 == given_a.length
        error "#{ param :stop } must come somewhere after at #{
          }least one of #{ or_ a_order.map{ |x| param x } }"
        usage_and_invite
        res = nil
      else
        ref = a2e.fetch given_a[-2]
        opt_h[:stop_at] = ref
        opt_h.delete :stop
        res = true
      end
      res
    end
  end
end
