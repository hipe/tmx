module Skylab::Treemap
  class CLI::Actions::Render < CLI::Action
    desc "render a treemap from a text-based tree structure"

    option_syntax_class CLI::Option::Parser::Syntax

    option_syntax do |o|
      o[:char] = '+'
      o[:exec] = true

      on('-a <NAME>', '--adapter <NAME>', * more(:a)){ |v| o[:adapter_name] = v }
      on('-c', '--char <CHAR>', "use CHAR (default: {{default}})") { |v| o[:char] = v }
      on('--tree', 'show the text-based structure in a tree (debugging)') { o[:do_show_tree] = true }
      on('--csv', 'output the csv to stdout instead of tempfile, stop.') { o[:csv_is_payload] = true }
      on('--stop', 'stop execution after the previously indicated step', * more(:s)) { o[:stop] = true }
      on('-F', '--force', 'force overwriting of an exiting file') { o[:force] = true }
      on('--[no-]exec', "the default is to open the file with exec {{default}}") { |v| o[:exec] = v }
    end

    option_syntax.more :a, -> y do
      y << 'which treemap rendering adapter to use.'
      a = api_action.adapter_box.names
      o = api_action.formal_attributes.fetch :adapter_name
      y << "(#{ s a, :no }known adapter#{ s a } #{ s a, :is } #{
        }#{ and_ a.map{ |x| pre x } }) (default: #{ pre o[:default] })"
      y << "(to see adapter-specific opts use this in conjunction #{
        }with #{ param :help, :rndr })"
      nil
    end

    option_syntax.more :s, -> o do
      fa = api_action.formal_attributes
      stop, impl = [ :stop_at, :stop_is_induced ].map { |x| fa.meta_attribute_value_box x }
      ks = stop.names - impl.names
      o << "(can appear after #{ and_ ks.map { |k| param k } }) #{
          }(implied after #{ and_ impl.names.map { |k| param k } })"
      nil
    end

    def invoke inpath, opt_h
      res = nil
      act = api_action
      begin
        break if ! parse_opts opt_h
        do_exec = opt_h.delete :exec
        act.on_treemap do |e|
          if do_exec && e.path.exist? && !
            act.stop_is_requested_before( :exec_open_eventpoint ) then
            act.info "calling exec() to open the pdf!" # #todo bad
            exec "open #{ e.path }"
          end
        end
        res = act.invoke opt_h.merge!( inpath: inpath )
        if false == res # [#035] - checking for help invite at action level ..
          help_invite
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

  include Treemap::Adapter::InstanceMethods::CLI_Action

    def build_option_syntax       # k.i.w.f
      enhance_with_adapter = -> x { self.enhance_with_adapter x }
      op = self.class.option_syntax.dupe
      op.parser_class = CLI::Option::Parser
      op.documentor_class = CLI::Option::Documenter
      clia = self
      op[:documentor_visit] = -> doc do # [#014.1]
        doc.cli_action = clia
        orig_documentor_visit doc
      end
      # get ready for literally the most retarded thing i've ever done in
      # my whole entire life - before we parse opts like normal..
      # we convinced ourselves that the only way to bootrap the adapter was
      op[:parse] = -> argv, args, help, syn_err do   # EPIC HACKERY..
        ref = options[:adapter_name].parse! argv     # mutate argv
        ref or (hlp = options[:help].parse argv)     # do not mutate argv
                                  # LOAD THE ADAPTER HERE - FRAGILE CITY
        rs = true                 # if a name was provided, load that, else
        if ref || ! ( 1 == argv.length && hlp )     # ( load the default unless
          rs = enhance_with_adapter[ ref ] # help appeared as the only option )
        end
        rs &&= orig_parse argv, args, help, syn_err
        rs
      end
      op
    end

    def parse_opts opt_h
      if opt_h[:stop]
        parse_opts_stop opt_h
      else
        true
      end
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
        help_invite
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
