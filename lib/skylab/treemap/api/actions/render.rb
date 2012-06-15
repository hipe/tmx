require_relative '../../models'
require 'fileutils'

module Skylab::Treemap
  class API::Actions::Render < API::Action
    emits payload: :all, info: :all, error: :all

    attribute :char, required: true, regex: [/^.$/, 'must be a single character']
    attribute :path, path: true, required: true
    attribute :tempdir_path, default: ->(){ File.join(FileUtils.pwd, '_tmp-r-data') }
    attribute :show_csv
    attribute :show_tree

    CSV_OUT_NAME = 'out.csv'

    def csv_tmp_path
      @csv_tmp_path ||= API::Path.new(tempdir.join(CSV_OUT_NAME).to_s)
    end

    def invoke params
      clear!.update_parameters!(params).validate or return
      (path = self.path).exist? or return error("input file not found: #{path.pretty}")
      @tree = API::Parse::Indentation.invoke(attributes, path, char) { |o|
        o.on_parse_error { |e| emit(:error, e) } } or return
      if show_tree
        render_debug
        return
      end
      ok = with_csv_out_stream do |csv_out|
        API::Render::CSV.invoke(@tree) do |o|
          o.on_payload { |e| csv_out.puts e.to_s }
          o.on_error   { |e| emit(:error, e) }
          o.on_info    { |e| emit(:info, e) }
        end
      end
      ok or return
      info "done."
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
        fake = PutsToEventProxy.new { |line| emit(:payload, line) }
        yield(fake) # ignore results for now
      else
        tempdir.ready? or return error("failed to make tempdir: #{tempdir.invalid_reason}: #{tempdir.pretty}")
        result = nil
        File.open(csv_tmp_path.to_s, 'w+') do |fh|
          result = yield(fh)
        end
        if result
          emit(:info, "wrote #{csv_tmp_path.pretty} (#{result.num_lines} lines)")
          true
        else
          emit(:error, "there was an issue in writing #{csv_tmp_path.pretty}.")
        end
      end
    end
  end
end

