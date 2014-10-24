module Skylab::Treemap

  class CLI::Actions::Render < CLI::Action

    extend CLI::Option__::Ridiculous  # headless cli action m.m and i.m too !
                                  # fully wired for hacking from old and new

    include Treemap::Adapter::InstanceMethods::CLI_Action
                                  # see notes there, this adapts old help reqs

    emits :error                  # usu. gets styled

    emits :help                   # a line for a help screen (from h.l)

    emits :info                   # usu. gets stylsed

    emits :info_line              # usu. unstyled, raw line

    desc "render a treemap from a text-based tree structure"

    option_parser do |o|

      @param_h[:char] = '+'
      @param_h[:do_exec] = true
      @param_queue ||= []

      o.on '-a <NAME>', '--adapter <NAME>', * more(:a) do |v|
        @param_h[:adapter_name] = v
      end
      o.on '-c', '--char <CHAR>', "use CHAR (default: {{default}})" do |v|
        @param_h[:char] = v
      end
      o.on '--tree', 'show the text-based structure in a tree (debugging)' do
        @param_queue << :do_show_tree
      end
      o.on '--csv', 'output the csv to stdout instead of tempfile, stop.' do
        @param_queue << :csv_is_payload
      end
      o.on '--stop', 'stop execution after the previously indicated step',
        * more(:s) do
        @param_queue << :stop
      end
      o.on '-F', '--force', 'force overwriting of an exiting file' do
        @param_h[:force] = true
      end
      o.on '--[no-]exec',
        "the default is to open the file with exec ({{default}})" do |v|
        @param_h[:do_exec] = v
      end
      o.on '-v', '--verbose', 'verbose output (implemented sparely)' do
        @param_h[:be_verbose] = true
      end
    end

    option_parser.more :a do |y|
      y << 'which treemap rendering adapter to use.'
      a = sister.adapter_box.names
      o = sister.formal_attributes.fetch :adapter_name
      y << "(#{ s a, :no }known adapter#{ s a } #{ s a, :is } #{
        }#{ and_ a.map{ |x| pre x } }) (default: #{ pre o[:default] })"
      y << "(to see adapter-specific opts use this in conjunction #{
        }with #{ param :help, :rndr })"
      nil
    end

    option_parser.more :s do |y|
      fa = sister.formal_attributes
      stop, impl = [ :stop_at, :stop_is_induced ].map { |x| fa.meta_attribute_value_box x }
      ks = stop.names - impl.names
      y << "(can appear after #{ and_ ks.map { |k| param k } }) #{
          }(implied after #{ and_ impl.names.map { |k| param k } })"
      nil
    end

  private

    def initialize( * )
      super
      _adapter_init
    end

    #                    ~ (nerks in order of nerking) ~

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

    # (as soon as the o.p is requested, it runs blocks which require the
    # api action ("sister"), which is wired once here.)

    def build_wired_api_action
      rc = request_client
      a = build_unwired_api_action
      a.on_payload_line rc.handle :payload_line
      a.on_info         rc.handle :info
      a.on_info_line    rc.handle :info_line
      a.on_error        rc.handle :error
      a.on_pdf do |e|
        if @do_exec
          if a.stop_is_requested_before :exec_open_eventpoint
            info "(stop was requested before executing opening of pdf.)"
          else
            if e.path.exist?
              info "calling exec() to open the pdf (!) - #{ escape_path e.path }"
              cmd = "open #{ e.path }"
              exec cmd
            else
              error "expected pdf output not found: #{ escape_path e.path }"
            end
          end
        end
      end
      a.if_unhandled_streams method( :fail )
      a
    end

    # `absorb_param_queue` - as an experiment we are seeing what it takes
    # to parse an order-sensitive syntax like this. We have an ordered
    # @param_queue and a (should be thought of as unordered) @param_h.
    # All we want is to distill the former down into the latter, by setting
    # a `true` value for each nerk, and setting one `stop_at` param if
    # appropriate.

    def absorb_param_queue
      begin
        break( res = true ) if @param_queue.length.zero?
        e2a = sister.eventpoint_to_attr_name
        a_order = sister.event_order.reduce [] do |memo, ename|
          memo << e2a[ ename ] if e2a.has? ename
          memo
        end
        idx = @param_queue.index :stop  # nil ok
        if idx
          if 0 == idx
            error "#{ param :stop } must come somewhere after at #{
              }least one of #{ or_ a_order.map{ |x| param x } }"
            break
          end
          # (stop does not necessarily need to be at the end.)
          @param_queue[ idx ] = nil
          @param_h[:stop_at] =    # mutating p.q is what is easiest,
            sister.attr_name_to_eventpoint.fetch @param_queue[ idx - 1 ]
          @param_queue.compact!   # also it is what we are here to do
        end
        @param_queue.compact.uniq.each { |k| @param_h[k] = true }
        @param_queue = nil
        res = true
      end while nil
      res
    end

    def process inpath            # **NOTE** signature is cosmetic here! names!
      param_h = @param_h
      @param_h = nil  # let's be clear..
      @param_h_spent = param_h.dup.freeze
      param_h[ :inpath ] = inpath
      @do_exec = param_h.delete :do_exec  # (we handle this now)
      sister.invoke param_h  # (no invite here, was [#035])
    end
  end
end
