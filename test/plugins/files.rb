module Skylab::Test

  module Plugins::Files

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_actions
        action_summaries
        available_options
        conclude
      |
      service_names %i|
        paystream
        hot_spec_paths
      |
    end
  end

  class Plugins::Files::Client

    include CLI::SubClient::InstanceMethods

    def initialize
      @do_pretty = @be_verbose = @did_run = nil
    end

    available_actions [
      [ :files, 0.50 ]
    ]

    action_summaries(
      files: "write to stdout the pretty name of each test file"
    )

    available_options do |o, _|
      o.on '-p', '--pretty', '..filenames. (files)' do
        @do_pretty = true
      end

      o.on '-v', '--verbose', 'this way you can have everything' do
        @be_verbose = true
      end

      true  # when you took action, non-nil
    end

    def files
      paystream, hot_spec_paths = host[ :paystream, :hot_spec_paths ]  # grease

      block = if @do_pretty
        -> spec_path do
          paystream.puts pretty_path( spec_path )
        end
      else
        -> spec_path do
          paystream.puts "#{ spec_path }"
        end
      end
      count = 0
      ok = hot_spec_paths.each do |pn|
        count += 1
        block[ pn ]
      end
      if ok
        @did_run = true
        @last_count = count if @be_verbose
      end
      ok
    end

    conclude do |y|
      if @be_verbose && @did_run
        y << "listed #{ @last_count } spec file(s)"
        true
      end
    end
  end
end
