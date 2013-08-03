module ::Skylab::TestSupport

  module Regret

    Get_SUT_command_a_method_ = -> do  # this is not meant to be autoloaded..
      ts = self.class::SUT_TEST_SUPPORT_MODULE_HANDLE_
      ts.get_command_parts_for_system_under_test_notify
    end

    module AnchorModuleMethods

      # this seems like it should be easy .. what is so complicated about it?

      def get_command_parts_for_system_under_test_notify
        pts = get_any_command_parts_for_system_under_test_notify
        pts or raise topless_errmsg( "set top SUT command#{
          }#{ " in parent or" if parent_anchor_module }" )
      end

      def get_any_command_parts_for_system_under_test_notify
        setting = any_sut_setting
        if setting && ! setting.is_root
          pam = parent_anchor_module
          ppts = pam && pam.get_any_command_parts_for_system_under_test_notify
        end
        if setting
          mypts = case setting.mode
          when :value ; setting.value
          when :block ; setting.value[ a = [ ] ] ; a
          else        ; fail 'no'
          end
        end
        if ppts
          mypts and ppts.concat mypts
          ppts
        elsif mypts
          setting.is_root or raise topless_errmsg( "set (not add) a ROOT #{
            }SUT command in parent or" )
          :value == setting.mode ? mypts.dup : mypts
        end
      end

    private

      remove_method :set_command_parts_for_system_under_test
      def set_command_parts_for_system_under_test * parts, &block  # IMPORTANT name
        setting = Setting_.new
        setting.is_root = true
        build_and_accept_sut_cmd_pts setting, parts, block
        nil
      end

      remove_method :add_command_parts_for_system_under_test
      def add_command_parts_for_system_under_test * parts, &block  # IMPORTANT name
        build_and_accept_sut_cmd_pts Setting_.new, parts, block
        nil
      end

      def any_sut_setting
        if const_defined? :SUT_CMD_SETTING_, false
          self::SUT_CMD_SETTING_
        end
      end

      Setting_ = ::Struct.new :is_root, :mode, :value

      def build_and_accept_sut_cmd_pts setting, parts, block
        const_defined? :SUT_CMD_SETTING_, false and fail "is write once."
        if parts.length.nonzero?
          block and fail 'no'
          setting.mode = :value
          setting.value = parts.freeze
        else
          block.respond_to? :call or fail "expected callable - #{ block.class }"
          setting.mode = :block
          setting.value = block
        end
        const_set :SUT_CMD_SETTING_, setting
        nil
      end
    end
    module Extensions_
      module SUT_Command_
        def self.load ; end
      end
    end
  end
end
