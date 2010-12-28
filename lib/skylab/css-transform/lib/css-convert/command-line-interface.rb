require 'optparse'

module Hipe::CssConvert
  class CliBase # from yacc-to-treetop
    def run argv
      @argv = argv
      @c = build_context
      @exit_ok = nil
      @queue = []
      begin
        option_parser.parse!(argv)
        @queue.push default_action
        catch(:early_exit){ @queue.each{ |meth| send meth } }
      rescue OptionParser::ParseError => e
        error e.message
      end
    end
  protected
    Codes = {:bold=>1,:dark_red=>31,:green=>32,:yellow=>33,:blue=>34,
      :purple=>35,:cyan=>36,:white=>37,:red=>38}
    def color(s, *a); "\e[#{a.map{|x|Codes[x]}.compact*';'}m#{s}\e[0m" end
    def em(s); style(s, :em) end
    Styles = { :error => [:bold, :red], :em => [:bold, :green] }
    def style(s, style); color(s, *Styles[style]) end
    def error msg
      @c.err.puts msg
      @c.err.puts usage
      @c.err.puts invite
    end
    def fatal msg
      @c.err.puts msg
      throw :early_exit
    end
    def invite
      em("#{program_name} -h") << " for help"
    end
    def option_parser
      @option_parser ||= build_option_parser
    end
    def run_help
      @c.err.puts option_parser.to_s
      @exit_ok = true
    end
    def run_version
      @c.err.puts "#{program_name} #{version_string}"
      @exit_ok = true
    end
    def usage
      "#{em('usage:')} #{usage_syntax_string}"
    end
  end
  class ExecutionContext < Hash
    def initialize
      @out = $stdout
      @err = $stderr
    end
    attr_reader :out, :err
  end
  class CommandLineInterface < CliBase
    def initialize
    end
  private
    def program_name;        File.basename($PROGRAM_NAME) end
    def default_action;      :run_convert                 end
    def usage_syntax_string; "#{program_name} [opts] <command-file>" end

    def build_context
      ExecutionContext.new
    end
    def build_option_parser
      OptionParser.new
    end
    def run_convert
      @c.out.puts "ok whatever"
    end
  end
end
