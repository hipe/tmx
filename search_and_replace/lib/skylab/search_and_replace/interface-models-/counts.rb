module Skylab::SearchAndReplace

  class Interface_Models_::Counts

    def description
      "the grep --count option - \"Only a count of selected lines ..\""
    end

    def initialize fbg, nf

      @_files_by_grep = fbg
      @name_ = nf
    end

    attr_reader(
      :name_,
    )

    def interpret_component st, & pp

      if st.no_unparsed_exists

        Callback_::Bound_Call[ nil, dup, :___to_stream_with_summary, & pp ]
      end
    end

    def ___to_stream_with_summary & pp

      st = ___to_count_stream( & pp )
      if st

        tot_paths = 0 ; tot_matches = 0

        summarize = -> do
          summarize = EMPTY_P_
          _oes_p = pp[ self ]
          _oes_p.call :info, :expression, :summary do | y |

            _ = plural_noun tot_matches, 'match'
            __ = plural_noun tot_paths, 'path'

            y << "(#{ tot_matches } #{ _ } in #{ tot_paths } #{ __ })"
          end
          NIL_
        end

        Callback_.stream do
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
      else
        st
      end
    end

    def ___to_count_stream & pp

      @_files_by_grep.to_file_path_stream(
        :for, :counts,
        & pp )
    end
  end
end

# #history: this splintered off of node [#003]
