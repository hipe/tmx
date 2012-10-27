require 'optparse'
require 'stringio'
require_relative '../test-support'

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
    include TanMan::TestSupport::Tmpdir_InstanceMethods # prepared_submodule_tmpdir

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

    NUM_RX = /\A([A-Za-z]+(?:::[A-Za-z]+)+)\d+[^:]+\z/

    def anchor_module_head
      _md = NUM_RX.match(self.class.to_s) or fail("failed to infer#{
        } anchor_module_head from this class name, expecting leading consts#{
        } without digits and the trailing const to have a digit in it#{
        } (You may need to implement your own hacky thing up the chain.)#{
        } (Your thing: #{self.class})")
      _md[1]
    end

    PATHSPEC_SYNTAX = '[ - | <filename> ]'

    def build_option_parser
      op = ::OptionParser.new
      op.banner = usage_line
      op.separator "#{em 'options:'}"
      op.on('-s <string>', "parse string instead of #{PATHSPEC_SYNTAX}") do |v|
        invocation_parameters.push([:upstream_string, v])
      end
      op.on('-e <method>', "if the parse succeeds,",
        "run <method> on the result and dump this result.") do |meth|
        invocation_parameters.push([:eval_string, meth])
      end
      op
    end

    def anchor_dir_pathname
      @anchor_dir_pathname ||= grammars_module.dir_pathname.join stem_path
    end

    attr_accessor :eval_string

    def eval_string_run result
      unless /\A[a-z_]+[a-z0-9_]*\z/ =~ eval_string
        fail("must be a valid method name: #{eval_string.inspect}")
      end
      _ = result.send eval_string
      ::PP.pp _, infostream
      true
    end

    def execute
      info "(parsing upstream which is a #{upstream.class})"
      info "(parser is #{parser.class})"
      result = parse upstream
      info "OK, WE GOT (after #{1000 * parse_time_elapsed_seconds
        } ms): #{result.class}"
      if result
        require 'pp'
        if eval_string
          eval_string_run result
        else
          ::PP.pp result, infostream
          true
        end
      end
    end

    def force_overwrite?
      false # in flux -- sometimes we blow away the tmpdir once
    end

    def self.grammars_module
      @grammars_module ||= begin
        self.to_s.split('::')[0..-2].reduce(::Object) { |m, k| m.const_get(k) }
      end
    end

    def grammars_module
      self.class.grammars_module
    end

    def load_parser_class
      f = on_load_parser_info_f ||
        ->(e) { info "      (loading parser ^_^ #{pretty_path_hack e.to_s})" }

      ::Skylab::TreetopTools::Parser::Load.new(
        ->(o) do
          force_overwrite? and o.force_overwrite!
          o.generated_grammar_dir tmpdir_prepared
          o.root_for_relative_paths anchor_dir_pathname
          grammars o
        end,
        ->(o) do
          o.on_info(& f )
          o.on_error { |e| fail("failed to load grammar: #{e}") }
        end
      ).invoke
    end

    def grammars o
      o.treetop_grammar 'g1.treetop'
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

    def stem_const_rx
      @stem_const_rx ||= /\A#{anchor_module_head}(.+)\z/
    end

    def stem_path
      @stem_path ||= begin
        _stem_const = stem_const_rx.match(self.class.to_s)[1]
        ::Skylab::Autoloader::Inflection.pathify _stem_const
      end
    end

    def tmpdir_prepared
      @tmpdir_prepared ||= begin
        t = prepared_submodule_tmpdir.join stem_path
        t.exist? or t.prepare # because parent gets rewritten once per runtime
        t
      end
    end

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
