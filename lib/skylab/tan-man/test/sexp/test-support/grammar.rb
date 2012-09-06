require 'optparse'
require 'stringio'

module ::Skylab::TanMan::Sexp::TestSupport
  module CLI_Client_InstanceMethods
  protected
    def em str
      "\e[1;32m#{str}\e[0m"
    end
    def emit type, str
      (:payload == type ? paystream : infostream).puts str
    end
    def error msg
      self.errors_count += 1
      emit :error, msg
      false
    end
    def errors_count ; @errors_count ||= 0 end
    attr_writer :errors_count
    def failed msg
      info msg
      invite
      false
    end
    def info m ; emit(:info, m) end
    def invite
      info "try #{em "#{program_name} -h"} for help"
    end
    def invocation_parameters ; @invocation_parameters ||= [] end
    def option_parser ; @option_parser ||= build_option_parser end
    def parse_opts argv
      option_parser.parse! argv
      before = errors_count # intentionally here to enforce good design
      invocation_parameters.each do |key, val|
        send("#{key}=", val)
      end
      errors_count <= before
    rescue ::OptionParser::ParseError => e
      usage e.message
    end
    def program_name
      (@program_name ||= nil) or ::File.basename($PROGRAM_NAME)
    end
    def usage msg=nil
      msg and info(msg)
      info usage_line
      invite
      false
    end
  end

  class Grammar < ::Struct.new(:upstream, :paystream, :infostream)
    include TanMan::Models::DotFile::Parser::InstanceMethods # parsing porcelain
    include CLI_Client_InstanceMethods

    def initialize i=$stdin, o=$stdout, e=$stderr
      @stdin = i ; self.paystream = o ; self.infostream = e
      # (keep stdin on deck but don't set upstream here. it takes logix)
    end

    def invoke argv
      parse_opts(argv) or return
      resolve_upstream(argv) or return
      execute
    end

  protected
    PATHSPEC_SYNTAX = '[ - | <filename> ]'

    def build_option_parser
      op = ::OptionParser.new
      op.banner = usage_line
      op.separator "#{em 'options:'}"
      op.on('-s <string>', "parse string instead of #{PATHSPEC_SYNTAX}") do |v|
        invocation_parameters.push([:upstream_string, v])
      end
      op
    end

    TAIL_CONST_RX =
      /\A#{::Skylab::TanMan::Sexp::TestSupport::Grammars}::Grammar(.+)\z/
    def dir
      @dir ||= begin
        tail_const = TAIL_CONST_RX.match(self.class.to_s)[1]
        tail_path = ::Skylab::Autoloader::Inflection.pathify(tail_const)
        Grammars.dir_pathname.join tail_path
      end
    end

    def execute
      info "(parsing upstream which is a #{upstream.class})"
      info "(parser is #{parser.class})"
      result = parse upstream
      info "OK, WE GOT: #{result.class}"
      if result
        require 'pp'
        ::PP.pp result, infostream
      end
    end

    def load_parser_class
      ::Skylab::TreetopTools::Parser::Load.new(
        ->(o) do
          o.force_overwrite!
          o.generated_grammar_dir tmpdir
          o.root_for_relative_paths dir
          o.treetop_grammar 'g1.treetop'
        end,
        ->(o) do
          o.on_info { |e| info "(loading parser #{e})" }
          o.on_error { |e| fail("failed to load grammar: #{e}") }
        end
      ).invoke
    end

    attr_reader :pathname

    def resolve_upstream argv
      if upstream
        0 == argv.length or
          usage("Upstream already resolved. #{
            }Expecting zero args, had #{argv.length}.")
      elsif 1 == argv.length
        pathspec = argv.shift
        if '-' == pathspec
          if @stdin.tty?
            usage("expeding STDIN to be an readable stream, was tty.")
          else
            self.upstream = build_stream_input_adapter @stdin
            @stdin = nil
            true
          end
        elsif @stdin.tty?
          @pathname = ::Pathname.new(pathspec)
          if @pathname.exist?
            self.upstream = build_file_input_adapter @pathname
          else
            failed("file not found: #{@pathname}")
          end
        else
          usage("can't have both STDIN and <pathspec>: #{pathspec}")
        end
      else
        usage("expecting #{PATHSPEC_SYNTAX}, had #{argv.length} args.")
      end
    end

    tmpdir = nil
    TMPDIR_F = -> do
      unless tmpdir
        tmpdir = ::Skylab::TestSupport::Tmpdir.new(
          ::Skylab::ROOT.join('tmp/tan-man').to_s  )
        tmpdir.exist? or tmpdir.prepare
      end
      tmpdir
    end
    def tmpdir ; TMPDIR_F.call end

    def usage_line
      "#{em 'usage:'} #{program_name} [opts] #{PATHSPEC_SYNTAX}"
    end

    def upstream_string= str
      if upstream
        error "can't set upstream string, upstream is already set."
      else
        self.upstream = build_string_input_adapter str
      end
      str
    end
  end
end
