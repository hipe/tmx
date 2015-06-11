module Skylab::FileMetrics

  Model_ = ::Module.new  # tree with struct-like nodes

  class Model_::Tree_Branch

    def initialize
      @child_a = nil
    end

    #                     ~ read about the children ~

    attr_reader :child_a

    def first_child  # meh
      if nonzero_children?
        @child_a[ 0 ]
      end
    end

    def nonzero_children?
      child_count.nonzero?
    end

    def zero_children?
      child_count.zero?
    end

    def child_count
      @child_a ? @child_a.length : 0
    end

    def each_child & yld_p
      if @child_a
        @child_a.each( & yld_p )
      end
    end

    #                       ~ mutate constituency ~

    def add_child child
      ( @child_a ||= [] ).push child
      nil
    end

    alias_method :<<, :add_child  # NOTE experimental!

    #                     ~ mutate (non-constituency) ~

    def sort_children_by! & p  # assume children
      @child_a.sort_by!( & p )
      nil
    end

  end

  class Model_::Tree_Branch::Structure < Model_::Tree_Branch

    class << self

      def members
        self::IVAR_BOX__.get_names
      end

      alias_method :orig_new, :new

      def new * sym_a

        cls = ::Class.new self

        class << cls
          alias_method :new, :orig_new
        end

        cls.class_exec do

          const_set :IVAR_BOX__, Callback_::Box.new
          _accept_symbols sym_a
        end

        cls
      end

      def subclass * sym_a

        cls = ::Class.new self

        cls.class_exec do

          const_set :IVAR_BOX__, self::IVAR_BOX__.dup
          _accept_symbols sym_a
        end

        cls
      end

    private

      def _accept_symbols sym_a
        bx = const_get :IVAR_BOX__, false
        sym_a.each do | sym |
          attr_accessor sym
          bx.add sym, :"@#{ sym }"
        end
        nil
      end
    end  # >>

    def initialize * x_a

      super()

      bx = self.class::IVAR_BOX__

      if x_a.length > bx.length
        raise ::ArgumentError, "wrong number of args (#{ x_a.length } for #{
          }#{ bx.length })"
      end

      h = ::Hash.try_convert x_a.last
      if h
        x_a.pop
      end

      x_a.each_with_index do | x, d |
        instance_variable_set bx.at_position( d ), x
      end

      ( x_a.length ... bx.length ).each do | d |
        instance_variable_set bx.at_position( d ), nil
      end

      if h
        h.each_pair do | k, x |
          instance_variable_set bx.fetch( k ), x
        end
      end
    end

    def [] k
      send k  # meh
    end

    def set_field k, x
      instance_variable_set self.class::IVAR_BOX__.fetch( k ), x
      nil
    end
  end
end
# :+#tombstone the predecessor to this is HILARIOUS function soup
