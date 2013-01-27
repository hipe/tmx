module Skylab::Treemap
  class API::Actions::Render < API::Action

    emits :treemap, payload: :all, info: :all, error: :all, info_line: :all

    event_class API::Event

    order_a = [:do_show_tree, :csv, :r_script, :write_outfile, :exec_open_file]
    order_a.freeze

    meta_attribute :stops_after
    meta_attribute :stop_implied

    attribute :adapter_name, default: 'r'
    attribute :char, required: true,
      regex: [ /^.$/, 'must be a single character (had {{value}})' ]
    attribute :csv_stream, enum: [:payload], stops_after: :csv,
                           stop_implied: true
    attribute :do_show_tree, stops_after: :do_show_tree
    attribute :force
    attribute :inpath, path: true, required: true
    attribute :outpath_requires_force, default: true
    attribute :tmpdir_path, default: -> { ::Pathname.pwd.join 'data/intermediate' }
    attribute :stop_after, enum: order_a
    attribute :title, default: 'Treemap Tiem'

    public :adapter_box           # expose this from above for reflection
                                  # for generating documentation

    singleton_class.send :public, :attribute # experimental for the adapter
                                  # to nerk it

    define_method :event_order do order_a end # used in documentors

    public :formal_attributes     # documentors use this to determine defaults

  protected

    def initialize api_client
      super
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
        res = event_point_reached( :csv ) or break
        res = csv_to_treemap or break
        res = event_point_reached( :do_show_tree ) or break
        info "finished."
        emit :treemap, path: @outpath
        res = true
      end while nil
      res
    end

    def  csv_no_change                         # do not re-write the csv
      if :payload != @csv_stream &&            # if we are not emitting it
        csv_tmp_pathname.exist? then
        curr_bytes = csv_tmp_pathname.read
        next_bytes = Treemap::Services::File::CSV::Render[ @tree ]
        if next_bytes && curr_bytes == next_bytes
          info '(no change in csv. skipping)'
          true
        end
      end
    end

    def csv_to_treemap
      res = false
      begin
        expecting :r_script_stream or break
        if :payload == r_script_stream
          on_r_script = -> e { emit :payload, e }
          stop_after_script = true
        end
        res = adapter_box.hot_instance.render_treemap(
                   csv_inpath: csv_tmp_pathname,
                         info: method( :info ),
                        title: title,
                       tmpdir: tmpdir,
                      rscript: on_r_script,
            stop_after_script: stop_after_script,
                      success: -> msg, metadata do
                                 info "generated treemap: #{ msg }",
                                 metadata
                               end,
                      failure: -> msg, metadata do
                                 error "failed to generate treemap: #{ msg }",
                                 metadata
                               end
         )
      end while nil
      res
    end

    csv_out_name = 'tmp.csv'

    define_method :csv_tmp_pathname do ||
      @csv_tmp_pathname ||= tmpdir.join( csv_out_name )
    end

    # this is "now that we are after X, have we passed a stop?"
    # and not "is there a stop after X?"
    def event_point_reached name
      res = true # true = keep going
      case stop_compare name
      when 0, -1
        info "(stopping because #{ param :stop } (stated or implied) #{
          }after #{ param formal_attributes.with( :stops_after ).invert[name]})" # [#052] borked
        res = nil # stop execution with nothing to report
      end
      res
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

    def info_line line
      emit :info_line, line
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
      res = false
      begin
        res = expecting( :default_outpath ) or break
        pathn = default_outpath
        outpn = Treemap::Models::Pathname.new pathn, -> pn do
          b = pn.exist?                        # (`is_missing_required_force`)
          b &&= outpath_requires_force
          b &&= ! stop_before?( :write_outfile )
          b &&= ! force
          b
        end
        if outpn.is_missing_required_force
          error "outpath exists, won't overwrite without #{
            }#{ param :force }", path: outpn
          break
        end
        @outpath = outpn
        res = true
        break
      end while nil
      res
    end


    def resolve_stops
      res = true
      formal_attributes.with( :stops_after ).each do |attrib, event|
        if send( attrib ) && ( self.stop_after ||= event ) != event
          inv = formal_attributes.with( :stops_after ).invert # [#052] borked
          res = error "can't have the (possibly implied) #{
            } #{ param :stop } after both #{ param inv[stop_after] }#{
            } and #{ param attrib }"
          break( res = false )
        end
      end
      res
    end

    def show_tree
      if do_show_tree
        res = render_debug
        res and event_point_reached :do_show_tree
      else
        true
      end
    end

    # this is "is there a stop anywhere before X?"
    def stop_before? name
      -1 == stop_compare( name )
    end

    def stop_compare name
      res = nil
      begin
        name_index = event_order.index name
        name_index or raise ::NameError.new "bad name: #{ name }"
        @stop_after or break
        res = event_order.index( @stop_after ) <=> name_index
      end while nil
      res
    end

    def tree_to_csv
      srand 867 # jenny's phone number - 867 5309 # %todo
      csv_no_change or begin
        with_csv_out_stream do |csv_out|
          Treemap::Services::File::CSV::Render.invoke @tree do |o|
            o.on_payload { |e| csv_out.puts e.to_s }
            o.on_error   { |e| error e }
            o.on_info    { |e| info e }
          end
        end
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

    def with_csv_out_stream &block # result is result of block or conventional
      res = nil
      begin
        if :payload == csv_stream
          pxy = Treemap::Models::Proxies::Puts.new -> line do
            emit :payload, line
          end
          yield pxy
          event_point_reached :csv # just to get a message
        else
          tmpdir.normalize or break
          existed = csv_tmp_pathname.exist?
          csv_tmp_pathname.open 'w+' do |fh|
            res = block[ fh ]
          end
          if res
            info "#{ existed ? 'overwrote' : 'wrote' } #{
              }(#{ res.num_lines } lines)", path: csv_tmp_pathname
          else
            error "had an issue in writing csv file", path: csv_tmp_pathname
          end
        end
      end while nil
      res
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
  end
end
