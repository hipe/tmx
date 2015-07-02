require 'skylab/headless/core'

module Skylab::Callback

  class CLI  # NOTE "this node in its scope is not related to pub-s.." [#018]

    class << self

      def option
        CLI::Option__
      end
    end

    Home_.lib_.CLI_lib::CLient[ self,
      :three_streams_notify,
      :DSL ]  # don't add DSL till end b.c of it's method_added hook

    def initialize *a
      @opendata = nil ; @param_h = { }
      three_streams_notify( * a )
      super()
    end

    def file_argument y
      y << say do
        "  <file>   file(s) to #{ em '`require`' }d in order"
      end
    end

    def ping
      errstream.puts "hello from callback."
      :'hello_from_callback'
    end

    desc 'visualize a [cb] digraph event stream graph for a particular module'

    option_parser do |o|
      # [#005] - we will leverage synergies below at some later date
      p = @param_h
      p[:default_outfile_name] = 'tmp.dot'
      p[:outfile_name] = p[:default_outfile_name]
      p[:do_open] =
        p[:do_digraph] =
        p[:do_show_backtrace] =
        p[:do_write_files] =
        p[:root_constant] =
        p[:use_force] = false

      o.on '-r <root-const>', "root constant (e.g `Skylab`)" do |x|
        p[:root_constant] = x
      end

      o.on '-d', '--digraph', 'surround output in "digraph{ .. }"' do
        p[:do_digraph] = true
      end

      o.on '--outfile[=<filename>]',
        "write output to <filename> (implies -d) (\"=\" necessary!)",
        "(if no arg provided, filename is \"#{p[:outfile_name]}\")",
        "(requires -F iff output filename is not default name)" do |v|
        p[:do_write_files] = true
        p[:outfile_name] = v if v
        p[:do_digraph] = true
      end

      o.on '-F', '--force', 'necessary to overwrite the non-default file.' do
        p[:use_force] = true
      end

      o.on '--open', "use the `open` command on your os on the#{
        } generated file", "(implies --outfile..)" do
        p[:do_open] = true
        p[:do_write_files] = true
        p[:do_digraph] = true
      end
    end

    desc do |y|
      y << "write the output to stdout by default."
      y << "arguments:"
      file_argument y
      y << "  <module>  show the event stream graph for this module"
      y << '    if not provided (i.e 1 filename), will do something tricky'
    end

    append_syntax '[<module>]'

    def viz file, *additional_file
      if additional_file.length.zero?
        do_guess_mod = true
        modul = false
      else
        modul = additional_file.pop
        do_guess_mod = false
      end
      additional_file.unshift file
      _, o, e = three_streams
      gv = Home_::API::Actions::GraphViz.new program_name, o, e
      gv.absorb_param_h_fully @param_h.merge!(
        files: additional_file, modul: modul,
        do_guess_mod: do_guess_mod )
      x = gv.execute
      usage_and_invite if false == x
      x ? x : ( false == x ? 1 : 0 )
    end

    desc 'fire one off (test factories)'

    option_parser do |o|
      p = @param_h
      p[:do_show_backtrace] = false
    end

    option_parser_class -> do
      CLI.option.parser.fire
    end

    append_syntax(
      '[ -- ( <payload_string> | --name-1 <val-1> [ --n-2 <v2> [..]] ) ]' )

    desc do |o|
      o << "arguments:"
      file_argument o
      o << '  <klass>  fire the event from an object of this class'
      o << ' <stream-name>  fizzle'
    end

    def fire file, klass, stream_symbol
      _, o, e = three_streams
      fi = Home_::API::Actions::Fire.new program_name, o, e
      fi.absorb_param_h_fully @param_h.merge!( files: [ file ], modul: klass,
        opendata: ( @opendata || false ), stream_symbol: stream_symbol.intern )
      x = fi.execute
      usage_and_invite if false == x
      x ? x : ( false == x ? 1 : 0 )
    end

    Client = self  # #hook-out: tmx

  end
end
