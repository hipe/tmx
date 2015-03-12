module Skylab::GitViz

  module Test_Lib_

    module Mock_Sys

      Models_ = ::Module.new

      class Models_::Command

        def initialize
          @exitstatus = nil
          @stdout_string = nil
          @stderr_string = nil
          @argv = nil
        end

        attr_accessor :exitstatus, :stdout_string, :stderr_string, :argv

        def write_to io

          oa = Mock_Sys_::Output_Adapters_::OGDL_esque.new io, :command

          if @argv
            oa.write @argv, :argv, :string_array
          end

          if @stdout_string
            oa.write @stdout_string, :stdout_string, :string
          end

          if @stderr_string
            oa.write @stderr_string, :stderr_string, :string
          end

          if @exitstatus
            oa.write @exitstatus, :exitstatus, :number
          end

          oa.flush
          NIL_
        end
      end

      Mock_Sys_ = self
    end
  end
end
