module Skylab::System::TestSupport

  Filesystem::Normalizations = -> tcm do

    Expect_Event[ tcm ]

    tcm.send :define_method, :against_ do | path |

      # confusingly, we do not test `against_path` here -
      # we want the full knownness result

      @result = subject_.with(
        :path, path,
        & handle_event_selectively_ )
      NIL_
    end
  end
end
