require 'assess/code-adapter/ramaze'

module Hipe
  module Assess
    module Commands

      listing_index 600

      RamazeSubs = %w(summary controller)
      o "#{app} web (#{RamazeSubs.join('|')}) [OPTIONS] [ARGUMENTS]"
      x 'Add and edit files for a ramaze web app. (-h)'
      def web opts={}, *args
        subcommand_dispatch RamazeSubs, opts, args
      end

    private

      o "#{app} web summary"
      x "Show summary info about the current app."
      def web_summary opts, *args
        return help if opts[:h]
        thing = Ramaze.app_info.summary
        ui.puts thing.jsonesque
      end

      RamazeSubCmd2 = %w(summary hello merge)
      o "#{app} web controller (#{RamazeSubCmd2.join('|')}) [OPTS] [ARGS]"
      x "Do some stuff with controllers. (-h)"
      def web_controller opts, *args
        subcommand_dispatch(RamazeSubCmd2, opts, args)
      end

      o "#{app} web controller summary"
      x "List known controllers."
      def web_controller_summary opts, *args
        return help if opts[:h]
        ui.puts Ramaze.controller_summary.jsonesque
      end

      o "#{app} web controller hello [OPTS]"
      x "Make a hello world controller."
      x "  This is the minimal ramaze app, to test if it works."
      x
      x "Options:"
      x "  -d, --dry    dry run -- don't actually do anything."
      x "  -i=STR       files are edited in-place always. The default is to "
      x "               make a backup copy with a datestamp.  If you pass the"
      x "               empty string as an argument, no backup will be made."
      x "  -p, --prune  remove backup files that you have generated."
      def web_controller_hello opts, prune=nil
        return help if opts[:h]
        return help unless opts.valid? do
          opts.parse!('-i=STR',     :backup_extension)
          opts.parse!('-d, --dry',  :dry_run?)
          opts.parse!('-p, --prune',:prune?)
        end
        Ramaze.hello_world ui, opts
      end

      o "#{app} web controller merge [OPTS] MODEL_NAME"
      x "Make or merge-in the necessary files and code (-h)"
      x "  for the model and/or app."
      x
      x "Options:"
      x "  -d, --dry    dry run -- don't actually do anything"
      x "                 (this will still use writable-temp)"
      x "  -p, --prune  delete all the files that exist and"
      x "                 are identical to what would have been "
      x "                 (was) generated."
      def web_controller_merge opts, model_name=nil
        return help if opts[:h]
        unless model_name
          ui.puts "#{this_command}: please provide MODEL_NAME"
          return help
        end
        return help unless opts.valid? do
          opts.parse!('-d, --dry',        :dry_run?)
          opts.parse!('-p, --prune',      :prune?)
          opts.parse!('-m, --code-merge', :code_merge?)
        end
        Ramaze.controller_merge ui, opts, model_name
      end
    end
  end
end
