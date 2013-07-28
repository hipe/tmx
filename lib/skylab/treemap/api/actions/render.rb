module Skylab::Treemap

  class API::Actions::Render < API::Action

    emits :payload_line # e.g if alternate payload, like csv or script contents.

    emits :info, :info_line, :error  # standard fare

    emits :pdf  # (how this is managed may changed. not all nerks will derk)

    event_factory API::Event::FACTORY

    order_a = [ :tree_eventpoint, :csv_eventpoint, :script_eventpoint,
                :write_outfile_eventpoint, :exec_open_eventpoint ] # not all of
                # these are explicitly ticked, are didactic & future-proofed too

    meta_attribute :is_adapter_parameter
    meta_attribute :stop_at
    meta_attribute :stop_is_induced

    attribute_metadata_class do
      [ :stop_is_induced,         # make soft boolean readers for these m.attrs
        :is_adapter_parameter ].each do |m|
        define_method m do        # this is here to fail. makes it more readable
          fetch m do end          # in application code.  also this dsl is
        end                       # pretty wild
      end

      def has_stop_at             # this is here to fail
        has? :stop_at
      end

      def stop_at
        fetch :stop_at            # this is here to fail
      end
    end

    attribute :adapter_name, default: 'r'
    attribute :char, required: true,
      regex: [ /^.$/, 'must be a single character (had {{value}})' ]
    attribute :csv_is_payload, stop_at: :csv_eventpoint, stop_is_induced: 1
    attribute :do_show_tree, stop_at: :tree_eventpoint
    attribute :force
    attribute :inpath, path: true, required: true
    attribute :outpath_requires_force, default: true
    attribute :tmpdir_path, default: -> { ::Pathname.pwd.join 'data/intermediate' }
    attribute :stop_at, enum: order_a
    attribute :title, default: 'Treemap Tiem'

    public :adapter_box           # expose this from above for reflection
                                  # for generating documentation

    def attr_name_to_eventpoint
      @attr_name_to_eventpoint ||=
        formal_attributes.with( :stop_at ).box_map(& :stop_at )
    end

    singleton_class.send :public, :attribute # experimental for the adapter
                                  # to nerk it

    define_method :event_order do order_a end # used in documentors

    def eventpoint_to_attr_name
      @event_point_to_attr_name ||= attr_name_to_eventpoint.invert
    end

    public :formal_attributes     # documentors use this to determine defaults

  private

    def initialize modal_rc
      super
      _adapter_init
      @outpath = nil
    end

    def execute                    # (given top billing, breaks alpha. order)
      res = nil
      begin
        res = resolve_stops or break
        res = resolve_inpath or break
        res = resolve_outpath or break
        res = inpath_to_tree or break
        res = show_tree or break
        res = tree_to_csv or break
        res = tick_eventpoint( :csv_eventpoint ) or break
        res = csv_to_treemap or break
        res = tick_eventpoint( :tree_eventpoint ) or break
        info "finished."
        emit :pdf, path: @outpath
        res = true
      end while nil
      res
    end

    def csv_needs_to_be_written
      if csv_is_payload then
        true                      # always write the csv when it is to stdout
      elsif ! csv_tmp_pathname.exist?
        true                      # yes please write it in cases such as this
      else
        curr_bytes = csv_tmp_pathname.read
        next_bytes = Treemap::Services::File::CSV::Render[ @tree ]
        yes = ! next_bytes || next_bytes != curr_bytes
        yes or info '(no change in csv. skipping)'
        yes
      end
    end

    def csv_to_treemap
      res = false
      begin
        param_h = {
                   csv_inpath: csv_tmp_pathname,
                         info: method( :info ),
                   stop_at: @stop_at,
                        title: title,
                       tmpdir: tmpdir,
                           #--*--
                      payline: method( :payload_line ),
                      success: -> msg, metadata do
                                 info "generated treemap: #{ msg }",
                                 metadata
                               end,
                      failure: -> msg, metadata do
                                 error "failed to generate treemap: #{ msg }",
                                 metadata
                               end
        }
        formal_attributes.which(& :is_adapter_parameter ).each do |k, fattr|
          param_h[ k ] = send k   # fun smell
        end
        res = with_adapter_api_action -> action do
          action.invoke param_h
        end
      end while nil
      res
    end

    csv_out_name = 'tmp.csv'

    define_method :csv_tmp_pathname do ||
      @csv_tmp_pathname ||= tmpdir.join( csv_out_name )
    end

    def expecting attr
      if formal_attributes.has? attr
        true
      else
        error "sorry, the adapter #{ em adapter_box.hot_name } #{
          }failed to load #{ kbd attr }, which is an attribute this #{
          }logic requires."
        false
      end
    end

    def inpath_to_tree
      begin
        res = Treemap::Services::File::Indented::Parse[ formal_attributes,
          char, inpath, stylus, -> e { error e } ]
        res or break
        @tree = res
        res = true
      end while nil
      res
    end

    def render_debug
      o = Porcelain::Tree.lines( @tree ).each do |line|
        info_line line
      end
      if o.node_count.zero?
        info_line "(nothing)"
        false
      else
        true
      end
    end

    def resolve_inpath
      if inpath.exist?
        true
      else
        error "couldn't find input file", path: inpath
        false
      end
    end

    def resolve_outpath
      begin
        if stop_is_requested_before :write_outfile_eventpoint
          @outpath = nil
          break( res = true )
        end
        res = adapter_api_action or break
        pathn = res.default_outpath
        outpn = Treemap::Models::Pathname.new pathn, -> pn do
          b = pn.exist?                        # (`is_missing_required_force`)
          b &&= outpath_requires_force
          b &&= ! force
          b
        end
        if outpn.is_missing_required_force
          error "outpath exists, won't overwrite without #{
            }#{ param :force }", path: outpn
          res = false
          break
        end
        @outpath = outpn
        res = true
        break
      end while nil
      res
    end
                                  # this is the part that checks: if parameters
                                  # are present that inducde stops, are they
                                  # at odds with any other stops?
    def resolve_stops
      # in the event order, and only for those attrs that have associated stops
      # see if a corresponding parameter was requested and etc.
      e2a = eventpoint_to_attr_name
      do_induce = nil
      stops_requested = event_order.reduce [] do |memo, eventpoint|
        if e2a.has? eventpoint    # (not all epoints have a fattr)
          aname = e2a[eventpoint]
          fattr = formal_attributes[aname]
          if @stop_at == eventpoint # then the user requested it
            memo << fattr
          elsif fattr.stop_is_induced and send aname # then, if the param is
            do_induce = true      # trueish you get the stop !
            memo << fattr
          end
        end
        memo
      end
      res = true
      case len = stops_requested.length
      when 0
        @stop_at = nil
      when 1
        @stop_at ||= stops_requested.first.stop_at if do_induce
      else
        error "there are #{ len } stops requested, choose one: #{
          stops_requested.map do |fattr|
            stem = param fattr
            if fattr.stop_is_induced
              "#{ stem } (implied stop)"
            else
              "#{ stem } #{ param :stop }"
            end
          end.join ', '
        }"
        res = false
      end
      res
    end

    def show_tree
      if do_show_tree
        res = render_debug
        if res
          res = tick_eventpoint :tree_eventpoint
        end
      else
        res = true
      end
      res
    end

    def stop_compare name
      @stop_at or fail "check @stop_at before calling this."
      name_index = event_order.index name
      name_index or raise ::NameError, "bad name: #{ name }"
      res = event_order.index( @stop_at ) <=> name_index
      res
    end

    def stop_is_requested_before name
      if @stop_at
        res = -1 == stop_compare( name )
      end
      res
    end

    public :stop_is_requested_before  # smell? cli wants this

    # "now that we are after X, have we passed a stop?"
    def tick_eventpoint eventpoint_ref
      if @stop_at
        cmp = stop_compare eventpoint_ref
        case cmp
        when 0, -1
          # what is the attr that stops after this eventpoint? we want its label
          fattr = formal_attributes.defectch -> x do
            x.has_stop_at and eventpoint_ref == x.stop_at
          end
          parts = [ param( :stop ) ]
          parts << "(induced)" if fattr.stop_is_induced
          parts << "after #{ param fattr }"
          info "(stopping because #{ parts.join ' ' })" # (was [#052] borked)
          res = nil                 # stop execution with nothing to report
        when 1
          res = true              # the stop comes later
        else exit 1 end           # sanity - find me
      else
        res = true                # there is no stop, keep going
      end
      res
    end

    def tree_to_csv
      srand 867 # #todo this is just so we can trigger dupe-checking on fs
      if csv_needs_to_be_written
        with_csv_out_stream do |csv_out|
          csv = Treemap::Services::File::CSV::Render.new @tree
          csv.each do |line|
            csv_out.puts "#{ line }"
          end
        end
      else
        true  # assume csv existed on disk and is valid
      end
    end

    def tmpdir
      @tmpdir ||= begin
        path = tmpdir_path
        path = path.call if path.respond_to? :call
        Treemap::Models::Pathname::Tmpdir.new path do |o|
          o.on_created do |e|
            info "created directory", path: e.path
          end
          o.on_exists do |e|
            info "using #{ escape_path e.path }"
          end
          o.on_failure do |e|
            error "failed to make tmpdir - #{ e }"
          end
        end
      end
    end

    def with_adapter_instance &block  # this will go straight up to somewhere
      res = adapter_box.fetch_hot_instance do |e|
        error "no adapter currently selected - #{ e }"
        false
      end
      if res
        res = block[ res ]
      end
      res
    end

    def with_csv_out_stream &block # result is result of block or conventional
      begin
        if csv_is_payload
          pxy = Treemap::Models::Proxies::Puts.new method( :payload_line )
          res = block[ pxy ]
        else
          res = tmpdir.normalize or break
          did_overwrite = csv_tmp_pathname.exist?
          csv_tmp_pathname.open WRITEMODE_ do |fh|
            res = block[ fh ]
          end
          if ! res
            error "had an issue in writing csv file", path: csv_tmp_pathname
            break
          end
          info "#{ did_overwrite ? 'overwrote' : 'wrote' } #{
            }(#{ res.num_lines } lines)", path: csv_tmp_pathname
          res = true
        end
      end while nil
      res
    end

    define_methods_for_emitters :payload_line
  end
end
