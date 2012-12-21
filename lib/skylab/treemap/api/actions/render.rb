require_relative '../../models'
require 'fileutils'

module Skylab::Treemap
  class API::Actions::Render < API::Action

    emits :treemap, payload: :all, info: :all, error: :all, info_line: :all
    event_class API::Event

    include API::Action::AdapterInstanceMethods

    ORDER = [:show_tree, :csv, :r_script, :write_outfile, :exec_open_file]

    meta_attribute :stops_after
    meta_attribute :stop_implied
    attribute :adapter_name, default: 'r'
    attribute :char, required: true, regex: [/^.$/, 'must be a single character (had {{value}})']
    attribute :csv_stream, enum: [:payload], stops_after: :csv, stop_implied: true
    attribute :force
    attribute :outpath_requires_force, default: true
    attribute :path, path: true, required: true
    attribute :tempdir_path, default: ->(){ File.join(FileUtils.pwd, '_tmp-r-data') }
    attribute :show_tree, stops_after: :show_tree
    attribute :stop_after, enum: ORDER
    attribute :title, default: 'Treemap Tiem'

    CSV_OUT_NAME = 'tmp.csv'


    def csv_tmp_path
      @csv_tmp_path ||= API::Path.new(tempdir.join(CSV_OUT_NAME).to_s)
    end

    def info_line line
      emit(:info_line, line)
    end

    def invoke!
      validate or return false
      path.exist? or return error("couldn't find input file", path: path)
      outpath.forceless? and return error("outpath exists, won't overwrite without #{param :force}", path: outpath)
      @tree = API::Parse::Indentation.invoke(attributes, path, char, stylus) { |o|
        o.on_parse_error { |e| error e } } or return
      if show_tree
        render_debug
        stop_after?(:show_tree) and return
      end
      ok = with_csv_out_stream do |csv_out|
        API::Render::CSV.invoke(@tree) do |o|
          o.on_payload { |e| csv_out.puts e.to_s }
          o.on_error   { |e| error e }
          o.on_info    { |e| info e }
        end
      end
      ok or return
      stop_after?(:csv) and return
      render_treemap or return
      stop_after?(:show_tree) and return
      info "finished."
      emit(:treemap, path: outpath)
      true
    end

    def order
      ORDER
    end

    def outpath
      @outpath ||= adapter_class.pdf_path_guess.tap do |o|
        o.forceless = ->() do
          o.exist? and outpath_requires_force and ! stop_before?(:write_outfile) and ! force
        end
      end
    end

    def render_debug
      require 'skylab/porcelain/tree'
      o = Skylab::Porcelain::Tree.lines(@tree).each do |line|
        info_line line
      end
      (0 < o.node_count) ? true : (info_line("(nothing)") && false)
    end

    def render_treemap
      adapter_instance.update_parameters!(csv_tmp_path, tempdir).invoke do |o|
        o.on_success { |e| info("generated treemap: #{e.message}", path: e.pathname) }
        o.on_failure { |e| error("failed to generate treempap: #{e.message}", path: e.pathname) }
        if :payload == r_script_stream
          o.on_r_script { |e| emit(:payload, e) }
          o.stop_after_script = true
        end
        o.title = title
      end
    end

    # this is "now that we are after X, have we passed a stop?" and not "is there a stop after X?"
    def stop_after? name
      if [0, -1].include? stop_compare(name)
        info "(stopping because #{param :stop} (stated or implied) after #{param attributes.with(:stops_after).invert[name]})"
        true
      end
    end

    # this is "is there a stop anywhere before X?"
    def stop_before? name
      -1 == stop_compare(name)
    end

    def stop_compare name
      name_index = ORDER.index(name) or raise ArgumentError.new("bad name: #{name}")
      @stop_after or return nil
      ORDER.index(@stop_after) <=> name_index
    end

    def tempdir
      @tempdir ||= begin
        path = tempdir_path
        path.respond_to?(:call) and path = path.call
        API::Tempdir.new(path.to_s) do |o|
          o.on_create { |e| info("created directory", path: e.tempdir) }
        end
      end
    end


    def validate
      super or return
      attributes.with(:stops_after).each do |attrib, event|
        if send(attrib) and (self.stop_after ||= event) != event
          inv = attributes.with(:stops_after).invert
          return error("can't have the (possibly implied) #{param :stop} after both #{param inv[stop_after]}" <<
            " and #{param attrib}")
        end
      end
      true
    end

    class PutsToEventProxy
      def initialize &b
        @block = b
      end
      def puts str
        @block.call(str)
      end
    end

    def with_csv_out_stream &b
      if :payload == csv_stream
        yield( PutsToEventProxy.new { |line| emit(:payload, line) } )
        stop_after?(:csv) # just to get a message
        return
      else
        tempdir.ready? or return error("failed to make tempdir: #{tempdir.invalid_reason}", path: tempdir)
        existed = csv_tmp_path.exist?
        result = nil ; File.open(csv_tmp_path.to_s, 'w+') { |fh| result = yield(fh) }
        if result
          info("#{existed ? 'overwrote' : 'wrote'} (#{result.num_lines} lines)", path: csv_tmp_path)
        else
          error("had an issue in writing csv file", path: csv_tmp_path)
        end
        result
      end
    end
  end
end

