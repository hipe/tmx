require 'assess/code-builder'
require 'assess/util/uber-alles-array'
require 'assess/util/sexpesque'
require 'assess/code-adapter/framework-common'


module Hipe
  module Assess
    module Ramaze
      extend self

      class AppInfo < FrameworkCommon::AppInfo
        def hello_world_path
          File.join(app_root.path,'hello_world.rb')
        end
      end

      # @todo
      def app_info
        AppInfo.current
      end

      def controller_summary
        s = Sexpesque
        summary = s[:controllers]
        if ! app_info.controller.exists?
          summary.push(:none)
        else
          summary.push app_info.controller.summary
        end
        summary
      end

      def controller_merge *a
        require 'assess/code-adapter/ramaze/controller-merge'
        ControllerMerge.controller_merge(*a)
      end

      def hello_world ui, opts
        file = CodeBuilder.create_or_get_file_sexp(app_info.hello_world_path)
        return file.prune_backups ui, opts if opts[:prune]
        if ! file.simple_requires.include? 'ramaze'
          file.add_require_at_top 'ramaze'
        end
        cls = file.block!.module!(:HelloWorld).class!(
          :Bar, 'Ramaze::Controller')
        write_it = false
        if cls.instance_method? :index
          ui.puts("#{file.path} already has #{cls.name_sym}#index")
        else
          method_sexp = CodeBuilder.parse("def index; 'Hello World!'; end")
          cls.add_instance_method_sexp method_sexp
          write_it = true
        end

        call_sexp = CodeBuilder.parse("Ramaze.start")
        if file.has_node?(call_sexp)
          ui.puts("#{file.path} already has call to Ramaze.start.")
        else
          write_it = true
          file.push call_sexp
        end

        if write_it
          file.write_ruby(ui,  opts)
        else
          ui.puts "#{file.path} Nothing to write."
        end

        ui.puts
        ui.puts "Try starting the server with 'ruby #{file.path}'"
      end
    end
  end
end
