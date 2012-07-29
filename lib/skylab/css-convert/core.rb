require_relative '..'
require 'skylab/face/core'
require 'skylab/meta-hell/core'

module Skylab::CssConvert
  extend ::Skylab::MetaHell::Autoloader::Autovivifying

  CssConvert = self
  InterfaceReflector && nil # load
  MyPathname = ::Skylab::Face::MyPathname

  class Core
    def self.build_interface
      InterfaceReflector::RequestParser.new do |o|
        o.on('-f', '--force', 'overwrite existing generated grammars')
        o.on('-d', '--dump={d|c}',
          '(debugging) Show sexp of directives (d) or css (c).',
          'More than once will supress normal output (e.g. "-dd -dd").')
        o.on('-v', '--version', 'Display version information.')
        o.on('-h', '--help',    'Display help screen.'        )
        o.arg('<directives-file>', 'A file with directives in it.')
      end
    end
    def default_action
      :convert
    end
    def defaults!
      params[:tmpdir_relative] = '../../../tmp'
      true
    end
    def on_force
      params[:force_overwrite] = true
    end
    DUMPABLE = {
      'directives' => -> {
        params[ params.key?(:dump_directives) ? :dump_directives_and_exit : :dump_directives ] = true
      },
      'css' => -> {
        params[ params.key?(:dump_css) ? :dump_css_and_exit : :dump_css ] = true
      }
    }
    def on_dump char
      m = /\A#{Regexp.escape char}/
      found = DUMPABLE.keys.detect { |str| m =~ str }
      found or return error(
        "need one of (#{DUMPABLE.keys.map(&:inspect).join(', ')}), not: #{char.inspect}")
      instance_exec(& DUMPABLE[found])
      true
    end
    def convert
      request_runtime or return # establish defaults and whatever
      sexp = parse_directives or return sexp
      if dump_directives?
        require 'pp'
        ::PP.pp(sexp, request_runtime.output_adapter.standard_err_stream)
        dump_directives_and_exit? and return
      end
      CssConvert::DirectivesRunner.new(request_runtime).run(sexp)
    end
    def parse_directives_in_file *a
      fail("reimplement me")
    end
    def parse_directives
      ok = CssConvert::DirectivesParser.new(request_runtime).parse_file(directives_file)
      # rescue CssConvert::DirectivesParser::RuntimeError, TreetopTools::RuntimeError => e
      #   error("#{style('error: ', :error)}#{e.message}")
      ok
    end
    def version_string
      ::Skylab::CssConvert::VERSION
    end
    # parameter getters, parsers and normalizers:
    def directives_file
      params[:directives_file] = MyPathname.new(params[:directives_file]) if String === params[:directives_file]
      params[:directives_file]
    end
    def dump_directives?
      params[:dump_directives]
    end
    def dump_directives_and_exit?
      params[:dump_directives_and_exit]
    end
  end
end
