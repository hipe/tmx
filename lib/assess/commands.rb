#
# this is based entirely off of chris wanstrath's rip
#
require 'json' # only for rescu_e

module Hipe
  module Assess
    module Commands
      include CommonInstanceMethods
      protected(*CommonInstanceMethods.instance_methods)

      extend self
      @help = {}
      @usage = {}

      def help(options = {}, command = nil, *args)
        # start experiment
        command ||= caller_method_name(1)
        command = nil if 'send'==command # @todo fixme
        # end experiment
        command = command.to_s
        if !command.empty? &&
            ( respond_to?(command) ||
              (@private_hack && @private_hack[command.to_sym])
            )
          cmd_pretty = command.gsub('_',' ').downcase
          ui.puts(
            "Usage: %s" % (@usage[command] || "#{app} #{cmd_pretty}")
          )
          if @help[command]
            ui.puts
            ui.puts(*@help[command])
          end
        else
          show_general_help
        end
      end

      def invoke argv
        command, opts, args = parse_args argv

        if command.nil?
          if ([:v, :version] & opts.keys).any?
            command = :version
          else
            command = :help
          end
        end

        use_command = find_command command
        begin
          send(use_command, opts, *args)
        rescue UserFail,
          Errno::ENOENT,
          UserFail,
          # ArgumentError,
          JSON::ParserError => e
          if opts[:error]
            raise e
          else
            say_command = command
            if e.kind_of?(ArgumentError)
              say_command = trace_row_method_name(e.backtrace[0])
            end
            bn = Assess.class_basename(e.class)
            ui.puts "#{app}: #{say_command} failed (#{bn})"
            ui.puts "#{e.message}"
            return help(nil, command)
          end
        end
      end

      def load_plugin(file)
        # @todo
        #begin
          require file
        # rescue Exception => e
        #   ui.puts "#{app}: plugin not loaded (#{file})"
        #   ui.puts "-> #{e.message}", ''
        # end
      end

    private

      def this_command
        soft = caller_method_name(1).gsub('_',' ')
        "#{app} #{soft}"
      end

      def controller(env = nil)
        @controller ||= Controller.new(env)
      end

      def ui
        @ui ||= begin
          parent_module.ui
        end
      end

      def app
        parent_module.to_s.split('::').last.downcase
      end

      def parent_module
        self.to_s.split('::').slice(0..-2).inject(Object) do |o,n|
          o.const_get(n)
        end
      end

      def o usage
        @next_usage = usage
      end

      def x help = ''
        @next_help ||= []
        @next_help.push help
      end

      def method_added(method)
        if @next_help || @next_usage
          @private_hack ||= {}
          @private_hack[method] = true
        end
        @help[method.to_s] = @next_help if @next_help
        @usage[method.to_s] = @next_usage if @next_usage
        @next_help = nil
        @next_usage = nil
      end

      def find_command command
        matches = public_instance_methods.select{|meth| meth =~ /^#{command}/}
        if matches.size == 0
          ui.puts "Could not find the command: #{command.inspect}"
          ui.puts
          :help
        elsif matches.size == 1
          matches.first
        else
          ui.abort("#{app}: which command did you mean?"<<
            " #{matches.join(' or ')}")
        end
      end

      #
      # experimental. some of this might not belong here.
      #
      module CommonOptionInstanceMethods
        include CommonInstanceMethods

        def expand_dry_run_opt!
          m = class << self; self end
          is_dry = self[:d] ? true : false
          def! :dry_run?, is_dry
          self
        end

        def expand_backup_opt!
          case self[:i]
          when ''; backup = :none
          when nil; backup = :yes
          else
            backup = :with_extension
            extension = self[:i]
          end
          # we make it like a mini openstruct
          m = class << self; self end
          # this should always be set but we do it this way to be safe
          if backup
            def! :backup, backup
            def!(:extension, extension) if extension
            do_backup = [:yes, :with_extension].include?(backup)
            def! :backup?, do_backup
          end
          self
        end
      end


      def parse_args argv
        options = argv.select { |piece| piece =~ /^-/ }
        argv   -= options
        command = argv.shift
        opts = Hash[* options.map do |flag|
          # key, value = flag.split('=')  # no good for detecting -i=''
          key,value = flag.match(/\A([^=]+)(?:=(.*))?\Z/).captures
          [key.sub(/^--?/, '').intern, value.nil? ? true : value ]
        end.flatten ]
        opts.extend CommonOptionInstanceMethods
        [ command, opts, argv ]
      end

      def show_general_help
        # chris does the below better somehow
        commands = public_instance_methods.reject do |method|
            method =~ /-/ ||
            %w( help version invoke load_plugin ).include?(method)
        end

        show_help nil, sort_commands(commands)

        ui.puts
        ui.puts "For more information on a command use:"
        ui.puts "  #{app} help COMMAND"
        ui.puts

        ui.puts "Options: "
        ui.puts "  -h, --help     show this help message and exit"
        ui.puts "  -v, --version  show the current version and exit"
      end

      def subcommand_help subs, opts, args, meth
        prefix = meth.gsub('_',' ')
        commands_pretty = subs.map{|x| "#{meth} #{x}" }
        show_help(prefix, commands_pretty)
      end

      def sort_commands(commands)
        commands
      end

      def show_help(command, commands_pretty = commands)
        subcommand = command.to_s.empty? ? nil :
          "#{command.upcase}_"
        ui.puts "Usage: #{app} #{subcommand}COMMAND [options]", ""
        ui.puts "Commands available:"

        show_command_table begin
          commands_pretty.zip(
            commands_pretty.map do |c|
              _c = c.gsub(' ','_')
              @help[_c].first unless @help[_c].nil?
            end
          )
        end
      end

      def show_command_table table
        return if table.empty?

        offset = table.map {|a| a.first.size }.max + 2
        offset += 1 unless offset % 2 == 0

        table.each do |(command, help)|
          ui.puts "  #{command}" << ' ' * (offset - command.size) << help.to_s
        end
      end

      def caller_method_name idx
        trace_row_method_name(caller[idx])
      end

      def pretty(str)
        str.gsub('_', ' ')
      end

      def trace_row_method_name row
        row.match(/`([^']+)'\Z/)[1]
      end

      #
      # on fail shows help and returns false
      # @return false or IO handle
      #
      def input_from_stdin_or_filename file
        sin = false
        if $stdin.tty?
          if file
            sin = File.open(file,'r')
          else
            call_name = caller_method_name(1)
            pretty = pretty(call_name)
            me = "#{app} #{pretty}"
            ui.puts "#{me}: STDIN was tty and no filename provided."
            help nil, call_name
          end
        else
          if file
            call_name = caller_method_name(1)
            pretty = pretty(call_name)
            me = "#{app} #{pretty}"
            ui.puts("#{me}: STDIN was not tty and "<<
              "filename was provided.")
            help nil, call_name
          else
            sin = $stdin
          end
        end
        sin
      end

      def subcommand_dispatch subcommands, opts, args
        meth = caller_method_name(1)
        if ! args.any? && opts[:h]
          opts[:h] = false; # stop propagation ?
          return subcommand_help subcommands, opts, args, meth
        end
        subcommand = args.shift
        sub_meth = "#{meth}_#{subcommand}"
        if subcommands.include?(subcommand)
          send(sub_meth, opts, *args)
        else
          my_name = "#{app} #{pretty(meth)}"
          if subcommand
            ui.puts("#{my_name}: Unrecognized command #{subcommand.inspect}.")
          end
          ui.puts("#{my_name}: expecting sub-command " <<
            oxford_comma(subcommands.map(&:inspect),' or ') << ".")
          ui.puts("  Try -h for more information.")
          help(nil, meth)
          :bad_subcommand # not sure about this
        end
      end
    end # Commands
  end # Assess
end # Hipe

# load lib/assess/commands/*.rb
if File.exists? dir = File.join(File.dirname(__FILE__), 'commands')
  Dir[dir + '/*.rb'].each do |file|
    Hipe::Assess::Commands.load_plugin file
  end
end
