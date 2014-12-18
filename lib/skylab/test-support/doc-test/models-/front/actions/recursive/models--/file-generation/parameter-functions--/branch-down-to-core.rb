module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          class Parameter_Functions__::Branch_down_to_core < Parameter_Function_

            def execute

              path = @generation.output_path
              dirname = ::File.dirname path
              @basename = ::File.basename path

              stem = @basename.sub GET_RID_OF_THIS_ENDING_RX__, EMPTY_S_

              if @basename == stem
                self._TODO_when_strange_basename  # #todo
              else
                _path = ::File.join( dirname, stem, "core#{ TestSupport_::Init.spec_rb }" )
                @generation.receive_output_path _path
              end
            end
          end

          GET_RID_OF_THIS_ENDING_RX__ = /#{
            ::Regexp.escape TestSupport_::Init.spec_rb }\z/
        end
      end
    end
  end
end
