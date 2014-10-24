module Skylab::Basic

  module Struct  # [#030].

    # use it
    # like this
    #
    #     Foo = Basic_::Struct[ :nerp ]
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
        make_via_arglist member_i_a
      end

      def new * i_a, & p
        make_via_arglist i_a, & p
      end

      def make_via_arglist member_i_a, & p
        if member_i_a.length.zero? or member_i_a[ 0 ].respond_to?( :id2name )
          cls = make_struct_class_via_arglist member_i_a
          p and cls.class_exec( & p )
          cls
        else
          cls = member_i_a.shift
          apply_enhancement_with_member_i_a_on_module member_i_a, cls
          p and cls.class_exec( & p )
          nil
        end
      end

      def the_empty_struct
        THE_EMPTY_STRUCT__
      end

    private

      def make_struct_class_via_arglist member_i_a
        cls = ::Class.new
        apply_enhancement_via_client_and_members cls, member_i_a
        cls
      end

      def apply_enhancement_via_client_and_members cls, member_i_a

        cls.extend MM__
        cls.include IM__

        _BOX = if cls.const_defined? CONST__
          if cls.const_defined? CONST__, false
            cls.const_get CONST__
          else
            cls.const_set CONST__, cls.const_get( CONST__ ).dup
          end
        else
          cls.const_set CONST__, Callback_::Box.new
        end

        member_i_a.each do |i|
          _BOX.set i, :"@#{ i }"
        end

        cls.send :attr_accessor, * member_i_a

        cls.send :define_method, :some_ivar do |x|
          _BOX.fetch x do
            if ::Integer === x and x < _BOX.length
              _BOX.at_position x
            else
              when_no_member x
            end
          end
        end

        cls.send :define_method, :__basic_struct_box__ do
          _BOX
        end

        nil
      end
    end

    CONST__ = :BASIC_STRUCT_PROPERTY_BOX___

    module MM__

      def [] * i_a
        new( * i_a )
      end

      def members
        const_get( CONST__ ).get_names
      end

    end

    module IM__

      def initialize( * x_a )

        box = __basic_struct_box__

        x_a.each_with_index do |x, d|
          instance_variable_set box.at_position( d ), x
        end

        ( x_a.length ... box.length ).each do |d|
          instance_variable_set box.at_position( d ), nil
        end
      end

      # CAVEAT - we might change the below to reader / writer calls rather than ivar accessions

      def to_a
        mmbrs.map( & method( :[] ) )
      end

      def to_json state=nil
        get_json_data.to_json state
      end

      def get_json_data
        to_h
      end

      def to_h
        h = {}
        each_pair do |i, x|
          h[ i ] = x
        end
        h
      end

      def each_pair
        if block_given?
          mmbrs.each do |i|
            yield [ i, self[ i ] ]
          end ; nil
        else
          to_enum :each_pair
        end
      end

      def members
        self.class.members
      end

      private def mmbrs
        __basic_struct_box__.send :a
      end

      def [] i
        instance_variable_get some_ivar i
      end

      def []= i, x
        instance_variable_set some_ivar( i ), x
      end

    private

      def when_no_member x
        case x
        when ::String, ::Symbol
          raise ::NameError, "no member '#{ x }' in struct"
        when ::Integer
          raise ::IndexError, "offset #{ x } too large for struct(size:#{ __basic_struct_box__.length })"
        else
          raise ::TypeError, "no implicit conversion of #{ x.class } into Integer"
        end
      end
    end

    THE_EMPTY_STRUCT__ = new.freeze

  end
end
