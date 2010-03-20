require 'assess/code-adapter/ramaze'

module Hipe
  module Assess
    module Commands

      RamazeSubs = %w(summary controller)
      o "#{app} ramaze (#{RamazeSubs.join('|')}) [OPTIONS] [ARGUMENTS]"
      x 'Maybe init current directory for ramaze web app.'
      x '"-h" after a sub-command might work if you are lucky.'
      def ramaze opts={}, *args
        sub_command_dispatch RamazeSubs, opts, args
      end

    private

      o "#{app} ramaze summary"
      x "Show summary info about the current app."
      def ramaze_summary opts, *args
        return help if opts[:h]
        thing = Ramaze.app_info.summary
        ui.puts thing.jsonesque
      end

      RamazeSubCmd2 = %w(summary update hello)
      o "#{app} ramaze controller (#{RamazeSubCmd2.join('|')}) [OPTS] [ARGS]"
      x "Do some stuff with controllers."
      def ramaze_controller opts, *args
        sub_command_dispatch(RamazeSubCmd2, opts, args)
      end

      o "#{app} ramaze controller summary"
      x "List known controllers."
      def ramaze_controller_summary opts, *args
        return help if opts[:h]
        ui.puts Ramaze.controller_summary.jsonesque
      end

      o "#{app} ramaze controller hello [prune]"
      x "Make a hello world controller."
      x
      x "Options:"
      x "  -d       dry run -- don't actually do anything."
      x "  -i=STR   files are edited in-place always. The default is to "
      x "           make a backup copy with a datestamp.  If you pass the"
      x "           empty string as an argument, no backup will be made."
      def ramaze_controller_hello opts, prune=nil
        return help if opts[:h]
        unless [nil,'prune'].include?(prune)
          ui.puts("#{this_command}: expecting \"prune\" not #{prune.inspect}")
          return help
        end
        opts[:prune] = true if prune # hackish
        if true==opts[:i]
          ui.puts("#{this_command}: -i must take an argument")
          return help
        end
        opts.expand_backup_opt!
        opts.expand_dry_run_opt!
        Ramaze.hello_world ui, opts
      end
    end
  end
end
