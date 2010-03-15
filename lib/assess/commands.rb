#
# this is based entirely off of chris wanstrath's rip
#

module Hipe
  module Assess

    class UI
      def initialize io = nil, verbose = false
        @io = io
        @verbose = verbose
      end

      def puts(*args)
        return unless @io

        if args.empty?
          @io.puts ""
        else
          args.each { |msg| @io.puts(msg) }
        end

        @io.flush
        nil
      end

      def abort msg
        @io && Kernel.abort("#{app}: #{msg}")
      end

      def vputs *args
        puts(*args) if @verbose
      end
    end

    class Never; end

    module Commands
      extend self
      @help = {}
      @usage = {}

      def help(options = {}, command = nil, *args)
        command = command.to_s
        if !command.empty? && respond_to?(command)
          ui.puts(
            "Usage: %s" % (@usage[command] || "#{app} #{command.downcase}")
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
          if ([:v, :version].include?(opts.keys))
            command = :version
          else
            command = :help
          end
        end

        use_command = find_command command
        begin
          send(use_command, opts, *args)
        rescue Never => e
          if opts[:error]
            raise e
          else
            ui.puts "#{app}: #{command} failed"
            ui.puts "-> #{e.message}"
          end
        end
      end

      def load_plugin(file)
        begin
          require file
        rescue Exception => e
          ui.puts "#{app}: plugin not loaded (#{file})"
          ui.puts "-> #{e.message}", ''
        end
      end

    private

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

      def parse_args argv
        options = argv.select { |piece| piece =~ /^-/ }
        argv   -= options
        command = argv.shift
        opts = Hash[* options.map do |flag|
          key, value = flag.split('=')
          [key.sub(/^--?/, '').intern, value.nil? ? true : value ]
        end.flatten ]
        [ command, opts, argv ]
      end

      def show_general_help
        # chris does the below better somehow
        commands = public_instance_methods.reject do |method|
            method =~ /-/ ||
            %w( help version invoke load_plugin ).include?(method)
        end

        show_help nil, commands.sort

        ui.puts
        ui.puts "For more information on a command use:"
        ui.puts "  #{app} help COMMAND"
        ui.puts

        ui.puts "Options: "
        ui.puts "  -h, --help     show this help message and exit"
        ui.puts "  -v, --version  show the current version and exit"
      end

      def show_help(command, commands = commands)
        subcommand = command.to_s.empty? ? nil : "#{command} "
        ui.puts "Usage: #{app} #{subcommand}COMMAND [options]", ""
        ui.puts "Commands available:"

        show_command_table begin
          commands.zip begin
            commands.map { |c| @help[c].first unless @help[c].nil? }
          end
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
    end
  end
end

# load lib/assess/commands/*.rb
if File.exists? dir = File.join(File.dirname(__FILE__), 'commands')
  Dir[dir + '/*.rb'].each do |file|
    Hipe::Assess::Commands.load_plugin file
  end
end
