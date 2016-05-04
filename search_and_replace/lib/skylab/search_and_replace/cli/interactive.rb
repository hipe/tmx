module Skylab::SearchAndReplace

  module CLI

    module Interactive

      CUSTOM_TREE = -> do  # accessed 1x
        [
          :children, {

            egrep_pattern: -> do
              EMPTY_A_
              # #milestone-9: this is supposed to "appear" IFF ruby regexp
            end,

            search: -> do
              [
                :children, {

                  files_by_find: -> o do

                    # experimental syntax #grease here in contrast to next
                    o.hotstring_delineation %w( files-by- f ind )
                  end,

                  files_by_grep: -> do
                    [
                      :hotstring_delineation, %w( files-by- g rep ),
                    ]
                  end,

                  matches: -> o do

                    o.custom_view_controller_by do |x, svcs|
                      Here_::Interactive_View_Controllers_::Matches.new x, svcs
                    end
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
