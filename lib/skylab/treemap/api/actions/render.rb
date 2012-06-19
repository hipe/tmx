require_relative '../../models'
require 'fileutils'

module Skylab::Treemap
  class API::Actions::Render < API::Action
    emits :treemap, payload: :all, info: :all, error: :all, info_line: :all
    event_class API::Event

    attribute :char, required: true, regex: [/^.$/, 'must be a single character (had {{value}})']
    attribute :force
    attribute :outpath_requires_force, default: true
    attribute :path, path: true, required: true
    attribute :tempdir_path, default: ->(){ File.join(FileUtils.pwd, '_tmp-r-data') }
    attribute :show_csv
    attribute :show_r_script
    attribute :show_tree
    attribute :stop_after
    attribute :title, default: 'Treemap Tiem'

    CSV_OUT_NAME = 'tmp.csv'

    def csv_tmp_path
      @csv_tmp_path ||= API::Path.new(tempdir.join(CSV_OUT_NAME).to_s)
    end

    def info_line line
      emit(:info_line, line)
    end

    def invoke params
      clear!.update_parameters!(params).validate or return
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
      stop_after?(:show_csv) and return
      render_treemap or return
      stop_after?(:show_tree) and return
      info "finished."
      emit(:treemap, path: outpath)
      true
    end

    def outpath
      @outpath ||= API::Render::Treemap.pdf_path_guess.tap do |o|
        o.forceless = ->() do
          o.exist? and outpath_requires_force and ! force
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
      API::Render::Treemap.invoke(r, csv_tmp_path, tempdir) do |o|
        o.on_success { |e| info("generated treemap: #{e.message}", path: e.pathname) }
        o.on_failure { |e| error("failed to generate treempap: #{e.message}", path: e.pathname) }
        o.on_r_script { |e| emit(:payload, e) } if show_r_script
        o.stop_after_script = show_r_script # right now it is always mutually exclusive
        o.title = title
      end
    end

    def stop_after? name
      if name  == @stop_after
        info "(stopping because #{param :stop} requested after #{name})"
        return true
      end
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

    class PutsToEventProxy
      def initialize &b
        @block = b
      end
      def puts str
        @block.call(str)
      end
    end

    def with_csv_out_stream &b
      if show_csv
        yield( PutsToEventProxy.new { |line| emit(:payload, line) } )
        # @todo: 102.300.4.2 dynamic modality-aware rendering of options (also near 'force')
        info "stopping after show_csv -- nothing more to do."
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

