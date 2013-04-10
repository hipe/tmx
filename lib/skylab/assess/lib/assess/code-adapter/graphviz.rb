require 'graphviz'
me = File.join(File.dirname(__FILE__), 'graphviz')
require me + '/abstract-model.rb'
require me + '/generate.rb'

module Hipe
  module Assess
    module Graphviz
      include CommonInstanceMethods
      extend self
      def process_generate_dotfile_request ui, opts, model_file=nil
        @ui = ui
        @app_info = nil
        ui.err = $stderr if ui.err == ui
        if model_file
          load_model_file_from_path model_file
        else
          load_model_file_from_app_info
        end
        graph = generate_struct
        return PP.pp(graph, ui) if opts.struct?
        return ui.puts(JSON.pretty_generate(graph.tojson)) if opts.json?
        generate ui, opts, graph
        nil
      end
      def app
        @app_info ||= begin
          require 'assess/code-adapter/framework-common/app-info'
          FrameworkCommon::AppInfo.current
        end
      end
    private
      def me; "assess graphviz: " end
      attr_accessor :ui
      def load_model_file_from_app_info
        @app_info = FrameworkCommon::AppInfo.current
        if ! app.has_model?
          flail("#{app.name} has no known model: "<<
          "#{app.model.pretty_path}"){|e|e.dont_show_help!}
        end
        ui.err.print(
          "#{me}attempting to load model: #{app.model.pretty_path} .. ")
        app.orm.abstract_model_interface.load_model
        ui.err.puts("loaded.")
      end
      def load_model_file_from_path model_file
        fail("file not found: #{model_file}") unless File.exist?(model_file)
        ui.err.print "attempting to load: #{model_file} .. "
        require model_file
        ui.err.puts "loaded"
      end
      def generate_struct
        graph = Graph.new(:data_mapper)
        desc = ::DataMapper::Model.descendants.to_ary
        count = desc.length
        ui.err.print "#{Cmd.soft_name}: #{count} datamapper model descendants found."
        desc.each do |mod|
          graph.process_model mod
        end
        graph
      end
    end
  end
end
