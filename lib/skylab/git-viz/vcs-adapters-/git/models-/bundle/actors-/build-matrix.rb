module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Actors_::Build_matrix  # algorithm in [#006]

        def initialize bundle, repo  # no events. all failure is exceptional

          @repo = repo
          @bundle = bundle
        end

        def execute

          __init_firsts_and_lasts  # [#006]:#step-one
          __init_earliest
          __init_latest  # #step-two
          __init_order_box  # #step-three

          Sparse_Matrix___.new @order_box, @bundle
        end

        Sparse_Matrix___ = ::Struct.new :order_box, :bundle

        def __init_firsts_and_lasts

          firsts = Callback_::Box.new
          lasts = Callback_::Box.new

          @bundle.trails.each do | tr |

            fc_a = tr.filechanges

            _first_fc = fc_a.first
            _last_fc = fc_a.last

            firsts.touch _first_fc.SHA.string do end
            lasts.touch _last_fc.SHA.string do end
          end

          @firsts = firsts
          @lasts = lasts

          NIL_
        end

        def __init_earliest

          _ = @firsts.a_.reduce do | m, sha |

            _i, o, _e, t = _cherry m, sha

            t.value.exitstatus.zero? or fail

            line = o.gets
            if line

              PLUS_BYTE___ == line.getbyte( 0 ) or fail
              m
            else
              # the right one (head) has no commits yet to be appied to upstream
              # (left). since they are on the same timeline, this can only mean
              # that the right one is the same or "older" than the left (yeah?)
              #
              sha
            end
          end

          @earliest_SHA = _
          NIL_
        end

        def __init_latest

          _ = @lasts.a_.reduce do | m, sha |

            _i, o, _e, t = _cherry m, sha

            # if it's empty, flip it, else don't

            t.value.exitstatus.zero? or fail

            line = o.gets

            if line

              PLUS_BYTE___ == line.getbyte( 0 ) or fail
              sha
            else
              # the right has no commits that the left doesn't have. right is
              # same or older, ergo left is same or newer.
              m
            end
          end

          @latest_SHA = _
          NIL_
        end

        PLUS_BYTE___ = '+'.getbyte 0

        def _cherry long_SHA, long_SHA_

          @repo.repo_popen_3_ 'cherry', _short( long_SHA ), _short( long_SHA_ )
        end

        def __init_order_box  # (read #step-three)

          _, o, e, t = @repo.repo_popen_3_ 'log', '--pretty=tformat:%H',
            "#{ _short @earliest_SHA }..#{ _short @latest_SHA }", "--"

          t.value.exitstatus.zero? or fail

          # as does the output of most such vendor commands, the output of
          # this one starts from the most recent (graph-wise) SHA and at each
          # step (each line of output) goes backward in time.
          #
          # we are producing integer indexes that count from the beginning
          # state (which we give an index of 0) and count upwards to N-1,
          # where N is the number of commits in our commit box.
          #
          # as such, as we progress through each line of the vendor output we
          # must count backwards from N-1 to assign each new column index.

          column_index = @bundle.ci_box.length  # subtract one before you use it
          order_box = Callback_::Box.new
          pool = ::Hash[ @bundle.ci_box.a_.map { | sha_s | [ sha_s, true ] } ]


          # because of the way the vendor command works, the first (oldest)
          # SHA will not appear in the list of SHA's; yet for the sake of
          # our algorithm we will add it such that it looks like it was:

          pool.fetch @earliest_SHA  # sanity
          pool.delete @earliest_SHA  # wlll pay it back #here

          begin
            line = o.gets
            line or break
            line.chop!

            _had = pool.delete line
            _had or next

            column_index -= 1

            order_box.add line, column_index

            if pool.length.zero?

              if o.respond_to? :closed?  # hack to allow for minimal mocks for now
                if ! o.closed?
                  o.close
                end
                if ! e.closed
                  e.close
                end
              end

              break
            end

            redo
          end while nil

          order_box.add @earliest_SHA, 0  # payed it back from :#here

          order_box.a_.reverse!  # now the item order matches the values

          @order_box = order_box
          NIL_
        end

        def _short long_SHA
          long_SHA[ 0, SHORT_SHA_LENGTH__ ]
        end

        SHORT_SHA_LENGTH__ = 7  # short SHA length. using the short forms
          # here makes life easier near mocking, with perhaps an increased
          # risk in hash collision
      end
    end
  end
end
