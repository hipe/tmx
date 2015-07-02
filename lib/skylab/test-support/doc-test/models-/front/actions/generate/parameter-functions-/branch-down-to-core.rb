module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Generate

          class Parameter_Functions_::Branch_down_to_core < Parameter_Function_

            description do | y |

              y << "instead of #{ val 'foo_spec.rb' }, make #{ val 'foo/core_spec.rb' }"

            end

            def execute

              path = @generation.output_path
              dirname = ::File.dirname path
              @basename = ::File.basename path

              stem = @basename.sub GET_RID_OF_THIS_ENDING_RX__, EMPTY_S_

              if @basename == stem
                self._TODO_when_strange_basename  # #todo
              else

                Mutate_string_by_removing_trailing_dashes_[ stem ]

                _path = ::File.join( dirname, stem, "core#{ Home_::Init.spec_rb }" )
                @generation.receive_output_path _path
              end
            end
          end

          GET_RID_OF_THIS_ENDING_RX__ = /#{
            ::Regexp.escape Home_::Init.spec_rb }\z/

      end
    end
  end
end
