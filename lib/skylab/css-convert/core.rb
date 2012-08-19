require_relative '..'
require 'skylab/face/core' # MyPathname
require 'skylab/meta-hell/core'
require 'skylab/headless/core'
require 'optparse'

module Skylab::CssConvert
  extend ::Skylab::MetaHell::Autoloader::Autovivifying
  CssConvert = self
  Headless = ::Skylab::Headless
  MyPathname = ::Skylab::Face::MyPathname
  module My
    module Headless
      module SubClient
        module InstanceMethods
          include ::Skylab::Headless::SubClient::InstanceMethods
        end
      end
    end
  end

  class My::Headless::Params < ::Hash
    extend Headless::Parameter::Definer::ModuleMethods
    include Headless::Parameter::Definer::InstanceMethods::HashAdapter
    param :directives_file, pathname: true, writer: true do
      desc 'A file with directives in it.' # (not used yet)
    end
    param :dump_css, boolean: true
    param :dump_css_and_exit, boolean: true
    param :dump_directives, boolean: true
    param :dump_directives_and_exit, boolean: true
    param :force_overwrite, boolean: true
    param :tmpdir_relative, default: '../../../tmp', accessor: true
  end

  class My::Headless::Client
    include Headless::Client::InstanceMethods
    def version
      emit(:payload, "#{program_name} #{CssConvert::VERSION}") or true
    end
  protected
    def formal_parameters ; params_class.parameters end
    def params_class ; My::Headless::Params end
  end

  module CLI
    def self.new ; CLI::Client.new end
  end

  class CLI::Client < My::Headless::Client
    include Headless::CLI::InstanceMethods
    def convert directives_file=nil
      parameter_controller.set! && (i = resolve_instream) &&
      (d = CssConvert::Directive::Parser.new(request_runtime).parse_stream i) &&
      dump_directives(d) &&
      CssConvert::Directive::Runner.new(request_runtime).invoke(d) &&
      exit_status_for(:ok) or exit_status_for(:error)
    end
  protected
    def build_option_parser
      o = @option_parser = ::OptionParser.new # set ivar early for banner= below
      o.on('-f', '--force', 'overwrite existing generated grammars') do
        params.force_overwrite!
      end
      o.on('-d', '--dump={d|c}',
        '(debugging) Show sexp of directives (d) or css (c).',
        'More than once will supress normal output (e.g. "-dd -dd").') do |v|
        enqueue! ->{ dump_this v }
      end
      o.on('-t', '--test[=name]', 'list available visual tests. (devel)') do |v|
        enqueue!( v ? -> { test v } : :test )
      end
      o.on('-v', '--version', 'show version') { enqueue! :version }
      o.banner = usage_line
      o
    end
    def default_action ; :convert end
    DUMPABLE = {
      'directives' => -> {
        p.dump_directives? ? p.dump_directives_and_exit! : p.dump_directives!
      },
      'css' => -> { p.dump_css? ? p.dump_css_and_exit! : p.dump_css!  }
    }
    def dump_this str
      re = /\A#{Regexp.escape str}/
      found = DUMPABLE.keys.detect { |s| re =~ s } or return(
        usage("need one of (#{DUMPABLE.keys.map(&:inspect).join(', ')}) " <<
          "not: #{str.inspect}"))
      instance_exec(& DUMPABLE[found])
      queue.last == :convert or enqueue!(:convert) # etc
      true
    end
    def dump_directives sexp
      params.dump_directives? or return true
      require 'pp'
      ::PP.pp(sexp, request_runtime.io_adapter.errstream)
      params.dump_directives_and_exit? and return
      true
    end
    def exit_status_for sym
      :ok == sym ? 0 : -1
    end
    def io_adapter_class ; CLI::IO::Adapter end
    alias_method :p, :params
    def pen_class ; CLI::IO::Pen end
  end
  require 'skylab/pub-sub/core'
  module CLI::IO end
  class CLI::IO::Pen
    include Headless::CLI::IO::Pen::InstanceMethods
    def em s ; stylize(s, :strong, :cyan) end
  end
  class CLI::IO::Adapter < ::Struct.new(:instream, :outstream, :errstream, :pen,
                                       :errors_count)
    extend ::Skylab::PubSub::Emitter
    emits :error, :help, :info, :invite, :payload, :usage
    def initialize instream, outstream, errstream, pen
      super(instream, outstream, errstream, pen, 0)
      on_error do |e|
        self.errors_count += 1
        self.errstream.puts("#{pen.em('nope:')} #{e}")
      end
      on_help     { |e| self.errstream.puts e }
      on_info     { |e| self.errstream.puts e }
      on_invite   { |e| self.errstream.puts e }
      on_payload  { |e| self.outstream.puts e }
      on_usage    { |e| self.errstream.puts e }
    end
  end
  module CLI::VisualTest end
  module CLI::VisualTest::InstanceMethods
  protected
    def color_test _
      pen = io_adapter.pen ; width = 50
      (colors = (pen.class::MAP.keys - [:strong])).each do |c|
        [[c], [:strong, c]].each do |a|
          s = "would you like some " <<
            "#{pen.stylize(a.map(&:to_s).join(' '), *a)} with that?"
          u = pen.unstylize(s)
          fill = ' ' * [width - u.length, 0].max
          emit(:payload, "#{fill}#{s} - #{u}")
        end
      end
      true
    end
    def errors_count ; io_adapter.errors.count end
    def fixture test
      require 'fileutils'
      _pwd = ::Pathname.new(FileUtils.pwd)
      _basename = "#{test.name}-#{test.value}"
      fixture_path = FIXTURES_DIR.join(_basename).relative_path_from(_pwd)
      _try = "#{program_name} #{fixture_path}"
      emit(:info, "#{em 'try running this:'} #{_try}")
    end
    def test name=nil
      if name
        r = /\A#{::Regexp.escape(name)}/
        list = VISUAL_TESTS.select { |t| r.match t.name }
      end
      if ! name or list.length > 1
        fmt = '  %16s  -  %s'
        (list || VISUAL_TESTS).each {|o|emit(:payload, fmt % o.values_at(0..1))}
      elsif list.empty?
        emit(:error, "no such test #{name.inspect}")
        invite
      else
        test = list.first
        send(test.method, test)
      end
    end
  end
  class CLI::Client
    include CLI::VisualTest::InstanceMethods
  end
  FIXTURES_DIR = CssConvert.dir.join('test/fixtures')
  VISUAL_TESTS = o = []
  test = ::Struct.new(:name, :value, :method)
  o << test.new('color test', 'see what the CLI colors look like.', :color_test)
  o << test.new('001', 'platonic-ideal.txt', :fixture)
  o << test.new('002', 'minitessimal.txt', :fixture)
end
