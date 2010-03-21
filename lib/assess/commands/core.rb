#
# using chris wanstrath's pattern from rip
#
module Hipe
  module Assess
    module Commands

      x 'Can you connect?'
      def db opts={}, *args
        if args.any?
          ui.puts "unexpected argument(s): #{args.join(' ')}"
          return help
        end
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

      DataSubs = %w(merge)
      o "#{app} data (#{DataSubs.join('|')}) OPTS ARGS"
      x 'Do data-related stuff. (-h)'
      def data opts, *args
        return help if opts[:h] && ! args.any?
        subcommand_dispatch(DataSubs, opts, args)
      end

    private

      o "#{app} data merge MODEL_NAME [JSON_FILE_NAME]"
      x 'Import data from json file or stdin'
      def data_merge opts, model_name=nil, json_file = nil
        return help if opts[:h]
        require 'assess/code-adapter/framework-common'
        return help unless entity_name_valid?('model name',opts,model_name)
        opts.def!(:model_name, model_name)
        sin = input_from_stdin_or_filename(json_file) or return
        FrameworkCommon.dispatch_merge_data ui, sin, opts
      end
    end
  end
end
