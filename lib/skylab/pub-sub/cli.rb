require 'skylab/headless/core'

# **NOTE** this is decidedly *not* something that is part of the typical
# day-to-day use of pub-sub. This is an experimental one-off-esque report
# for visualizations of graphs. You can happily ignore this little hack!

module Skylab::PubSub

  Headless = ::Skylab::Headless   # be very careful that this only happens in
    # 1 place! this dependency must be downwards-only from this node.

  class CLI
    extend Headless::CLI::Client::DSL

    desc 'visualize a pub-sub event stream graph for a particular class'

    option_parser do |o|
      # [#005] - we will leverage synergies below at some later date
      @param_h ||= {  }
      @param_h[:default_outfile_name] = 'tmp.dot'
      @param_h[:outfile_name] = @param_h[:default_outfile_name]
      @param_h[:do_open] =
        @param_h[:do_digraph] =
        @param_h[:do_show_backtrace] =
        @param_h[:outfile_is_payload] =
        @param_h[:use_force] = false

      o.on '-d', '--digraph', 'surround output in "digraph{ .. }"' do
        @param_h[:do_digraph] = true
      end

      o.on '--outfile[=<filename>]',
        "write output to <filename> (implies -d) (\"=\" necessary!)",
        "(if no arg provided, filename is \"#{@param_h[:outfile_name]}\")",
        "(requires -F iff output filename is not default name)" do |v|
        @param_h[:outfile_is_payload] = true
        @param_h[:outfile_name] = v if v
        @param_h[:do_digraph] = true
      end

      o.on '-F', '--force', 'necessary to overwrite the non-default file.' do
        @param_h[:use_force] = true
      end

      o.on '--open', "use the `open` command on your os on the#{
        } generated file", "(implies --outfile..)" do
        @param_h[:do_open] = true
        @param_h[:outfile_is_payload] = true
        @param_h[:do_digraph] = true
      end
    end

    desc do |o|
      o << "write the output to stdout by default."
      o << "arguments:"
      o << "  <file>   file(s) to #{ em '`load`' } in order"
      o << "  <klass>  show the event stream graph for this class"
    end

    default_action :viz

    def viz file, *additional_file, klass
      additional_file.unshift file
      o = PubSub::API::Actions::GraphViz.new(
        io_adapter.outstream, io_adapter.errstream )
      o.files, o.klass = additional_file, klass
      @param_h.each { |k, v| o.send "#{ k }=", v }
      x = o.execute
      if false == x
        usage_and_invite
      end
      x ? x : ( false == x ? 1 : 0 )
    end
  end
end
