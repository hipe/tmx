require_relative '../headless/core'

requiet = ->(s) { _ = $VERBOSE ; $VERBOSE = nil ; require(s) ; $VERBOSE = _ }
require 'optparse'
require 'pathname'
require 'strscan'
requiet['treetop']

module Skylab::Flex2Treetop

  VERSION = '0.0.1'
  FIXTURES = {}
  FIXTURES[:fixthix] = 'lib/skylab/flex2treetop/test/fixtures/fixthis.flex'
  FIXTURES[:mini]    = 'lib/skylab/flex2treetop/test/fixtures/mini.flex'
  FIXTURES[:tokens]  = 'lib/skylab/css-convert/css/parser/tokens.flex'

  def self.dir
    @dir ||= ::Pathname.new(::File.expand_path('..', __FILE__))
  end

  Headless = ::Skylab::Headless

  module Request end
  class Request::Runtime < Headless::Request::Runtime::Minimal
    def builder
      @builder ||= TreetopBuilder.new(io_adapter.outstream)
    end
    def translate_name flex_name
      flex_name # @todo prefixes, whatever
    end
  end

  module My end
  module My::Headless end
  class My::Headless::Client
    include Headless::Client::InstanceMethods # get ancestor chain right
    def version
      emit(:payload, "#{program_name} version #{VERSION}")
    end
  protected
    def request_runtime_class ; Request::Runtime end
  end

  module CLI end
  module CLI::Actions end
  module CLI::Actions::Translate end
  class CLI::Actions::Translate::Parameters < ::Hash
    extend Headless::Parameter::Definer::ModuleMethods
    include Headless::Parameter::Definer::InstanceMethods::HashAdapter
    param :case_insensitive, boolean: :case_sensitive, default: true, writer: 1
    param :clear_generated_files, boolean: :dont_clear_generated_files
    param :filesystem_parser_enabled, boolean: true
    param :filesystem_parser_dir, pathname: true, accessor: true
    param :result_state, internal: true, enum: [:exists, :filesystem_touched,
            :modified, :not_found, :parse_failure, :translated,
            :translate_failure, :showed_sexp], accessor: true
    param :show_sexp, boolean: :dont_show_sexp, default: false, writer: true
    param :suppress_normal_output_after_filesystem_parser, boolean: true
    param :verbose, boolean: true, default: true, writer: true
    # -- * --
    # the /^[a-z]/ namespace is off limits to us for method names here
    def _client &block
      @_client.instance_eval(&block)
    end
    def _formal_parameters
      self.class.parameters
    end
    def initialize client
      @_client = client
    end
  end

  module API end
  class API::RuntimeError < Headless::API::RuntimeError ; end

  def API.invoke method, params=nil
    API::Client.new.invoke(method, params)
  end

  module API::Actions end
  module API::Actions::Translate end
  class API::Actions::Translate::Parameters <
    CLI::Actions::Translate::Parameters

    param :force, boolean: true, default: true, writer: true
    param :flexfile, pathname: true, required: true, accessor: true
    param :outfile, pathname: true, required: true, accessor: true
    param :verb, accessor: true, internal: true
  end

  AUTOGENERATED_LINE =
    "# Autogenerated by flex2treetop on {{now}}. Edits may be lost."
  AUTOGENERATED_RE   = /autogenerated by flex2treetop/i

  class API::Client < My::Headless::Client
    include Headless::API::InstanceMethods
    def translate request=nil
      parameter_controller.set!(request) or return
      resolve_io or return params.result_state
      begin
        params.result_state = Translation.new(request_runtime).invoke
      ensure
        io_adapter.outstream.closed? or io_adapter.outstream.close
        io_adapter.instream.closed? or io_adapter.instream.close
      end
      params.result_state
    end
  protected
    def build_io_adapter
      API::IO::Adapter.new
    end
    def build_params
      API::Actions::Translate::Parameters.new(self)
    end
    def program_name ; "Flex to Treetop" end
    def resolve_io
      if ! (p = params).flexfile.exist?
        error("file not found: #{p.flexfile}")
        p.result_state = :not_found
      elsif p.outfile.exist?
        if p.force?
          s = nil ; p.outfile.open('r') { |h| s = h.gets }
          if AUTOGENERATED_RE =~ s
            p.verb = 'overwritinag'
          elsif p.outfile.stat.size.zero?
            emit(:info, "(overwriting empty file: #{p.outfile})")
            p.verb = 'overwriting'
          else
            error("won't overwrite, does not appear generated: #{p.outfile}")
            p.result_state = :modified
          end
        else
          emit(:info, "exists, won't overwrite without force: #{p.outfile}")
          p.result_state = :exists
        end
      else
        p.verb = 'creating'
      end
      if ! p.result_state
        io_adapter.instream = params.flexfile.open('r')
        io_adapter.outstream = params.outfile.open('w')
      end
      ! p.result_state
    end
    def runtime_error_class ; API::RuntimeError end
    def valid_action_names
      infer_valid_action_names_from_public_instance_methods
    end
  end

  module API::IO end
  class API::IO::Pen
    include Headless::API::IO::Pen::InstanceMethods
  end
  class API::IO::Adapter < ::Struct.new(
    :payloads, :errors, :info_stream, :instream, :outstream, :pen
  )
    def initialize
      super([], [], $stderr, nil, nil, API::IO::Pen.new)
    end
    def emit type, mixed
      case type
      when :payload ; payloads << mixed
      when :error   ; errors   << mixed
                    ; info_stream.puts("(api #{type} preview): #{mixed}")
      else          ; info_stream.puts("(api #{type}): #{mixed}")
      end
      nil # undefined
    end
    def errors_count ; errors.length end
  end

  def CLI.new ; CLI::Client.new end # reveal

  class CLI::Client < My::Headless::Client
    include Headless::CLI::InstanceMethods
    def build_option_parser
      o = @option_parser = ::OptionParser.new # set ivar early for banner= below

      o.on('-g=<grammar>', '--grammar=<grammar>',
        "nest treetop output in this grammar declaration",
        "(e.g. \"Mod1::Mod2::Grammar\")."
      ) { |g| params[:grammar] = g }

      o.on('-s', '--sexp',
        "show sexp of parsed flex file.",
        "suppress normal output. (devel)"
      ) { params.show_sexp! } # sic. suppression is with logic

      o.on('--flex-tt',
       'write the flex treetop grammar to stdout.',
       "suppress normal output. (devel)"
      ) { suppress_normal_output!.enqueue!(:grammar) }

      o.on('-t[=<dir>]', '--tempdir[=<dir>]',
        '[write, ]read flex treetop grammar',
        '[from ,] to the filesystem as opposed to in memory. (devel)',
        'multiple times will supress normal output.',
        'use --clear (below) to force a rewrite of the file(s).'
      ) do |v|
        v and params.filesystem_parser_dir = v
        if params.filesystem_parser_enabled?
          params.suppress_normal_output_after_filesystem_parser!
          suppress_normal_output! # a small smell is here
        else
          params.filesystem_parser_enabled!
        end
      end

      o.on('-c', '--clear',
        'if used in conjuction with --tmpdir,',
        'clear any existing parser files first (devel).'
      ) { params.clear_generated_files! }

      o.on('-h', '--help', 'show this message') do
        suppress_normal_output!.enqueue!(:help)
      end
      o.on('-v', '--version', 'show version') do
        suppress_normal_output!.enqueue!(:version)
      end
      o.on('--test', '(shows some visual tests that can be run)') do
        suppress_normal_output!.enqueue!(:show_tests)
      end
      o.banner = usage_line
      o
    end

    def build_params
      CLI::Actions::Translate::Parameters.new(self)
    end

    def default_action ; :translate end

    def grammar
      emit(:payload, TREETOP_GRAMMAR)
    end

    def show_tests
      require 'fileutils'
      pwd = ::Pathname.new(::FileUtils.pwd)
      FIXTURES.each do |k, path|
        _p = ::Skylab::Flex2Treetop.dir.join("../#{path}")
        _p = _p.relative_path_from(pwd)
        emit(:info, "#{program_name} #{_p}")
      end
      true
    end

    def translate flexfile
      unless suppress_normal_output?
        resolve_instream or return
      end
      Translation.new(request_runtime).invoke
    end
  end

  class Translation
    include Headless::SubClient::InstanceMethods
    def instream ; io_adapter.instream end
    def invoke
      p = params
      p.verbose? and emit(:info, "#{p.verb} #{p.outfile} with #{p.flexfile}")
      p.filesystem_parser_enabled? and (use_filesystem or return)
      whole_file = instream.read
      instream.close # ''spot 1''
      io_adapter.outstream.puts autogenerated_line
      result = parser.parse(whole_file)
      if ! result
        error(parser.failure_reason || "Got nil from parse without reason")
        :parse_failure
      elsif p.show_sexp?
        require 'pp'
        ::PP.pp(result.sexp, io_adapter.errstream)
        :showed_sexp
      elsif result.sexp.translate(request_runtime)
        :translated
      else
        :translate_failure
      end
    end
  protected
    def autogenerated_line
      AUTOGENERATED_LINE.gsub(/\{\{((?:(?!\}\}).)+)\}\}/) do
        case $1
        when 'now' ; Time.now.strftime('%Y-%m-%d %I:%M:%S%P %Z')
        end
      end
    end
    def autogenerated_re ; AUTOGENERATED_RE end
    def clear_generated_files
      [f2tt_tt, f2tt_rb].each do |path|
        path.exist? and file_utils.rm(path.to_s, verbose: true)
      end
    end
    attr_reader :f2tt_tt, :f2tt_rb
    def file_utils # future-proofed for hacking
      @file_utils ||= begin
        require 'fileutils'
        extend ::FileUtils
        @fileutils_output = request_runtime.io_adapter.errstream
        @fileutils_label = "(futils:) "
        singleton_class.send(:public, :rm)
        ->{ self }
      end
      @file_utils.call
    end
    def parser
      @parser ||= parser_class.new
    end
    def parser_class
      @parser_class ||= begin
        unless defined?(FlexFileParser)
          ::Treetop.load_from_string TREETOP_GRAMMAR
        end
        c = ::Class.new FlexFileParser
        c.class_eval(&PARSER_EXTLIB)
        c
      end
    end
    def recompile
      a = []
      f2tt_tt.exist? or begin
        bytes = write_grammar_file
        a.push "wrote #{f2tt_tt} (#{bytes} bytes)."
      end
      emit(:info, a.push("writing #{f2tt_rb}.").join(' '))
      ::Treetop::Compiler::GrammarCompiler.
        new.compile(f2tt_tt.to_s, f2tt_rb.to_s)
    end
    def use_filesystem
      (p = params).filesystem_parser_dir ||= (require 'tmpdir' ; ::Dir.tmpdir)
      dirname = p.filesystem_parser_dir # (necessary in its own line)
      dirname.directory? or return error("not a directory: #{dirname}")
      @f2tt_tt = dirname.join('flex-to-treetop.treetop')
      @f2tt_rb = dirname.join('flex-to-treetop.rb')
      p.clear_generated_files? and clear_generated_files
      f2tt_rb.exist? ? emit(:info, "using: #{f2tt_rb}") : recompile
      rb = f2tt_rb.absolute? ? f2tt_rb : f2tt_rb.expand_path
      require rb.to_s.sub(/\.rb\z/, '') # "bare()" externally
      if p.suppress_normal_output_after_filesystem_parser?
        emit(:info, "touched files. nothing more to do.")
        p.result_state = :filesystem_parsers_touched
        false # leave
      else
        true # stay
      end
    end
    def write_grammar_file
      bytes = nil
      f2tt_tt.open('w+') { |fh| bytes = fh.write(TREETOP_GRAMMAR) }
      bytes
    end
  end
end

class Skylab::Flex2Treetop::Sexpesque < Array # class Sexpesque
  class << self
    def add_hook(whenn, &what)
      @hooks ||= Hash.new{ |h,k| h[k] = [] }
      @hooks[whenn].push(what)
    end
    def guess_node_name
      m = to_s.match(/([^:]+)Sexp$/) and
        m[1].gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern
    end
    def hooks_for(whenn)
      instance_variable_defined?('@hooks') ? @hooks[whenn] : []
    end
    def from_syntax_node name, node
      new(name, node).extend SyntaxNodeHaver
    end
    def traditional name, *rest
      new(name, *rest)
    end
    def hashy name, hash
      new(name, hash).extend Hashy
    end
    attr_writer :node_name
    def node_name *a
      a.any? ? (@node_name = a.first) :
      (instance_variable_defined?('@node_name') ? @node_name :
        (@node_name = guess_node_name))
    end
    def list list
      traditional(node_name, *list)
    end
    def terminal!
      add_hook(:post_init){ |me| me.stringify_terminal_syntax_node! }
    end
  end
  def initialize name, *rest
    super [name, *rest]
    self.class.hooks_for(:post_init).each{ |h| h.call(self) }
  end
  def stringify_terminal_syntax_node!
    self[1] = self[1].text_value
    @syntax_node = nil
    class << self
      alias_method :my_text_value, :last
    end
  end
  module SyntaxNodeHaver
    def syntax_node
      instance_variable_defined?('@syntax_node') ? @syntax_node : last
    end
  end
  module Hashy
    class << self
      def extended obj
        class << obj
          alias_method :children, :last
        end
      end
    end
  end
end

module Skylab::Flex2Treetop::CommonNodey
  Sexpesque = ::Skylab::Flex2Treetop::Sexpesque
  def at(str); ats(str).first end
  def ats path
    path = at_compile(path) if path.kind_of?(String)
    here = path.first
    cx = (here == '*') ? elements : (elements[here] ? [elements[here]] : [])
    if path.size > 1 && cx.any?
      child_path = path[1..-1]
      cx = cx.map do |c|
        c.extend(::Skylab::Flex2Treetop::CommonNodey) unless
          c.respond_to?(:ats)
        c.ats(child_path)
      end.flatten
    end
    cx
  end
  def at_compile str
    res = []
    s = ::StringScanner.new(str)
    begin
      if s.scan(/\*/)
        res.push '*'
      elsif s.scan(/\[/)
        d = s.scan(/\d+/) or fail("expecting digit had #{s.rest.inspect}")
        s.scan(/\]/) or fail("expecting ']' had #{s.rest.inspect}")
        res.push d.to_i
      else
        fail("expecting '*' or '[' near #{s.rest.inspect}")
      end
    end until s.eos?
    res
  end
  def sexp_at str
    # (n = at(str)) ? n.sexp : nil
    n = at(str) or return nil
    n.respond_to?(:sexp) and return n.sexp
    n.text_value == '' and return nil
    fail("where is sexp for n")
  end
  def sexps_at str
    ats(str).map(&:sexp)
  end
  def composite_sexp my_name, *children
    with_names = {}
    children.each do |name|
      got = send(name)
      sexp =
        if got.respond_to?(:sexp)
          got.sexp
        else
          fail('why does "got" have no sexp')
        end
      with_names[name] = sexp
    end
    if my_name.kind_of? Class
      my_name.hashy(my_name.node_name, with_names)
    else
      Sexpesque.hashy(my_name, with_names)
    end
  end
  def list_sexp *foos
    foos.compact!
    foos # yeah, that's all this does
  end
  def auto_sexp
    if respond_to?(:sexp_class)
      sexp_class.from_syntax_node(sexp_class.node_name, self)
    elsif ! elements.nil? && elements.index{ |n| n.respond_to?(:sexp) }
      cx = elements.map{ |n| n.respond_to?(:sexp) ? n.sexp : n.text_value }
      ::Skylab::Flex2Treetop::AutoSexp.traditional(guess_node_name, *cx)
    else
      ::Skylab::Flex2Treetop::AutoSexp.traditional(guess_node_name, text_value)
    end
  end
  def guess_node_name
    m = singleton_class.ancestors.first.to_s.match(/([^:0-9]+)\d+$/)
    if m
      m[1].gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern
    else
      fail("what happen")
    end
  end
  def singleton_class
    @sc ||= class << self; self end
  end
end

module Skylab::Flex2Treetop
  class CommonNode < ::Treetop::Runtime::SyntaxNode
    include CommonNodey
  end
  module AutoNodey
    include CommonNodey
    def sexp; auto_sexp end
  end
  class AutoNode < CommonNode
    include AutoNodey
  end
end

module Skylab::Flex2Treetop
  module RuleWriter
  end
  class RuleWriter::Rule < Struct.new(
    :request_runtime, :rule_name, :pattern_like)

    def builder                   ; request_runtime.builder end
    def translate_name(*a)        ; request_runtime.translate_name(*a) end
    def write
      builder.rule_declaration(translate_name(rule_name)) do
        builder.write "".indent(builder.level)
        pattern_like.translate request_runtime
        builder.newline
      end
    end
  end
  module RuleWriter::InstanceMethods
    def write_rule request_runtime
      yield( build = RuleWriter::Rule.new(request_runtime) )
      build.write
    end
  end
  class FileSexp < Sexpesque # :file
    def translate ctx
      nest = [lambda {
        if children[:definitions].any?
          ctx.builder << "# from flex name definitions"
          children[:definitions].each{ |c| c.translate(ctx) }
        end
        if children[:rules].any?
          ctx.builder << "# flex rules"
          children[:rules].each{ |c| c.translate(ctx) }
        end
      }]
      if ctx.params.key?(:grammar)
        parts = ctx.params[:grammar].split('::')
        gname = parts.pop
        nest.push lambda{
          ctx.builder.grammar_declaration(gname, & nest.pop)
        }
        while mod = parts.pop
          nest.push lambda{
            mymod = mod
            lambda {
              ctx.builder.module_declaration(mymod, & nest.pop)
            }
          }.call
        end
      end
      nest.pop.call
    end
  end
  class StartDeclarationSexp < Sexpesque # :start_declaration
    def translate ctx
      case children[:declaration_value]
      when 'case-insensitive' ; ctx.params.case_insensitive!
      else
        ctx.builder <<
          "# declaration ignored: #{children[:declaration_value].inspect}"
      end
    end
  end
  class ExplicitRangeSexp < Sexpesque # :explicit_range
    class << self
      def bounded min, max
        min == '0' ? new('..', max) : new(min, '..', max)
      end
      def unbounded min
        new min, '..'
      end
      def exactly int
        new int
      end
    end
    def initialize *parts
      @parts = parts
    end
    def translate ctx
      ctx.builder.write " #{@parts.join('')}"
    end
  end
  class NameDefinitionSexp < Sexpesque # :name_definition
    include RuleWriter::InstanceMethods
    def translate ctx
      write_rule(ctx) do |m|
        m.rule_name = children[:name_definition_name]
        m.pattern_like = children[:name_definition_definition]
      end
    end
  end
  class RuleSexp < Sexpesque # :rule
    include RuleWriter::InstanceMethods

    # this is pure hacksville to deduce meaning from actions as they are
    # usually expressed in the w3c specs with flex files -- which is always
    # just to return the constant corresponding to the token
    def translate ctx
      action_string = children[:action].my_text_value
      /\A\{(.+)\}\Z/ =~ action_string and action_string = $1
      if md = /\Areturn ([a-zA-Z_]+);\Z/.match(action_string)
        from_constant(ctx, md[1])
      elsif md = %r{\A/\*([a-zA-Z0-9 ]+)\*/\Z}.match(action_string)
        from_constant(ctx, md[1].gsub(' ','_')) # extreme hack!
      else
        ctx.io_adapter.emit(:info,
          "notice: Can't deduce a treetop rule name from: " <<
          "#{action_string.inspect}  Skipping."
        )
        nil
      end
    end
    def from_constant ctx, const
      write_rule(ctx) do |m|
        m.rule_name = const
        m.pattern_like = children[:pattern]
      end
    end
  end
  class PatternChoiceSexp < Sexpesque # :pattern_choice
    def translate ctx
      (1..(last = size-1)).each do |idx|
        self[idx].translate(ctx)
        ctx.builder.write(' / ') if idx != last
      end
    end
  end
  class PatternSequenceSexp < Sexpesque # :pattern_sequence
    def translate ctx
      (1..(last = size-1)).each do |idx|
        self[idx].translate(ctx)
        ctx.builder.write(' ') if idx != last
      end
    end
  end
  class PatternPartSexp < Sexpesque # :pattern_part
    def translate ctx
      self[1].translate(ctx)
      self[2] and self[2][:range].translate(ctx)
    end
  end
  class UseDefinitionSexp < Sexpesque # :use_definition
    def translate ctx
      ctx.builder.write ctx.translate_name(self[1])
    end
  end
  class LiteralCharsSexp < Sexpesque # :literal_chars
    terminal!
    def translate ctx
      ctx.builder.write self[1].inspect # careful! put lit chars in dbl "'s
    end
  end
  class CharClassSexp < Sexpesque # :char_class
    terminal! # no guarantee this will stay this way!
    def translate ctx
      ctx.builder.write( ctx.params.case_insensitive? ?
        case_insensitive_hack(my_text_value) : my_text_value )
    end
    def case_insensitive_hack txt
      s = StringScanner.new(txt)
      out = ''
      while found = s.scan_until(/[a-z]-[a-z]|[A-Z]-[A-Z]/)
        repl = (/[a-z]/ =~ s.matched) ? s.matched.upcase : s.matched.downcase
        s.scan(/#{repl}/) # whether or not it's there scan over it. careful!
        out.concat("#{found}#{repl}")
      end
      "#{out}#{s.rest}"
    end
  end
  class HexSexp < Sexpesque # :hex
    terminal!
    def translate ctx
      ctx.builder.write "OHAI_HEX_SEXP"
    end
  end
  class OctalSexp < Sexpesque # :octal
    terminal!
    def translate ctx
      ctx.builder.write "OHAI_OCTAL_SEXP"
    end
  end
  class AsciiNullSexp < Sexpesque # :ascii_null
    terminal!
    def translate ctx
      ctx.builder.write "OHAI_NULL_SEXP"
    end
  end
  class BackslashOtherSexp < Sexpesque # :backslash_other
    terminal!
    def translate ctx
      # byte per byte output the thing exactly as it is, but wrapped in quotes
      ctx.builder.write "\"#{my_text_value}\""
    end
  end
  class ActionSexp < Sexpesque # :action
    terminal! # these are hacked, not used conventionally
  end
  class AutoSexp < Sexpesque
    def translate ctx
      self[1..size-1].each do |c|
        if c.respond_to?(:translate)
          c.translate(ctx)
        else
          ctx.builder.write c
        end
      end
    end
  end
end

module Skylab::Flex2Treetop
  class ProgressiveOutputAdapter < ::Struct.new(:out)
    def <<(*a)
      out.write(*a)
      self
    end
  end
  class TreetopBuilder < ::Treetop::Compiler::RubyBuilder
    def initialize outstream
      super() # nathan sobo reasonably sets @ruby to a ::String here, (@hack?)
      @ruby = ProgressiveOutputAdapter.new(outstream) # but we need this
    end
    def rule_declaration name, &block
      self << "rule #{name}"
      indented(&block)
      self << "end"
    end
    def grammar_declaration(name, &block)
      self << "grammar #{name}"
      indented(&block)
      self << "end"
    end
    def write *a
      @ruby.<<(*a)
    end
  end
end


Skylab::Flex2Treetop::PARSER_EXTLIB = lambda do |_|
  # CompiledParser#failure_reason overridden for less context
  def failure_reason
    return nil unless (tf = terminal_failures) && tf.size > 0
    "Expected " +
      ( tf.size == 1 ?
        tf[0].expected_string.inspect :
        "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
      ) + " at line #{failure_line}, column #{failure_column} " +
      "(byte #{failure_index+1}) after#{my_input_excerpt}"
  end

  def num_lines_ctx; 4 end

  def my_input_excerpt
    num = num_lines_ctx
    slicey = input[index...failure_index]
    all_lines = slicey.split("\n", -1)
    lines = all_lines.slice(-1 * [all_lines.size, num].min, all_lines.size)
    nums = failure_line.downto(
      [1, failure_line - num + 1].max).to_a.reverse
    w = nums.last.to_s.size # greatest line no as string, how wide?
    ":\n" + nums.zip(lines).map do |no, line|
      ("%#{w}i" % no) + ": #{line}"
    end.join("\n")
  end
end

Skylab::Flex2Treetop::TREETOP_GRAMMAR = <<'GRAMMAR'
# The 'pattern' rule below is a subset of the grammar grammar described at
#   http://flex.sourceforge.net/manual/Patterns.html.
#   Note that not all constructs are supported, only those necessary
#   to parse the target flex input files for this project.

module Skylab
module Flex2Treetop
grammar FlexFile
  rule file
    definitions spacey* '%%' spacey* rules spacey*  <CommonNode>
    { def sexp; composite_sexp FileSexp, :definitions, :rules end }
  end
  rule definitions
    spacey*  ( definition_declaration (decl_sep definition_declaration)*  )?
    <CommonNode> {
      def sexp
        list_sexp(sexp_at('[1][0]'), * sexps_at('[1][1]*[1]'))
      end
    }
  end
  rule definition_declaration
    name_definition / start_declaration
  end
  rule name_definition
    name_definition_name [ \t]+ name_definition_definition
    <CommonNode> {
      def sexp
        composite_sexp(
          NameDefinitionSexp, :name_definition_name,
            :name_definition_definition
        )
      end
    }
  end
  rule name_definition_name
    [A-Za-z_] [-a-zA-Z0-9_]* {
      def sexp
        text_value
      end
    }
  end
  rule name_definition_definition
    pattern
  end
  rule start_declaration
    '%' 'option' [ \t]+ 'case-insensitive'
     <CommonNode> {
      def sexp
        StartDeclarationSexp.hashy( :start_declaration,
          :declaration_type  => 'option',
          :declaration_value => 'case-insensitive'
        )
      end
    }
  end
  rule rules
    rool (decl_sep rool)* <CommonNode> {
      def sexp
        list_sexp(sexp_at('[0]'), *sexps_at('[1]*[1]'))
      end
    }
  end
  rule rool
    pattern [ \t]+ action <CommonNode> {
      def sexp
        composite_sexp(RuleSexp, :pattern, :action)
      end
    }
  end
  rule pattern
    pattern_part pattern_part* ( '|' pattern )* <CommonNode> {
      def sexp
        seq = list_sexp(sexp_at('[0]'), * sexps_at('[1]*'))
        choice = sexps_at('[2]*[1]')
        seq_or_pat = seq.size == 1 ? seq.first : PatternSequenceSexp.list(seq)
        if choice.any?
          PatternChoiceSexp.list( [seq_or_pat] + choice )
        else
          seq_or_pat
        end
      end
    }
  end
  rule pattern_part
    ( character_class / string / use_definition / backslashes /
        dot / literal_chars / parenthesized_group ) range?
    <CommonNode> {
      def sexp
        els = [sexp_at('[0]')]
        range = sexp_at('[1]') and els.push(:range => range)
        PatternPartSexp.traditional(:pattern_part, *els)
      end
    }
  end
  rule parenthesized_group
    '(' pattern ')' <AutoNode> { }
  end
  rule character_class
    '[' ( '\]' / !']' . )* ']' <AutoNode> {
      def sexp_class; CharClassSexp end
    }
  end
  rule string
    '"' (!'"' . / '\"')* '"' <AutoNode> { }
  end
  rule use_definition
    '{' name_definition_name '}' <CommonNode> {
      def sexp
        UseDefinitionSexp.traditional(:use_definition, elements[1].text_value)
      end
    }
  end
  rule backslashes
    hex / octal / null / backslash_other
  end
  rule hex
    '\\x' [0-9A-Za-z]+ <AutoNode> { def sexp_class; HexSexp end }
  end
  rule octal
    '\\' [1-9] [0-9]* <AutoNode> { def sexp_class; OctalSexp end }
  end
  rule null
    '\\0' <AutoNode> { def sexp_class; AsciiNullSexp end }
  end
  rule backslash_other
    '\\' [^ \t\n\r\f] <AutoNode> { def sexp_class; BackslashOtherSexp end }
  end
  rule action
    [^\n]+ <AutoNode> { def sexp_class; ActionSexp end }
  end
  rule dot
    '.' <AutoNode> { }
  end
  rule literal_chars
    [^\\|/\[\](){} \t\n\r\f'"]+ <AutoNode> {def sexp_class; LiteralCharsSexp end }
  end
  rule range
    shorthand_range / explicit_range
  end
  rule shorthand_range
    ( '*' / '+' / '?' ) <AutoNodey> { }
  end
  rule explicit_range
    '{' [0-9]+ ( ',' [0-9]* )? '}' <CommonNode> {
      def sexp
        if elements[2].elements.nil?
          ExplicitRangeSexp.exactly(elements[1].text_value)
        elsif "," == elements[2].text_value
          ExplicitRangeSexp.unbounded(elements[1].text_value)
        else
          ExplicitRangeSexp.bounded(elements[1].text_value,
            elements[2].elements[1].text_value
          )
        end
      end
    }
  end
  rule comment
    '/*' ( [^*] / '*' !'/' )* '*/' <AutoNode> {
      def sexp_class; CommentSexp end
    }
  end
  rule spacey
    comment / [ \t\n\f\r]
  end
  rule decl_sep
    ( [ \t] / comment )* newline spacey*
  end
  # http://en.wikipedia.org/wiki/Newline (near OSX)
  rule newline
    "\n" / "\r\n"
  end
end
end
end
GRAMMAR
