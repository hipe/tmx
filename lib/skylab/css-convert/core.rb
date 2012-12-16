require_relative '..'
require 'skylab/headless/core'
require 'optparse'

module Skylab::CssConvert
  extend ::Skylab::MetaHell::Autoloader::Autovivifying

  CssConvert = self
  Headless = ::Skylab::Headless
  Inflection = ::Skylab::Autoloader::Inflection

  module Core
    # a namespace to hold modality-agnositc stuff
  end


  module Core::SubClient
  end


  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods

    def escape_path x
      request_client.escape_path x
    end
  end


  class Core::Params < ::Hash
    extend Headless::Parameter::Definer

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


  module Core::Client
    # even though there is only one modality for now, we put non-CLI
    # specific things here just for clarity
  end


  module Core::Client::InstanceMethods
    include Core::SubClient::InstanceMethods
    include Headless::Parameter::Controller::InstanceMethods

  protected

    def version
      emit :payload, "#{ program_name } #{ CssConvert::VERSION }"
      true
    end
  end

  module CLI
    def self.new
      CLI::Client.new
    end
  end

  class CLI::Client
    include Headless::CLI::Client::InstanceMethods
    include Core::Client::InstanceMethods

    def convert directives_file=nil
      result = :error
      begin
        set! or break
        resolve_instream or break
        p = CssConvert::Directive::Parser.new self
        d = p.parse_stream( io_adapter.instream ) or break
        if ! dump_directives d
          result = :ok
          break
        end
        r = CssConvert::Directive::Runner.new self
        r.invoke d or break
        result = :ok
      end while false
      if :error == result
        emit :help, usage_line
        emit :help, invite_line
      end
      exit_status_for result
    end

  protected

    def actual_parameters
      @actual_parameters ||= formal_parameters_class.new
    end

    def build_option_parser
      o = ::OptionParser.new
      o.on('-f', '--force', 'overwrite existing generated grammars') do
        actual_parameters.force_overwrite!
      end
      o.on('-d', '--dump={d|c}',
        '(debugging) Show sexp of directives (d) or css (c).',
        'More than once will supress normal output (e.g. "-dd -dd").') do |v|
        enqueue! ->{ dump_this v }
      end
      o.on('-t', '--test[=name]', 'list available visual tests. (devel)') do |v|
        enqueue!( v ? -> { test v } : :test )
      end
      o.on('-h', '--help', 'this screen') { enqueue! :help } # hehe comment out
      o.on('-v', '--version', 'show version') { enqueue! :version }
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
      re = /\A#{ ::Regexp.escape str }/
      found = DUMPABLE.keys.detect { |s| re =~ s } or return(
        usage("need one of (#{DUMPABLE.keys.map(&:inspect).join(', ')}) " <<
          "not: #{str.inspect}"))
      instance_exec(& DUMPABLE[found])
      queue.last == :convert or enqueue!(:convert) # etc
      true
    end

    def dump_directives sexp
      keep_going = true
      if actual_parameters.dump_directives?
        require 'pp'              # possible future fun with [#tm-043] svc
        ::PP.pp sexp, request_client.io_adapter.errstream
        keep_going = ! actual_parameters.dump_directives_and_exit?
      end
      keep_going
    end

    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path

    def exit_status_for sym
      :ok == sym ? 0 : -1
    end

    def formal_parameters_class
      Core::Params
    end

    def pen_class
      CLI::Pen # our own pen, just as a fun p.o.c.
    end
  end


  module CLI::IO
  end


  class CLI::Pen
    include Headless::CLI::Pen::InstanceMethods
    def em s
      stylize s, :strong, :cyan
    end
  end


  module CLI::VisualTest
  end


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

    def fixture test
      require 'fileutils' # #[tm-042] as service
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
        emit :error, "no such test #{name.inspect}"
        emit :info, invite_line
      else
        test = list.first
        send test.method, test
      end
    end
  end

  class CLI::Client
    include CLI::VisualTest::InstanceMethods
  end

  FIXTURES_DIR = CssConvert.dir_pathname.join('test/fixtures')
  VISUAL_TESTS = o = []
  test = ::Struct.new(:name, :value, :method)
  o << test.new('color test', 'see what the CLI colors look like.', :color_test)
  o << test.new('001', 'platonic-ideal.txt', :fixture)
  o << test.new('002', 'minitessimal.txt', :fixture)
end
