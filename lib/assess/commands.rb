#
# this is based entirely off of chris wanstrath's rip
#
require 'json' # only for rescu_e

module Hipe
  module Assess
    module Commands
      include CommonInstanceMethods # @todo if u remove this this depencency
                                    # this will be very resusable
      protected(*CommonInstanceMethods.instance_methods)

      extend self
      @help = {}
      @usage = {}

      def help(opts = {}, command = nil, *args)
        opts ||= {}
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
        command, opts, args = OptParseLite.parse_args(argv, self)

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

      def this_command idx=1
        soft = caller_method_name(idx).gsub('_',' ')
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

      def listing_index int=nil
        @listing_index ||= []
        if int.nil?
          @listing_index
        else
          idx = @listing_index.index{|x| x[:index] == int}
          if idx
            @current_list = @listing_index[:list]
          else
            if ! @listing_index.any?
              idx = 0
            else
              idx = @listing_index.index{|x| x[:index] > int}
              if ! idx
                idx = @listing_index.length
              end
            end
            thing = {:index => int, :list => []}
            @listing_index.insert(idx, thing)
            @current_list = thing[:list]
          end
          nil
        end
      end

      def current_list
        @current_list ||= begin
          listing_index(-1)
          @current_list
        end
      end

      def o usage
        @next_usage = usage
      end

      def x help = ''
        @next_help ||= []
        @next_help.push help
      end

      def enable_closest_match!
        if @closest_match_enabled == false
          fail("can't turn short commands on when they are off")
        end
        @closest_match_enabled = true
      end

      def closest_match_enabled?
        @closest_match_enabled
      end

      def method_added(method)
        current_list.push method
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
        ui.puts "or try the -h option on a sub-command"
        ui.puts
        ui.puts "Options: "
        ui.puts "  -h, --help     show this help message and exit"
        ui.puts "  -v, --version  show the current version and exit"
      end

      def subcommand_help subs, opts, args, meth
        prefix = meth.gsub('_',' ')
        commands_pretty = subs.map{|x| "#{prefix} #{x}" }
        show_help(prefix, commands_pretty)
      end

      def sort_commands commands
        map = command_sort_map
        commands.sort do |a,b|
          map[a.to_sym] <=> map[b.to_sym]
        end
      end

       # you will get a caching problem depending on when you call it
      def command_sort_map
        # because method_added() calls current_list() we assume @listing_index
        @command_sort_map ||= begin
          ordered = @listing_index.map{|x| x[:list]}.flatten
          Hash[ * ordered.zip((0..ordered.length-1).to_a).flatten ]
        end
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

      def messages
        @messages ||= {}
      end

      def set_message(name, value)
        messages[name] = value
      end

      def message? name
        messages.has_key? name
      end

      def pop_message name
        messages.delete(name)
      end

      # if found unambiguous, execute it
      def attempt_closest_match(cmds, cmd, meth, opts, args)
        return false if cmd.nil? # when user didn't provide a sub
        return false unless closest_match_enabled?
        re = Regexp.new('\A'+Regexp.escape(cmd))
        found = cmds.grep(re)
        case found.size
        when 0; return :unresolved
        when 1
          sub = found.first
          sub_meth = meth ? "#{meth}_#{sub}" : sub
          send(sub_meth, opts, *args)
        else
          set_message(:ambig,("Did you mean "<<
            oxford_comma(found.map(&:inspect),' or ')<<'?'))
          return :unresolved
        end
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
        elsif (:unresolved !=
          (resp =
            attempt_closest_match(subcommands, subcommand, meth, opts, args)
          )
        )
          # it handled it
          resp
        else
          my_name = "#{app} #{pretty(meth)}"
          if subcommand
            adj = message?(:ambig) ? 'Ambiguous' : 'Unrecognized'
            ui.puts("#{my_name}: #{adj} command #{subcommand.inspect}.")
            ui.puts("#{my_name}: #{pop_message(:ambig)}") if message?(:ambig)
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
