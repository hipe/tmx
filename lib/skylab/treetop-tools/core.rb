# encoding: UTF-8
require 'skylab/face/core' # MyPathname
require 'skylab/headless/core'
require 'skylab/meta-hell/core'

module Skylab::TreetopTools

  Headless = ::Skylab::Headless

  extend ::Skylab::MetaHell::Autoloader::Autovivifying

  class Pathname < ::Skylab::Face::MyPathname ; end
  class RuntimeError < ::RuntimeError ; end


  module Grammar end
  class Grammar::Reflection < ::Struct.new(:name, :inpath_f, :outdir_f)
    def inpath ; inpathname.to_s end
    def inpathname ; inpath_f.call end
    NAME_RX = /[A-Z][a-zA-Z0-9_]+/
    SPACE_RX = /[ \t]*(#.*)?\n?/
    def nested_const_names
      # this implementation is a shameless & deferential tribute which, if not
      # obvious at first glance, is intended to symbolize the triumph of
      # the recursive buck stopping somewhere even if it perhaps doesn't
      # need to.  (i.e.: yes i know, and i'm considering it.)
      lines = build_lines_enumerator or return false
      require 'strscan'
      consts = [] ; scn = nil
      lines.each do |line|
        scn ? (scn.string = line) : (scn = ::StringScanner.new line)
        scn.skip SPACE_RX
        scn.eos? and next
        if scn.scan(/module[ \t]+/)
          consts << (scn.scan(NAME_RX) or fail("no: #{scn.rest}"))
          while scn.scan(/::/)
            consts << (scn.scan(NAME_RX) or fail("no: #{scn.rest}"))
          end
        elsif scn.scan(/grammar[ \t]+/)
          consts << (scn.scan(NAME_RX) or fail("no: #{scn.rest}"))
          break
        else
          fail("grammar grammar hack failed: #{scn.rest.inspect}")
        end
        scn.skip SPACE_RX
        scn.eos? or fail("grammar grammar hack failed: #{scn.rest.inspect}")
      end
      consts
    end
    def outpath ; outpathname.to_s end
    def outpathname
      outdir_f.call.join("#{name}.rb")
    end
  protected
    def build_lines_enumerator
      ::Enumerator.new do |y|
        fh = inpath_f.call.open('r') ; s = nil
        y << s while s = fh.gets
        fh.close
      end
    end
  end

  # --*-- @abstraction-candidate: this (in some form) will probably go up
  module DSL end
  module DSL::IO end
  module DSL::Client end
  class DSL::IO::Joystick
    # A Joystick is the interface (and only the interface) to a DSL.
    # A user client that wants to create a DSL could subclass Joystick
    # and use the parameter definer (ahem) DSL to define the (er) DSL with.
    # Joystick records the client request in the `params` member.

    extend Headless::Parameter::Definer::ModuleMethods
    include Headless::Parameter::Definer::InstanceMethods::DelegateToParamsIvar
  protected
    def initialize ; @params = self.class.build_params end
    def self.build_params ; params_class.new end
    def self.build_params_class
      ::Class.new( ::Struct.new(* parameters.all.map(&:name))).class_eval do
        include Headless::Parameter::Definer::InstanceMethods::StructAdapter
        public :known?
        self
      end
    end
    def self.params_class
      const_defined?(:Params) or const_set(:Params, build_params_class)
      self::Params
    end
  end

  # other members: joystick, params, errors_count
  class DSL::Client::Minimal < ::Struct.new(:dsl_f, :events_f)
    # You, the DSL Client, are the one that runs the client (user)'s
    # block around your joystick instance, runs the validation etc,
    # emits any errors, does any normalization, and then comes out at the
    # other end with a `params` structure that holds the client's
    # (semi valid) request

    include Headless::Parameter::Controller::InstanceMethods
    # results in false on validation failure, params struct on success
    def invoke
      self.joystick ||= build_joystick
      dsl_f.call joystick
      set!(nil, joystick.instance_variable_get('@params')) # returns params
    end
  protected
    def absorb! struct
      struct.members.each do |name|
        instance_variable_set("@#{name}", struct[name])
      end
      true
    end
    def build_emitter
      e = Headless::Parameter::Definer.new do
        param :on_error, hook: true, writer: true
        param :on_info,  hook: true, writer: true
      end.new(& events_f)
      e.on_error ||= ->(msg) { fail("Couldn't #{verb} #{noun} -- #{msg}") }
      e.on_info  ||= ->(msg) { $stderr.puts("(⌒▽⌒)☆  #{msg}  ლ(́◉◞౪◟◉‵ლ)") }
      e
    end
    def build_joystick ; joystick_class.new end
    def emitter ; @emitter ||= build_emitter end
    def error msg
      self.errors_count += 1
      emit(:error, msg)
      false
    end
    def errors_count ; @errors_count ||= 0 end
    attr_writer :errors_count
    def emit type, data
      emitter.send("on_#{type}").call data
    end
    def finish!
      @params ||= joystick.instance_variable_get('@params')
      true
    end
    def formal_parameters ; joystick_class.parameters end
    attr_accessor :joystick
    def joystick_class ; self.class::DSL end
    def noun ; 'grammar' end
    attr_reader :params
    def pen ; Headless::IO::Pen::MINIMAL end
    def verb ; 'load' end
  end
  # --*--

  class Parameter < Headless::Parameter::Definition
    param :dir, boolean: true
    param :exist, enum: [:must], accessor: true
    def pathname= _
      super(_)
      :dir == _ and dir!
    end
  end

  class Parser::Load < DSL::Client::Minimal
    class DSL < DSL::IO::Joystick
      def self.parameter_definition_class ; Parameter end
      def self.pathname_class ; Pathname end
      param :enhance_parser_with, dsl: :list
      param :force_overwrite, boolean: true
      param :generated_grammar_dir, dsl: :value, required: true,
        pathname: :dir, exist: :must
      param :root_for_relative_paths, dsl: :value, pathname: :dir
      param :treetop_grammar, dsl: :list, required: true,
        pathname: true, exist: :must
    end

    include Headless::Parameter::Definer::InstanceMethods::IvarsAdapter
    include Headless::Parameter::Bound::InstanceMethods
    attr_reader(* DSL.parameters.all.map(&:name))

    def invoke
      (params = super and absorb!(params)) or return
      # we want to hold on to the string representation of the path exactly
      # as the user provided it before we normalize it
      @grammars = treetop_grammar.each_with_index.map do |pn, i|
        Grammar::Reflection.new(pn.to_s, ->{ treetop_grammar[i] },
                                -> { generated_grammar_dir })
      end
      normalize_and_validate_paths_to(:root_for_relative_paths) or return
      load_or_generate_grammar_files or return
      (kk = grammars.last.nested_const_names) or return
      (kk[kk.length - 1] = "#{kk.last}Parser") &&
      (klass = kk.reduce(::Object) { |m, c| m.const_get(c) }) or return
      a = enhance_parser_with and a.each { |mod| klass = subclass(klass, mod) }
      klass
    end
  protected
    def compiler ; @compiler ||= ::Treetop::Compiler::GrammarCompiler.new end

    def file_utils ; require 'fileutils' ; ::FileUtils end

    attr_reader :grammars

    STACK_RE = %r{\A(?<file>[^:]+):(?<line>\d+)(?::in `(?<method>[^']+)')?\z/}
    def load_or_generate_grammar_files
      summarize grammars
      grammars.each do |g|
        defined?(::Treetop) or requiet('treetop')
        if force_overwrite or ! g.outpathname.exist?
          recompile(g) or return
        end
        begin
          require g.outpathname.bare
        rescue ::NameError => e
          _context = (md = STACK_RE.match e.backtrace[0]) ?
            "in #{ File.basename(md[:file]) }:#{ md[:line] }" :
            "(#{ e.backtrace[0] })"
          raise RuntimeError.new( [e.message, _context].join(' ') )
        end
      end
      true
    end
    def mkdir_safe g
      # don't make any new directories deeper than the amt of dirs in grammar
      parent = g.outpathname.dirname
      g.name.scan(%r</>).size.times{ parent = parent.dirname }
      if parent.directory?
        file_utils.mkdir_p(g.outpathname.dirname.to_s, verbose: true)
        true
      else
        error("directory must exist: #{parent.pretty}")
        false
      end
    end
    def normalize_and_validate_paths_to param_name
      errors_count_before = errors_count
      root_f = ->(bp) do
        root = bound_parameters[param_name]
        ! root.value and return error("#{root.name} must be set in " <<
          "order to support a relative path like #{bp.label}!")
        ! root.value.absolute? and return error("#{root.name} must " <<
          "be an absolute path in order to expand paths like #{bp.label}")
        (root_f = ->(_) { root }).call(nil)
      end
      pathname_params = bound_parameters.where do |param|
        param.known?(:pathname) && param[:pathname]
      end.to_a
      pathname_params.each do |bp|
        bp.value or next # if path value wasn't specified, leave brittany alone
        if ! bp.value.absolute? # expand *all* relative paths
          bp.value = root_f[bp].value.join(bp.value) # sexy and evil
        end
        if bp.value.exist?
          if bp.parameter.dir? and ! bp.value.directory?
            error("#{ bp.label } is not a directory: #{ p.value.pretty }")
          end
        elsif :must == bp.parameter.exist
          error("#{ bp.label } not found: #{bp.value.pretty}")
        end
      end
      errors_count == errors_count_before
    end
    def recompile g
      g.outpathname.dirname.directory? or mkdir_safe(g) or return
      begin
        compiler.compile(g.inpath, g.outpath)
        true
      rescue ::RuntimeError => e
        raise RuntimeError.new("when compiling #{g.name}:\n#{e.message}")
      end
    end
    def requiet lib
      v = $VERBOSE ; $VERBOSE = nil ; require(lib) ; $VERBOSE = v
      true
    end
    def subclass cls, mod
      newcls = ::Class.new(cls)
      cls_modname, cls_basename =
        cls.to_s.match(/\A(?:(.*[^:])::)?([^:]+)\Z/).captures
      newcls.class_eval do
        include mod
        mod.override.each { |meth| alias_method meth, "my_#{meth}" }
      end
      parent_mod = (cls_modname.nil?) ? ::Object :
        cls_modname.split('::').inject(::Object){ |m,n| m.const_get(n) }
      nonum, num = cls_basename.match(/\A(.*[^0-9])([0-9]+)?\Z/).captures
      i = num ? (num.to_i + 1) : 2
      i += 1 while(parent_mod.const_defined?(usename = "#{nonum}#{i}"))
      newconst = parent_mod.const_set(usename, newcls)
      newconst
    end
    def summarize grammars
      exists = []; creates = []
      grammars.each { |g| (g.outpathname.exist? ? exists : creates).push g }
      exists.empty? or emit(:info, "#{force_overwrite ? 'overwrit' : 'us'
        }ing: #{exists.map(&:outpath).join(', ')}")
      creates.empty? or
        emit(:info, "creating: #{creates.map(&:outpath).join(', ')}")
      grammars.empty? and emit(:info, "none.")
      true
    end
  end
end
