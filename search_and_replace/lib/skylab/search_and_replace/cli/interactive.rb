module Skylab::SearchAndReplace

  module CLI

    module Interactive

      CUSTOM_TREE = -> do  # accessed 1x
        [
          :children, {

            egrep_pattern: -> do
              # #milestone-9: this is supposed to "appear" IFF ruby regexp
            end,

            search: -> do
              [
                :children, {
                  files_by_find: -> do
                    [
                      :hotstring_delineation, %w( files-by- f ind ),
                    ]
                  end,
                  files_by_grep: -> do
                    [
                      :hotstring_delineation, %w( files-by- g rep ),
                    ]
                  end,
                  matches: -> do
                    [
                      :custom_view_controller, -> * a do
                        Here_::Interactive_View_Controllers_::Matches.new( * a )
                      end,
                    ]
                  end,
                  replacement_expression: -> do
                    [
                      :hotstring_delineation, %w( replacement- e xpression ),
                    ]
                  end,
                  replace: -> do
                    [
                      :custom_view_controller, -> * a do
                        Here_::Interactive_View_Controllers_::Edit_File.new( * a )
                      end,
                    ]
                  end,
                }
              ]
            end
          }
        ]
      end
    end
  end
end
