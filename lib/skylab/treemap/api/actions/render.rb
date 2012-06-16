require_relative '../../models'
require 'fileutils'

module Skylab::Treemap
  class API::Actions::Render < API::Action
    emits payload: :all, info: :all, error: :all

    attribute :char, required: true, regex: [/^.$/, 'must be a single character (had {{value}})']
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

    def invoke params
      clear!.update_parameters!(params).validate or return
      path.exist? or return error("input file not found: #{path.pretty}")
      @tree = API::Parse::Indentation.invoke(attributes, path, char) { |o|
        o.on_parse_error { |e| emit(:error, e) } } or return
      if show_tree
        render_debug
        stop_after?(:show_tree) and return
      end
      ok = with_csv_out_stream do |csv_out|
        API::Render::CSV.invoke(@tree) do |o|
          o.on_payload { |e| csv_out.puts e.to_s }
          o.on_error   { |e| emit(:error, e) }
          o.on_info    { |e| emit(:info, e) }
        end
      end
      ok or return
      stop_after?(:show_csv) and return
      render_treemap or return
      stop_after?(:show_tree) and return
      open_treemap or return
      info "done."
    end

    def open_treemap
      info "pretending to open treemap"
      true
    end

    def render_debug
      require 'skylab/porcelain/tree'
      empty = true
      Skylab::Porcelain::Tree.lines(@tree).each do |line|
        emit :info, line # egads!
        empty = false
      end
      empty ? (info("(nothing)") and false) : true
    end

    def render_treemap
      API::Render::Treemap.invoke(r, csv_tmp_path, tempdir) do |o|
        o.on_info  { |e| emit(:info, e) }
        o.on_error { |e| emit(:error, e) }
        o.on_r_script { |e| emit(:payload, e) } if show_r_script
        o.stop_after_script = stop_after?(:show_r_script)  if show_r_script
        o.title = title
      end
    end

    def stop_after? name
      if name  == @stop_after
        emit(:info, "(--stop requested after #{name})")
        return true
      end
    end

    def tempdir
      @tempdir ||= begin
        path = tempdir_path
        path.respond_to?(:call) and path = path.call
        API::Tempdir.new(path.to_s) do |o|
          o.on_create { |e| emit(:info, "created directory: #{e.tempdir.pretty}") }
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
      else
        tempdir.ready? or return error("failed to make tempdir: #{tempdir.invalid_reason}: #{tempdir.pretty}")
        existed = csv_tmp_path.exist?
        result = nil ; File.open(csv_tmp_path.to_s, 'w+') { |fh| result = yield(fh) }
        if result
          emit(:info, "#{existed ? 'overwrote' : 'wrote'} #{csv_tmp_path.pretty} (#{result.num_lines} lines)")
        else
          emit(:error, "there was an issue in writing #{csv_tmp_path.pretty}.")
        end
        result
      end
    end
  end
end

