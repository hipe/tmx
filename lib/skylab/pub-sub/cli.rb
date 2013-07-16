require 'skylab/headless/core'

# **NOTE** this is decidedly *not* something that is part of the typical
# day-to-day use of pub-sub. This is an experimental one-off-esque report
# for visualizations of graphs. You can happily ignore this little hack!

module Skylab::PubSub

  Headless = ::Skylab::Headless   # be very careful that this only happens in
    # 1 place! this dependency must be downwards-only from this node.

  class CLI

    def initialize *a             # necessary when you have a client and a box
      init_headless_cli_client( * a )
      @param_h = { }
      @opendata = nil
    end

    def file_argument o
      o << "  <file>   file(s) to #{ em '`require`' }d in order"
    end

    Client = self  # #tmx-compat

    extend Headless::CLI::Client::DSL # before below
    extend Headless::CLI::Box::DSL    # after above, to override o.p things

    def ping
      @io_adapter.errstream.puts "hello from pub-sub."
      :'hello_from_pub-sub'
    end

    desc 'visualize a pub-sub event stream graph for a particular module'

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

    desc do |o|
      o << "write the output to stdout by default."
      o << "arguments:"
      file_argument o
      o << "  <module>  show the event stream graph for this module"
      o << '    if not provided (i.e 1 filename), will do something tricky'
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
      o = PubSub::API::Actions::GraphViz.new( program_name, * io_adapter.two )
      o.absorb @param_h.merge!( files: additional_file, modul: modul,
        do_guess_mod: do_guess_mod )
      x = o.execute
      usage_and_invite if false == x
      x ? x : ( false == x ? 1 : 0 )
    end

    desc 'fire one off (test factories)'

    option_parser do |o|
      p = @param_h
      p[:do_show_backtrace] = false
    end

    option_parser_class -> { CLI::Option::Parser::Fire }

    append_syntax(
      '[ -- ( <payload_string> | --name-1 <val-1> [ --n-2 <v2> [..]] ) ]' )

    desc do |o|
      o << "arguments:"
      file_argument o
      o << '  <klass>  fire the event from an object of this class'
      o << ' <stream-name>  fizzle'
    end

    def fire file, klass, stream_name
      o = PubSub::API::Actions::Fire.new( program_name, * io_adapter.two )
      o.absorb @param_h.merge!( files: [ file ], modul: klass,
        opendata: ( @opendata || false ), stream_name: stream_name.intern )
      x = o.execute
      usage_and_invite if false == x
      x ? x : ( false == x ? 1 : 0 )
    end
  end
end
