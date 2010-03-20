#
# using chris wanstrath's pattern from rip
#
module Hipe
  module Assess
    module Commands

      x 'Can you connect?'
      def db opts={}, *args
        require 'assess/code-adapter/framework-common'
        ui.puts FrameworkCommon.dispatch_db_check(opts, *args).jsonesque
      end

      x 'Prints the current version(s) and exits.'
      def version(options = {}, *args)
        ui.puts "#{app} version #{Assess::Version}"

        require 'assess/code-adapter/framework-common/app-info'
        app_info = FrameworkCommon::AppInfo.current

        ui.puts "your app: #{app_info.name} version #{app_info.version}"
      end

      x 'Populate database with domain info (from json).'
      o "#{app} import MODEL_NAME JSON_FILE"
      def populate opts, model_name=nil, json_file=nil
        require 'assess/code-adapter/framework-common'
        return help if opts[:h]
        return help unless entity_name_valid?('model name',opts,model_name)
        opts.def!(:model_name, model_name)
        sin = input_from_stdin_or_filename(json_file) or return
        FrameworkCommon.dispatch_merge_data ui, sin, opts
      end
    end
  end
end
