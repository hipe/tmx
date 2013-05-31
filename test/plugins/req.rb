module Skylab::Test

  module Plugins::Req

    # `Req` plugin. 'req' is short for 'require', and this ugly name will
    # stick until [#hl-070-002] we design something better.

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_actions
        action_summaries
        available_options
        default_action
      |

      service_names %i|
        infostream
        full_name
        run_mode
        hot_spec_paths
      |
    end
  end

  class Plugins::Req::Client

    include CLI::SubClient::InstanceMethods

    def initialize
      @be_verbose = nil
    end

    available_actions [
      [ :req, 0.8333 ],
      [ :run, 0.90 ]
    ]

    action_summaries(
      req: "require() each file (but do not require 'rspec/autorun')",
      run: "(the default action - specifying its name is not necessary)"
    )

    default_action [ :run, 0.5 ]

    available_options do |o, _|
      o.on '-v', '--verbose', 'things like output filenames' do
        @be_verbose = true
      end

      true  # because we took action
    end

    def req
      _req -> do
        MetaHell::FUN.require_quietly[ 'rspec' ] unless defined? ::RSpec
          # without this, quickie runs the tests.
      end, -> { }
    end

    def run
      rm = host.run_mode
      if :cli == rm || :rspec == rm
        _req -> do
          if :cli == rm
            require 'rspec/autorun'  # don't load this till after query ok
          end
        end, -> { }
      else
        host.infostream.puts "(doing nothing for runmode \"#{ rm }\".)"
        nil
      end
    end

    def _req before, after
      cache_a = [ ]
      res = host.hot_spec_paths.each do |p|
        cache_a << p
      end
      if false == res
        host.infostream.puts "not requiring any files because of this."
        nil
      else
        info = host.infostream
        before[ ]
        v = @be_verbose
        v or info.write '('
        cache_a.each do |p|
          if v
            info.puts "   #{ em '>>>' } #{ p }"
          else
            info.write '.'
          end
          require p.to_s
        end
        if ! v
          info.write " #{ full_name } loaded #{ cache_a.length} spec files)\n\n"
        end
        after[ ]
      end
    end
    protected :_req

    def full_name
      "#{ host.full_name } #{ plugin_slug }"
    end
    protected :full_name
  end
end
