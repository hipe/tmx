module Skylab::FileMetrics

  Models_::Totaller = FM_::Model_::Tree_Branch::Structure.new :label, :count

  class Models_::Totaller

    Actions = THE_EMPTY_MODULE_

    undef_method :count
    def count
      if @count || zero_children?
        @count
      else
        @children.map(& :count ).reduce :+  # cute
      end
    end

    def mutate_by_common_sort
      _mutate_by_sort
    end

    def mutate_by_visit_then_sort & visit_p
      _mutate_by_sort( & visit_p )
    end

    def _mutate_by_sort & visit_p

      # all your children are in. tell them now which one is your favorite.

      if nonzero_children?
        max_p = @children.reduce { |a, b| b.count > a.count ? b : a }.count.to_f
        total_p = @children.reduce 0 do |m, x| m += x.count ; m end.to_f
        @children.each do |c|
          c.set_field :total_share, c.count.to_f / total_p
          share_of_max = c.count.to_f / max_p
          c.set_field :normal_share, share_of_max
          visit_p and visit_p[ c ]
        end
        sort_children_by! { |c| -1 * c.count }
      end
      true  # future-proof
    end

    attr_writer :normal_share  # ratio of 0 to 1?

    def lipstick
      @lipstick_pxy ||= bld_lipstick_pxy
    end

    def bld_lipstick_pxy
      CelPxy_.new(

        # we act like a string during the pre-render, and don't ever add
        :length => -> { 0 },  # any width, you are strictly a decoration.

        :respond_to? => MONADIC_TRUTH_,  # catch errors

        :normalized_scalar => -> do
          @normal_share
        end
      )
    end

    CelPxy_ = LIB_.proxy_lib.nice :length, :respond_to?, :normalized_scalar

    def sum_of sym

      x_a = each_child.map( & sym )
      x_a.compact!
      x_a.reduce :+

      # each_child.map(& sym ).reduce :+
        # http://howfuckedismydatabase.com/nosql
    end

    # `initialize` - note any ivars you would set would look ugly in big trees
  end
end
