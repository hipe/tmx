module Skylab::Treemap
  class CLI::Actions::Render < CLI::Action
    desc "render a treemap from a text-based tree structure"

    option_syntax_class CLI::DynamicOptionSyntax

    option_syntax do |o|
      o[:char] = '+'
      o[:exec] = true

      on('-a <NAME>', '--adapter <NAME>', * more(:a)){ |v| o[:adapter_name] = v }
      on('-c', '--char <CHAR>', "use CHAR (default: {{default}})") { |v| o[:char] = v }
      on('--tree', 'show the text-based structure in a tree (debugging)') { o[:do_show_tree] = true }
      on('--csv', 'output the csv to stdout instead of tempfile, stop.') { o[:csv_stream] = :payload }
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
      stop, impl = [ :stops_after, :stop_implied ].map { |x| fa.box_reduce x }
      ks = stop.names - impl.names
      o << "(can appear after #{ and_ ks.map { |k| param k } }) #{
          }(implied after #{ and_ impl.names.map { |k| param k } })"
      nil
    end

    def invoke inpath, opt_h
      res = nil ; act = api_action
      begin
        break if ! parse_opts opt_h
        do_exec = opt_h.delete :exec
        act.on_treemap do |e|
          if do_exec && e.path.exist? && ! act.stop_before?( :exec_open_file )
            act.info "calling exec() to open the pdf!"
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

    def build_option_syntax       # k.i.w.f
      load_adapter = -> name { self.load_adapter name }
      op = self.class.option_syntax.dupe
      op.parser_class = CLI::DynamicOptionParser
      op.documentor_class = CLI::DynamicOptionDocumentor
      clia = self
      op[:documentor_visit] = -> doc do # [#014.1]
        doc.cli_action = clia
        orig_documentor_visit doc
      end
      # get ready for literally the most retarded thing i've ever done in
      # my whole entire life - before we parse opts like normal..
      # we convinced ourselves that the only way to bootrap the adapter was
      op[:parse] = -> argv, args, help, syn_err do   # EPIC HACKERY..
        name = options[:adapter_name].parse! argv    # mutate argv
        name or (hlp = options[:help].parse argv)    # do not mutate argv
                                  # LOAD THE ADAPTER HERE - FRAGILE CITY
        rs = true                 # if a name was provided, load that, else
        if name || ! ( 1 == argv.length && hlp )     # ( load the default unless
          rs = load_adapter[ name ] # help appeared as the only option )
        end
        rs &&= orig_parse argv, args, help, syn_err
        rs
      end
      op
    end

    def api_action                # this may very well prove to be a non-
      @api_action ||= begin       # standard coupling of api & modality
        action = api_client.action :render
        wire_api_action action
        action
      end
    end

    def load_adapter name
      name ||= api_action.formal_attributes[:adapter_name][:default]
      name or fail 'sanity'
      ad = api_action.activate_adapter_if_necessary name, -> e do
        info e
        help_invite for: ' for more about help with adapters.'
      end
      if ad # if you got it it means there were no errors *and* it changed
        ad.load_attributes_into api_action.formal_attribute_definer
        ad.load_options_into self
        true
      end
    end

    def parse_opts opt_h
      if opt_h[:stop]
        parse_opts_stop opt_h
      else
        true
      end
    end

    def parse_opts_stop opt_h
      opt_to_event = api_action.formal_attributes.with :stops_after
      event_to_opt = opt_to_event.invert
      order = api_action.event_order.map { |e| event_to_opt[e] }.compact
      given = opt_h.keys & [:stop, *order]
      given.pop while :stop != given.last
      if 1 == given.length
        error "#{ param :stop } must come somewhere after at #{
          }least one of #{ or_ order.map{ |x| param x } }"
        help_invite
        res = nil
      else
        x = opt_to_event[given[-2]]
        x or fail 'error parsing stop'
        opt_h[:stop_after] = x
        opt_h.delete :stop
        res = true
      end
      res
    end
  end
end
