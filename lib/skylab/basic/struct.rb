module Skylab::Basic

  module Struct

    # use it
    # like this
    #
    #     Foo = Basic::Struct[ :nerp ]
    #
    #     Foo.new.nerp  # => nil
    #
    # beep
    #
    #     Foo.new( :bleep ).nerp  # => :bleep
    #
    # berp
    #
    #     Foo[ :fazzle ].nerp  # = :fazzle
    #
    # bingo
    #
    #     foo = Foo.new
    #     foo.nerp = :dango
    #     foo.nerp  # => :dango
    #
    # django unchained
    #
    #     Foo.members  # => [ :nerp ]
    #
    # hotsauce
    #
    #     Foo.new.members  # => [ :nerp ]
    #

    def self.[] * member_a
      ::Class.new.class_exec do
        extend MM_
        include IM_
        member_a.freeze
        ivar_a = member_a.map { |i| :"@#{ i }" }.freeze
        ivar_h = ::Hash[ member_a.zip( ivar_a ) ].freeze
        const_set :MEMBER_A_, member_a
        const_set :IVAR_A_, ivar_a
        const_set :IVAR_H_, ivar_h
        attr_accessor( * member_a )
        self
      end
    end

    module MM_
      def [] * i_a
        new( * i_a )
      end
      def members  # NOTE not a dupe
        self::MEMBER_A_
      end
    end

    module IM_
      def initialize( * x_a )
        v_a = self.class::IVAR_A_
        x_a.each_with_index do | x, idx |
          instance_variable_set v_a.fetch( idx ), x
        end
        ( x_a.length ... v_a.length ).each do | idx |
          instance_variable_set v_a.fetch( idx ), nil
        end
      end
      def [] i
        instance_variable_get self.class::IVAR_H_.fetch( i )
      end
      def []= i, x
        instance_variable_set self.class::IVAR_H_.fetch( i ), x
      end
      def members
        self.class.members
      end
    end

    def self.new * i_a, & p
      cls = self[ * i_a ]
      cls.class_exec( & p )
      cls
    end
  end
end
