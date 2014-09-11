module Skylab::Basic

  module Struct  # [#030].

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

    class << self

      def [] * member_i_a
        from_i_a member_i_a
      end

      def from_i_a member_i_a
        if member_i_a.length.zero? or member_i_a[ 0 ].respond_to?( :id2name )
          build_struct_class_from_member_i_a member_i_a
        else
          apply_enhancement_with_member_i_a_on_module member_i_a, member_i_a.shift
          nil
        end
      end

    private

      def build_struct_class_from_member_i_a member_i_a
        cls = ::Class.new
        apply_enhancement_with_member_i_a_on_module member_i_a, cls
        cls
      end

      def apply_enhancement_with_member_i_a_on_module member_i_a, mod  # mutates arg
        mod.module_exec do
          extend MM__ ; include IM__
          attr_accessor( *
            const_set( :BASIC_STRUCT_MEMBER_I_A__, member_i_a.freeze ) )
          const_set :BASIC_STRUCT_IVAR_A__,
            member_i_a.map { |i| :"@#{ i }" }.freeze
          const_set :BASIC_STRUCT_IVAR_H__,
            ::Hash[ member_i_a.zip( self::BASIC_STRUCT_IVAR_A__ ) ].freeze
          self
        end
      end
    end

    module MM__
      def [] * i_a
        new( * i_a )
      end
      def members  # NOTE not a dupe
        self::BASIC_STRUCT_MEMBER_I_A__
      end
    end

    module IM__
      def initialize( * x_a )
        v_a = self.class::BASIC_STRUCT_IVAR_A__
        x_a.each_with_index do | x, idx |
          instance_variable_set v_a.fetch( idx ), x
        end
        ( x_a.length ... v_a.length ).each do | idx |
          instance_variable_set v_a.fetch( idx ), nil
        end
      end
      # CAVEAT - we might change the below to reader / writer calls rather than ivar accessions
      def [] i
        instance_variable_get self.class::BASIC_STRUCT_IVAR_H__.fetch( i )
      end
      def to_a
        members.map( & method( :[] ) )
      end
      def members
        self.class.members
      end
      def []= i, x
        instance_variable_set self.class::BASIC_STRUCT_IVAR_H__.fetch( i ), x
      end
      def to_json state=nil
        get_json_data.to_json state
      end
      def get_json_data
        to_h
      end
      def to_h
        h = { } ; each_pair { |i, x| h[ i ] = x } ; h
      end
      def each_pair
        if block_given?
          members.each { |i| yield [ i, self[ i ] ] }
        else
          to_enum :each_pair
        end
      end
    end

    def self.new * i_a, & p
      cls = self[ * i_a ]
      p and cls.class_exec( & p )
      cls
    end
  end
end
