module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::Load_The_Test_Files < Plugin_

      # ( was: [#hl-070-002] something about names )

      can :flush_the_test_files do | tr |

        tr.if_transition_is_effected do | o |

          o.on '--require-only',
              "require() each file (but do not require 'r#{}spec/autorun')" do

            @require_only = true
          end
        end
      end

      def do__flush_the_test_files__
        @resources.serr.puts "(pretending to flush the test files)"
        ACHIEVED_
      end

    if false
    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_actions
        action_summaries
        available_options
        default_action
      | )

      services_used(
        [ :em, :ivar ],
        [ :full_name, :proxy ],
        :hot_spec_paths,
        :infostream,
        :run_mode
      )

    end

    def initialize
      @be_verbose = nil
    end

    available_actions [
      [ :req, 0.8333 ],
      [ :run, 0.90 ]
    ]

    action_summaries(
      req: :x,
      run: "(the default action - specifying its name is not necessary)"
    )

    default_action :run, 0.5

    available_options do |o, _|
      o.on '-v', '--verbose', 'things like output filenames' do
        @be_verbose = true
      end

      true  # because we took action
    end

    def req
      _req -> do
        Test_.adapters[ :rspec ].load_core_if_necessary
          # without this, quickie runs the tests.
      end
    end

    def run
      rm = run_mode
      if :cli == rm || :rspec == rm
        _req -> do
          if :cli == rm
            require 'rspec/autorun'  # don't load this till after query ok
          end
        end
      else
        infostream.puts "(doing nothing for runmode \"#{ rm }\".)"
        nil
      end
    end

    def _req before
      cache_a = [ ] ; info = infostream
      res = hot_spec_paths.each do |p|
        cache_a << p
      end
      if false == res
        info.puts "not requiring any files because of this."
        nil
      else
        info = infostream
        before[ ]
        v = @be_verbose
        v or info.write '('
        cache_a.each do |p|
          if v
            info.puts "   #{ @em[ '>>>' ] } #{ p }"
          else
            info.write '.'
          end
          require p.to_s
        end
        if ! v
          info.write " #{ full_name } loaded #{ cache_a.length} spec files)\n\n"
        end
        true  # per [#006]
      end
    end

    def full_name
      "#{ @plugin_parent_services.full_name } #{ local_plugin_moniker }"
    end
    end
    end
  end
end
