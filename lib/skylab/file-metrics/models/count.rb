module Skylab::FileMetrics

  class Models::Count < Model::Node::Structure.new :label, :count

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
        max_f = @child_a.reduce { |a, b| b.count > a.count ? b : a }.count.to_f
        total_f = @child_a.reduce 0 do |m, x| m += x.count ; m end.to_f
        @child_a.each do |c|
          c.set_field :total_share, c.count.to_f / total_f
          share_of_max = c.count.to_f / max_f
          c.set_field :max_share, share_of_max
          c.set_field :lipstick_float, share_of_max
          ping_each_child and ping_each_child[ c ]
        end
        sort_children_by! { |c| -1 * c.count }
      end
      true  # future-proof
    end

    attr_writer :lipstick_float  # ratio of 0 to 1?

    -> do

      lpstck = nil

      CelPxy_ = MetaHell::Proxy::Nice.new :length, :respond_to?, :render

      define_method :lipstick do
        @lipstick_pxy ||= CelPxy_.new(
          :length => -> { 0 },
          :respond_to? => -> x { true },
          :render => -> row_a, table do
            lpstck[ @lipstick_float, row_a, table ]
          end
        )
      end

      lpstck = -> ratio, row_a, table do
        lpst = CLI::Lipstick[ row_a, table.sep, -> { 80 } ] # fallback
        lpstck = lpst
        lpst[ ratio, row_a, table ]
      end
    end.call

    # display (writers [/readers])

    def display_summary_for field_name, &func
      ( @column_summary_cel ||= { } )[ field_name ] = func
      nil
    end

    attr_reader :column_summary_cel

    def display_total_for field_name, &render
      render ||= default_render_total
      display_summary_for field_name, do
        render[ each_child.map(& field_name ).map { |v| v ? v : 0 }.reduce :+ ]
      end
      nil
    end

    attr_reader :default_render_total

    alias_method :default_render_total_ivar, :default_render_total

    def default_render_total &func
      if func
        @default_render_total = func
        nil
      elsif default_render_total_ivar
        @default_render_total
      else
        @default_render_total = -> x do
          "Total: #{ ( ( ::Float === x  ) ? '%.2f' : '%d' ) % x }"
        end
      end
    end

    -> do  # `summary_nodes`

      empty_a = [ ].freeze  # ocd

      to_s = -> x { x.to_s if ! x.nil? }

      define_method :summary_nodes do
        res = if zero_children? or ! column_summary_cel then empty_a else
          proto = first_child
          node = proto.class.members.reduce proto.class.new do |o, sym|
            f = @column_summary_cel.fetch sym do nil end
            if f
              if f.arity.nonzero? then fail "arity? - #{ f }" else
                o.set_field sym, f[]
              end
            end
            o
          end
          [ node ]
        end
        res
      end
    end.call

    def initialize( * )
      # any ivars you set here look ugly in big trees
      super
    end
  end
end
