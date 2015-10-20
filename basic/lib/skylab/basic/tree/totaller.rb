module Skylab::Basic

  class Tree::Totaller < Tree::Business

    def initialize
      super()
    end

    attr_accessor(
      :count,
      :total_share,
      :normal_share,
    )

    def finish
      _mutate_by_sort
    end

    def accept_and_finish_by & visit_p
      _mutate_by_sort( & visit_p )
    end

    def _mutate_by_sort & visit_p

      # all your children are in. tell them now which one is your favorite.

      if children_count.nonzero?

        cx_a = to_child_stream.to_a

        max = 0
        tot = 0

        cx_a.each do | cx |

          d = cx.count
          tot += d
          if max < d
            max = d
          end

        end

        cx_a.each do | cx |

          f = cx.count.to_f

          cx.total_share = f / tot

          cx.normal_share = f / max

          if visit_p
            visit_p[ cx ]
          end
        end

        @a.sort_by! do | sym |
          -1 * @h.fetch( sym ).count
        end
      end
      ACHIEVED_
    end

    def sum_of sym

      st = to_child_stream
      o = st.gets
      if o

        x = o.send sym
        begin
          o = st.gets
          o or break
          x += ( o.send sym )
          redo
        end while nil
        x
      end

      # each_child.map(& sym ).reduce :+
        # http://howfuckedismydatabase.com/nosql
    end
  end
end
