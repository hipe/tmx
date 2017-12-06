module Skylab::Git

  class Models::Branch_Collection

    class << self

      def via_project_path_and_cetera pp, sc, & p

        repo = Home_.lib_.git_viz.repository.via_path pp, sc, & p

        repo and __via_at_one_time_valid_project_path repo.path, sc, & p
      end

      def __via_at_one_time_valid_project_path path, system_conduit, & p

        i, o, e, w = system_conduit.popen3(
          'git', 'branch',
          chdir: path )

        i.close
        s = e.gets
        if s
          self._COVER_ME
        else
          __via_these o, w, & p
        end
      end

      def __via_these o, w, & p

        _st = Common_.stream do
          s = o.gets
          if s
            s[ 2 .. -2 ]
            # (we used to accomplish the above by piping to
            # `cut 3-` on the system side oh my)
          else
            d = w.value.exitstatus
            if d.zero?
              NIL_
            else
              self._COVER_ME
            end
          end
        end

        via_name_stream _st
      end

      def via_name_stream st

        s_a = st.to_a
        if s_a
          new s_a
        end
      end

      private :new
    end

    def initialize s_a

      # we find it likely that for practical purposes there will rarely
      # be so many branches that it is prohibitively costly to flush them
      # all to objects early

      @_o_a = s_a.map do | s |

        Home_::Models::Branch.new s
      end
    end

    def to_stream
      Stream_[ @_o_a ]
    end
  end
end
