module Skylab::SearchAndReplace

  class Interface_Models_::Counts

    def self.describe_into_under y, _
      y << "the grep --count option - \"Only a count of selected lines ..\""
    end

    PARAMETERS = Attributes_.call(
      files_by_grep: nil,
    )
    attr_writer( * PARAMETERS.symbols )

    def initialize & p
      @_listener = p
    end

    def finish__files_by_grep__by o  # #[#ze-031]
      o.for = :counts
      o.execute
    end

    def execute

      st = @files_by_grep
      _p = @_listener
      # -

        tot_paths = 0 ; tot_matches = 0

        summarize = -> do
          summarize = EMPTY_P_
          _p.call :info, :expression, :summary do | y |

            _ = plural_noun tot_matches, 'line'
            __ = plural_noun tot_paths, 'path'

            y << "(#{ tot_matches } matching #{ _ } in #{ tot_paths } #{ __ })"
          end
          NIL_
        end

        Common_.stream do
          o = st.gets
          if o
            tot_matches += o.count
            tot_paths += 1
            o
          else
            summarize[]
          end
          o
        end
      # -
    end

    def handle_event_selectively_for_zerk
      @_listener
    end
  end
end
# #history: this splintered off of node [#003]
