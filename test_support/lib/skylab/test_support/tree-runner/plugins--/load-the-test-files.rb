module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::Load_The_Test_Files < Plugin_

      can :flush_the_test_files do | tr |

        tr.if_transition_is_effected do | o |

          o.on '--require-only',
              "require() each file, but do not require 'r#{}spec/autorun'" do

            @require_only = true
          end

          o.on '-v', '--verbose', 'output each path right before it is loaded'
        end
      end

      def initialize( * )
        @be_verbose = false
        @require_only = false
        super
      end

      def do__flush_the_test_files__

        if @require_only
          @on_event_selectively.call( :for_plugin, :adapter, :relish ).load_core_if_necessary
            # without this, quickie tries to run the tests.
        else
          require 'rspec/autorun'  # etc
        end

        st = @on_event_selectively.call :for_plugin, :test_file_stream
        st and begin

          serr = @resources.serr
          path = nil
          about_to_load_path = if @be_verbose
            s = nil
            @on_event_selectively.call :info, :expression do | _y |
              s = em '  >>>> '
            end
            -> do
              serr.puts "#{ s }#{ path }"
            end
          else
            -> do
              serr.write DOT___
            end
          end

          begin
            path = st.gets
            path or break
            about_to_load_path[]
            require path
            redo
          end while nil

          ACHIEVED_  # (was historically marked with what is now [#dt-002])
        end
      end

      DOT___ = '.'

    end
  end
end
