module Skylab::SubTree

  class API::Actions::Cov

    class Model_Agents__::Upstream

      Lib_::Properties_stack_frame.call self,
        :globbing, :processor, :initialize,
        :required, :field, :be_verbose,
        :required, :field, :on_event

      class Via_Filesystem < self

        Lib_::Properties_stack_frame.call self,
          :required, :field, :path

        attr_reader :sub_path_array

        def test_dir_pathnames
          ok = is_directory
          ok &&= look_at_current_node_as_test_directory
          ok &&= look_upwards_for_test_directory
          ok && find_with_find
          @result
        end

      private

        def is_directory
          stat_and_stat_e
          if @stat
            when_stat
          else
            send_event No_Such_Directory_[ @stat_e, @path ].to_event
            @result = UNABLE_
          end
        end

        No_Such_Directory_ = Message_.new do |stat_e, path|
          "no such directory: #{ pth path }"
        end

        def stat_and_stat_e
          @stat = ::File.stat @path
          @stat_e = nil
        rescue ::SystemCallError => @stat_e
          @stat = nil
        end

        def when_stat
          if 'directory' == @stat.ftype
            PROCEDE_
          else
            send_event No_Single_File_Support_[ @path ].to_event
            @result = UNABLE_
          end
        end

        No_Single_File_Support_ = Message_.new do |path|
          "single file trees not yet implemented #{
            }(for #{ pth path })"
        end

        def look_at_current_node_as_test_directory
          # if pn looks like foo/bar/test we are done
          @pn = ::Pathname.new @path
          bn_s = @pn.basename.to_path
          if TEST_DIR_NAME_A_.include? bn_s
            @result = Callback_::Scan.via_item @pn
            CEASE_
          else
            PROCEDE_
          end
        end

        def look_upwards_for_test_directory
          if SOFT_RX_ =~ @path  # don't bother looking unless test dir string
            do_look_upwards  # is in path (but note it is not a hard match)
          else
            PROCEDE_
          end
        end

        def do_look_upwards
          pn = ::Pathname.new @path
          seen_a = []
          found = false
          loop do
            bn = pn.basename
            bn_s = bn.to_path
            if HARD_RX_ =~ bn_s  # is the test dir?
              break found = true
            end
            seen_a.push bn_s
            pn_ = pn.dirname
            pn_ == pn and break
            pn = pn_
          end
          if found
            seen_a.reverse!
            @sub_path_array = seen_a
            @result = Callback_::Scan.via_item pn
            CEASE_
          else
            PROCEDE_
          end
        end

        def find_with_find
          @result = SubTree_._lib.system.filesystem.find(
            :path, @path,
            :freeform_query_infix, '-type dir',
            :filenames, TEST_DIR_NAME_A_,
            :on_event_selectively,
              selective_listener_for_find.method( :maybe_receive_event ),
            :as_normal_value, -> command do
              command.to_scan
            end )
          nil
        end

        def selective_listener_for_find
          Callback_::Selective_Listener.methodic self, :prefix, :find
        end

        def send_event ev
          @on_event[ ev ]
        end

      public

        def is_subscribed_to_find_error
          true
        end

        def is_subscribed_to_find_info
          @be_verbose
        end

        def receive_find_info ev
          send_event ev
          nil
        end
      end

      CEASE_ = false  # like "UNABLE_" but semantically not an error

      SOFT_RX_ = %r{(?:#{
        TEST_DIR_NAME_A_.map( & ::Regexp.method( :escape ) ) * '|'
      })}

      HARD_RX_ = %r{ \A #{ SOFT_RX_.source } \z }x

    end
  end
end
