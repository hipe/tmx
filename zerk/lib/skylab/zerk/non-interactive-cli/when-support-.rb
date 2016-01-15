module Skylab::Zerk

  class NonInteractiveCLI

    module When_Support_

      # (this module is written anticipating that *some* (not all) of its
      # clients will be using the [#cm-008]#Scope-stack-trick so the
      # constant names reflect their scope accordingly.)

      Node_monikizer_ = -> expag do

        -> no do

          expag.calculate do
            code no.name.as_slug
          end
        end
      end

      Node_formal_property = Lazy_.call do

        Remote_CLI_lib_[]::Modality_Specific_Property.new(
          :compound_or_operation,
          :is_required,  true,
        )
      end

      MAX_SPLAY_AMOUNT_ = 3
    end
  end
end
