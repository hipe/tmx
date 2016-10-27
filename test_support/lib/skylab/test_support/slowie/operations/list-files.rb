module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::List_The_Test_Files < Plugin_

      does :flush_the_test_files do | tr |

        tr.transition_is_effected_by do | o |

          o.on '--list-files', 'write to stdout the path to each test file'

        end

        tr.if_transition_is_effected do | o |

          o.on '-p', '--pretty', 'make the filenames \"pretty\" somehow' do
            @do_pretty = true
          end

          o.on '-v', '--verbose', 'add additional information' do
            @be_verbose = true
          end
        end
      end

      def initialize( * )
        super
        @do_pretty = @be_verbose = false
      end

      def do__flush_the_test_files__

        # ~ the base callbacks

        @receive_path = @resources.sout.method( :puts )

        @at_end = EMPTY_P_

        # ~ mutate the callbacks

        if @be_verbose
          __mutate_callbacks_for_be_verbose
        end

        if @do_pretty
          __mutate_callbacks_for_do_pretty
        end

        # ~ flush output:

        p = @receive_path
        st = @on_event_selectively.call :for_plugin, :test_file_stream
        begin
          path = st.gets
          path or break
          p[ path ]
          redo
        end while nil

        @at_end[]

        ACHIEVED_
      end

      def __mutate_callbacks_for_do_pretty

        @receive_path = -> p do
          -> path do
            path = "(pretty: #{ path })"
            p[ path ]
          end
        end.call @receive_path
        nil
      end

      def __mutate_callbacks_for_be_verbose

        count = 0
        @receive_path = -> p do
          -> path do
            count += 1
            p[ path ]
          end
        end.call @receive_path

        @at_end = -> do
          @resources.serr.puts "(listed #{ count } spec file(s))"
          nil
        end
        nil
      end
    end
  end
end
