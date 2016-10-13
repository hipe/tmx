module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class Actors_::Build_matrix  # algorithm in [#006]

        def initialize bundle, repo, rsx  # no events. all failure is exceptional

          @repo = repo
          @stderr = rsx.stderr
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

          firsts = Common_::Box.new
          lasts = Common_::Box.new

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

          _ = @firsts.a_.reduce do | upstream, head |

            @stderr.write A___

            _i, o, _e, t = _cherry upstream, head  # :+[#021]


            line = o.gets

            if line

              PLUS_BYTE___ == line.getbyte( 0 ) or fail

              # there is one or more commit in <limit>..<head> that has no
              # equivalent in <head>..<upstream>. this means the upstream
              # is the "older" of the two.

              t.exit  # no need to look at the rest. result is receiver
              upstream
            else

              t.value.exitstatus.zero? or fail
              head
            end
          end

          @earliest_SHA = _
          NIL_
        end

        A___ = 'a'

        def __init_latest

          _ = @lasts.a_.reduce do | upstream, head |

            @stderr.write Z___

            _i, o, _e, t = _cherry upstream, head

            line = o.gets

            if line

              # see converse note above

              PLUS_BYTE___ == line.getbyte( 0 ) or fail
              t.exit
              head
            else

              t.value.exitstatus.zero? or fail
              upstream
            end
          end

          @latest_SHA = _
          NIL_
        end

        PLUS_BYTE___ = '+'.getbyte 0
        Z___ = 'z'

        def _cherry long_SHA, long_SHA_

          @repo.repo_popen_3_ 'cherry', _short( long_SHA ), _short( long_SHA_ )
        end

        def __init_order_box  # (read #step-three)

          @stderr.write O___

          _, o, e, t = @repo.repo_popen_3_ 'log', '--pretty=tformat:%H',
            "#{ _short @earliest_SHA }..#{ _short @latest_SHA }", "--"  # :+[#021]

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
          order_box = Common_::Box.new
          pool = ::Hash[ @bundle.ci_box.a_.map { | sha_s | [ sha_s, true ] } ]

          # because of the way the vendor command works, the first (oldest)
          # SHA will not appear in the list of SHA's; yet for the sake of
          # our algorithm we will add it such that it looks like it was:

          pool.fetch @earliest_SHA  # sanity
          pool.delete @earliest_SHA  # wlll pay it back #here

          @stderr.write "(building order box with .."

          count = 0
          begin
            line = o.gets

            if ! line
              t.value.exitstatus.zero? or fail
              break
            end

            count += 1

            line.chop!

            _had = pool.delete line
            _had or redo

            column_index -= 1

            order_box.add line, column_index

            if pool.length.zero?

              t.exit
              if o.respond_to? :close
                o.close
                e.close
              end
              @stderr.write NEWLINE_

              break
            end

            redo
          end while nil

          @stderr.write "#{ count } commits)#{ NEWLINE_ }"

          order_box.add @earliest_SHA, 0  # payed it back from :#here

          order_box.a_.reverse!  # now the item order matches the values

          @order_box = order_box
          NIL_
        end

        O___ = 'o'

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
