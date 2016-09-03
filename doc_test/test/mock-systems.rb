module Skylab::DocTest::TestSupport

  module Mock_Systems

    def self.[] tcc
      tcc.include InstanceMethods___
    end

    module InstanceMethods___

      def mock_system_for_tree_03_gemish__

        o = _mock_system_begin

        _mock_system_find_and_grep_passthru_common o

        __mock_system_git_commands_for_tree_03_gemish o

        o.finish
      end

      def mock_system_that_is_passthru_of_filesystem_related_only__

        o = _mock_system_begin

        _mock_system_find_and_grep_passthru_common o

        o.finish
      end

      def _mock_system_begin
        Home_.lib_.system_lib::Doubles::Stubbed_System::MockSystem.begin
      end

      def _mock_system_find_and_grep_passthru_common o

        _Open3 = the_real_system_

        # ~ the find commands

        o.command_category do |a|
          'find' == a[0]
        end

        o.times 2 do |argv|
          _Open3.popen3( * argv )
        end

        # ~ the grep commands

        o.command_category do |a|
          'grep' == a[0]
        end

        o.times 2 do |argv|
          _Open3.popen3( * argv )
        end
      end

      def __mock_system_git_commands_for_tree_03_gemish o

        o.command_category do |a|
          'git' == a[0]
        end

        o.command_key do |a|
          a.fetch( -2 )  # the index of the local test path in the ARGV
        end

        o.on 'core_speg.ko' do  # first - exists and is not versioned at all
          [ 0, '?? test/core_speg.ko' ]
        end

        o.on 'acerbic_speg.ko' do  # second - exists, has unversioned changes
          [ 0, ' M test/acerbic_speg.ko' ]
        end

        o.on 'berdersic-flersic_speg.ko' do  # third - does not exist at all
          TS_._ASSERT_IS_NEVER_CALLED
        end

        o.on 'cerebus-rex_speg.ko' do  # fourth - exists but has no unversioned changes
          [ 0 ]  # exitstatus 0; result streams are zero bytes long
        end
      end
    end
  end
end
