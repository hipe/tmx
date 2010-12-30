# require 'rubygems'; require 'ruby-debug'; $stderr.puts "\e[1;5;33mruby-debug\e[0m"

module Hipe::CssConvert::TreetopTools
  class << self
    def load_parser_class &b
      ParserClassLoader.new(&b).run
    end
  end
  class RuntimeError < ::RuntimeError; end
  class Sexpesque < Array
    alias_method :node_name, :first
    class << self
      def build name, *childs
        new([name, *childs])
      end
      alias_method :[], :build
    end
  end
  class ParserClassLoader
    def initialize &b
      @ui = nil
      @do = { :grammars => [], :enhance => [] }
      yield self
    end
    def enhance_parser_with mod
      @do[:enhance].push mod
    end
    def force_overwrite!
      @do[:overwrite] = true
    end
    def root_dir dir
      @do[:root_dir] = dir
    end
    def treetop_grammar path
      @do[:grammars].push path
    end
    def use_ui ui
      @ui = ui
    end
    def generated_grammar_dir dir
      @do.key?(:gennd_dir) and
        fail("only specify generated_grammar_dir once")
      @do[:gennd_dir] = dir
    end
    def run
      @do[:gennd_dir_full] = File.expand_path(@do[:gennd_dir], @do[:root_dir])
      File.directory?(@do[:gennd_dir_full]) or
        return error("must exist and be a directory: " <<
          " #{@do[:gennd_dir_full].inspect}")
      gx = load_or_generate_grammar_files
      parts = grammar_module_name_in(fullpath(gx.last.first))
      parts.last.concat 'Parser'
      cls = parts.inject(Object){ |m,n| m.const_get(n) }
      @do[:enhance].each do |enhance_mod|
        cls = make_enhanced_class(cls, enhance_mod)
      end
      cls
    end
  private
    def error(msg); raise RuntimeError.new(msg) end
    def fullpath(relpath); File.join(@do[:root_dir], relpath) end
    def load_or_generate_grammar_files
      gx = @do[:grammars].map do |gname|
        [gname, x = File.join(@do[:gennd_dir], gname) + '.rb', fullpath(x)]
      end
      @ui and summarize(gx)
      gx.each do |gname, gennd_name, full|
        (@do[:overwrite] or !File.exist?(full)) and recompile(gname, full)
        begin
          require full
        rescue ::NameError => e
          raise RuntimeError.new( [e.message,
          ( (m = parse_stack_item(e.backtrace.first)) ?
            "in #{File.basename(m[:file])}:#{m[:line]}" :
            "(#{e.backtrace.first})"
          ) ].join(' ') )
        end
      end
      gx
    end
    def make_enhanced_class cls, mod
      newcls = Class.new(cls)
      cls_modname, cls_basename =
        cls.to_s.match(/\A(?:(.*[^:])::)?([^:]+)\Z/).captures
      newcls.class_eval do
        include mod
        mod.override.each{ |meth| alias_method meth, "my_#{meth}" }
      end
      parent_mod = (cls_modname.nil?) ? Object :
        cls_modname.split('::').inject(Object){ |m,n| m.const_get(n) }
      nonum, num = cls_basename.match(/\A(.*[^0-9])([0-9]+)?\Z/).captures
      usename = "#{nonum}#{num.nil? ? 2 : (num.to_i + 1)}"
      newconst = parent_mod.const_set(usename, newcls)
      newconst
    end
    def mkdir_safe? dir, gname
      # don't make any new directories deeper than the amt of dirs in gname
      s = dir
      gname.scan(%r{/}).size.times{ s = File.dirname(s) }
      File.directory?(s) or return error("directory must exist: #{s}")
      require 'fileutils'
      @ui and (hold = $stderr and $stderr = @ui.err)
      begin
        FileUtils.mkdir_p(dir, :verbose => @ui)
      ensure
        @ui and $stderr = hold
      end
      true
    end
    def parse_stack_item str
      if md = /\A([^:]+):(\d+)(?::in `([^']+)')?\Z/.match(str)
        {:file => md[1], :line => md[2], :method => md[3] }
      end
    end
    def grammar_module_name_in gpath
      require 'strscan'
      scn = nil
      mods = []
      gram = nil
      File.open(gpath, 'r') do |fh|
        while line = fh.gets
          scn.nil? ? (scn = StringScanner.new(line)) : (scn.string = line)
          scn.skip(/[ \t]*(#.*)?\n?/)
          scn.eos? and next
          if scn.scan(/module[ \t]+/)
            mname = scn.scan(/[A-Z][a-zA-Z0-9_]+/) or fail("no: #{scn.rest}")
            mods.push mname
          elsif scn.scan(/grammar[ \t]+/)
            gram = scn.scan(/[A-Z][a-zA-Z0-9_]+/) or fail("no: #{scn.rest}")
            break
          else
            fail("no: #{scn.rest.inspect}")
          end
          scn.skip(/[ \t]*(#.*)?\n?/)
          scn.eos? or fail("huh?: #{scn.rest.inspect}")
        end
      end
      mods.push(gram)
    end
    def recompile gname, ppath_full
      gpath_full = fullpath(gname)
      dir = File.dirname(ppath_full)
      File.directory?(dir) or mkdir_safe?(dir, gname) or return
      @compiler ||= ::Treetop::Compiler::GrammarCompiler.new
      begin
        @compiler.compile(gpath_full, ppath_full)
      rescue ::RuntimeError => e
        raise RuntimeError.new("when compiling #{gpath_full}:\n#{e.message}")
      end
    end
    def summarize gx
      ex = []; cx = []
      gx.each { |x| ( File.exist?(x[2]) ? ex : cx ).push x[1] }
      ex.any? and @ui.err.puts((@do[:overwrite] ? "overwriting": "using") <<
        ": #{ex.join(', ')}")
      cx.any? and @ui.err.puts("creating: #{cx.join(', ')}")
    end
  end
  module ParserExtlib

    def self.override; [:failure_reason] end

    def my_failure_reason
      return nil unless (tf = terminal_failures) && tf.size > 0
      "Expected " +
        ( tf.size == 1 ?
          tf[0].expected_string.inspect :
          "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        ) + " at line #{failure_line}, column #{failure_column} " +
        "(byte #{failure_index+1}) #{my_input_excerpt}"
    end

    def num_context_lines; 4 end

    def my_input_excerpt
      0 == failure_index and return "at:\n1: #{input.match(/.*/)[0]}"
      all = input[index...failure_index].split("\n", -1)
      lines = all.slice(-1 * [all.size, num_context_lines].min, all.size)
      nos = failure_line.downto(
        [1, failure_line - num_context_lines + 1].max).to_a.reverse
      w = nos.last.to_s.size # width of greatest line number as string
      "after:\n" <<
        (nos.zip(lines).map{|no, s| ("%#{w}i" % no) + ": #{s}" } * "\n")
    end
  end
end
