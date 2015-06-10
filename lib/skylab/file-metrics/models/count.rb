module Skylab::FileMetrics

  Models::Count = Model::Node::Structure.new :label, :count
  class Models::Count

    undef_method :count
    def count
      if @count || zero_children?
        @count
      else
        @child_a.map(& :count ).reduce :+  # cute
      end
    end

    def collapse_and_distribute &ping_each_child
      # all your children are in. tell them now which one is your favorite.
      if nonzero_children?
        max_p = @child_a.reduce { |a, b| b.count > a.count ? b : a }.count.to_f
        total_p = @child_a.reduce 0 do |m, x| m += x.count ; m end.to_f
        @child_a.each do |c|
          c.set_field :total_share, c.count.to_f / total_p
          share_of_max = c.count.to_f / max_p
          c.set_field :max_share, share_of_max
          c.set_field :lipstick_float, share_of_max
          ping_each_child and ping_each_child[ c ]
        end
        sort_children_by! { |c| -1 * c.count }
      end
      true  # future-proof
    end

    attr_writer :lipstick_float  # ratio of 0 to 1?

    def lipstick
      @lipstick_pxy ||= bld_lipstick_pxy
    end

    def bld_lipstick_pxy
      CelPxy_.new(

        # we act like a string during the pre-render, and don't ever add
        :length => -> { 0 },  # any width, you are strictly a decoration.

        :respond_to? => MONADIC_TRUTH_,  # catch errors

        :normalized_scalar => -> do
          @lipstick_float
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
