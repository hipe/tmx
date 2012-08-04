module Skylab::CssConvert::TreetopTools
  CssConvert = ::Skylab::CssConvert
  MyPathname = CssConvert::MyPathname
  class << self
    def load_parser_class &b
      ParserClassLoader.new(&b).load
    end
  end
  class MyRuntimeError < ::RuntimeError
  end
  class Sexpesque < Array
    alias_method :node_name, :first
    class << self
      def build name, *childs
        new([name, *childs])
      end
      alias_method :[], :build
    end
    alias_method :fetch, :[]
    def [] mixed
      mixed.kind_of?(::Symbol) ? super(1)[mixed] : super(mixed)
    end
    def children sym, *syms
      ([sym] + syms).map { |x| fetch(1)[x] }
    end
  end
  class ParserClassLoader < Struct.new(
    :_enhance, :_generated_grammar_dir, :_grammars, :_overwrite, :_root_dir
  )
    include CssConvert::My::Headless::SubClient::InstanceMethods
    def initialize &b
      self._enhance = []
      self._grammars = []
      self._overwrite = false
      yield self
      @request_runtime or fail("be sure to set this")
    end
    def compiler
      @compiler ||= ::Treetop::Compiler::GrammarCompiler.new
    end
    def enhance_parser_with mod
      _enhance.push mod
    end
    def file_utils
      require 'fileutils'
      ::FileUtils
    end
    def force_overwrite!
      self._overwrite = true
    end
    def grammar_module_name_in g
      require 'strscan'
      scn = nil
      mods = []
      gram = nil
      File.open(g.inpath, 'r') do |fh|
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
    def generated_grammar_dir dir
      dir or fail("expecting dir had #{dir.inspect}")
      self._generated_grammar_dir = MyPathname.new(dir)
    end
    def load
      _outdir.directory? or return fail("must exist and be directory: #{_outdir.pretty}")
      load_or_generate_grammar_files
      kk = grammar_module_name_in _grammars.last
      kk[kk.length - 1] = "#{kk.last}Parser"
      k = kk.reduce(::Object) { |m, c| m.const_get(c) }
      _enhance.each { |m| k = subclass(k, m) }
      k
    end
    def load_or_generate_grammar_files
      summarize _grammars
      _grammars.each do |g|
        defined?(::Treetop) or require_treetop
        (_overwrite || ! g.outpath.exist?) and recompile(g)
        begin
          require g.outpath.bare
        rescue ::NameError => e
          raise MyRuntimeError.new( [e.message,
          ( (m = parse_stack_item(e.backtrace.first)) ?
            "in #{File.basename(m[:file])}:#{m[:line]}" :
            "(#{e.backtrace.first})"
          ) ].join(' ') )
        end
      end
      nil
    end
    def require_treetop
      v = $VERBOSE ; $VERBOSE = nil ; require('treetop') ; $VERBOSE = v
    end
    def subclass cls, mod
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
      i = num ? (num.to_i + 1) : 2
      i += 1 while(parent_mod.const_defined?(usename = "#{nonum}#{i}"))
      newconst = parent_mod.const_set(usename, newcls)
      newconst
    end
    def mkdir_safe g
      # don't make any new directories deeper than the amt of dirs in grammar
      parent = g.outpath.dirname
      g.name.scan(%r{/}).size.times{ parent = parent.dirname }
      parent.directory? or return fail("directory must exist: #{parent.pretty}")
      file_utils.mkdir_p(g.outpath.dirname.to_s, verbose: true)
      true
    end
    def _outdir
      @_outdir ||= _root_dir.join((_generated_grammar_dir or fail('no')).to_s)
    end
    def parse_stack_item str
      if md = /\A([^:]+):(\d+)(?::in `([^']+)')?\Z/.match(str)
        {:file => md[1], :line => md[2], :method => md[3] }
      end
    end
    def recompile g
      g.outpath.dirname.directory? or mkdir_safe(g) or return
      begin
        compiler.compile(g.inpath.to_s, g.outpath.to_s)
      rescue ::RuntimeError => e
        raise MyRuntimeError.new("when compiling #{g.name}:\n#{e.message}")
      end
    end
    def root_dir dir
      self._root_dir = MyPathname.new(dir.to_s)
    end
    def summarize gx
      ex = []; cx = []
      gx.each { |g| ( g.outpath.exist? ? ex : cx ).push g.name }
      ex.empty? or  emit(:info, "#{_overwrite ? 'overwrit' : 'us'}ing: #{ex.join(', ')}")
      cx.empty? or  emit(:info, "creating: #{cx.join(', ')}")
      gx.empty? and emit(:info, "none.")
      nil
    end
    def treetop_grammar path
      found = pathname = tries = nil
      search = [ -> { String === path ? MyPathname.new(path) : path },
                 -> { pathname.absolute? ? nil : MyPathname.new(CssConvert.dir.join(pathname).to_s) } ]
      until found or search.empty? or ! (pathname = search.shift.call)
        if pathname.exist? then found = true else (tries ||= []).push(pathname) end
      end
      if found
        _grammars.push  GrammarMeta.new(path, pathname, ->{ _outdir })
      else
        fail("treetop grammar not found: (#{tries.map(&:pretty).join(', ')})")
      end
    end
  end
  class GrammarMeta < Struct.new(:name, :inpath, :outdir)
    def outpath
      outdir.call.join("#{name}.rb")
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
