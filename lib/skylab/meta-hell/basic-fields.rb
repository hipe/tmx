module Skylab::MetaHell

  module Basic_Fields  # [#061].

    # the basic fields facility out of the box is a low-frills, low-level
    # means of defining "absorber" methods (frequently but not always
    # `initialize` for use in constructors) that accept as arguments
    # "iambic"-looking lists (either globbed or not globbed depending on you).
    #
    # enhance your class using the iambic DSL:
    #
    #     class Foo
    #       MetaHell_::Basic_Fields.with :client, self,
    #         :globbing, :absorber, :initialize,
    #         :field_i_a, [ :ding, :bat ]
    #     end
    #
    #     foo = Foo.new
    #
    #
    # contructed with no args, your instance will have nilified ivars
    #
    #     foo.instance_variables.sort  # => [ :@bat, :@ding ]
    #
    #
    # it does not, however, give you attr readers
    #
    #     foo.respond_to?( :bat )  # => false
    #     foo.class.private_method_defined?( :bat )  # => false
    #
    #
    # it sets *all* field ivars to nil, and then sets the values given
    #
    #     foo = Foo.new( :bat, :x )
    #     foo.instance_variable_get( :@bat )  # => :x
    #     foo.instance_variable_get( :@ding )  # => nil
    #
    #
    # although it does not enforce required fields, it enforces the valid set
    #
    #     Foo.new( :ding, :x, :bat, :y, :bazzle, :z )  # => KeyError: key not found: :bazzle

    def self.with * x_a
      Shell__.new( x_a ).execute
    end

    def self.via_iambic x_a
      Shell__.new( x_a ).execute
    end

    class Shell__
      def initialize x_a=nil
        @absorber_a = @client = @field_i_a = nil
        @is_struct_like = nil
        x_a and parse_iambic_fully x_a ; nil
      end
      attr_writer :client, :field_i_a

      def parse_iambic_fully x_a
        prs_iambic x_a, true
      end
      def parse_iambic_passively x_a
        prs_iambic x_a, false
      end
    private
      def prs_iambic x_a, is_active
        @absorber = nil
        @d = -1 ; @x_a = x_a ; @last = x_a.length - 1
        while @d < @last
          m_i = OP_H__[ @x_a.fetch @d += 1 ]
          if m_i
            send m_i
          else
            is_active and OP_H__.fetch @x_a.fetch @d
            @d -= 1 ; break
          end
        end
        -1 == @d or @x_a[ 0, @d + 1 ] = EMPTY_A_
        @absorber and raise ::ArgumentError, "incomplete absorber" ; nil
      end
    public

      def execute
        @client.const_set :BASIC_FIELDS_H_,
          ::Hash[ @field_i_a.map { |i| [ i, :"@#{ i }" ] } ].freeze
        @is_struct_like and
          Define_struct_like_methods__[ @client, @field_i_a ]
        @absorber_a and @absorber_a.each do |absorber|
          absorber.execute_on_client @client
        end ; nil
      end
    private
      OP_H__ = {
        absorber: :finish_absorber,
        client: :parse_client,
        field_i_a: :parse_field_i_a,
        globbing: :parse_globbing,
        passive: :parse_passive,
        struct_like: :parse_struct_like,
        supering: :parse_supering
      }.freeze
      def parse_client
        @absorber and raise bld_interrupted_absorber_exception
        @client = @x_a.fetch @d += 1 ; nil
      end
      def parse_globbing
        active_absorber.is_globbing = true ; nil
      end
      def parse_passive
        active_absorber.is_passive = true ; nil
      end
      def parse_supering
        active_absorber.is_supering = true ; nil
      end
      def finish_absorber
        active_absorber.method_name = @x_a.fetch @d += 1
        abs = @absorber ; @absorber = nil
        ( @absorber_a ||= [] ).push abs ; nil
      end
      def active_absorber
        @absorber ||= Absorber__.new
      end
      def parse_struct_like
        @absorber and raise bld_interrupted_absorber_exception
        @is_struct_like = true ; nil
      end
      def parse_field_i_a
        @absorber and raise bld_interrupted_absorber_exception
        @field_i_a = @x_a.fetch @d += 1 ; nil
      end
      def bld_interrupted_absorber_exception
        ::ArgumentError.new "'#{ @x_a[ @d ] }' while absorber in progress"
      end
    end

    class Absorber__
      def initialize
        @is_globbing = @is_passive = @is_supering = nil
      end
      attr_writer :is_globbing, :is_passive, :is_supering, :method_name
      def execute_on_client client
        @is_globbing && @is_passive and self._SANITY
        do_super = @is_supering
        absrb = bld_proc
        if @is_globbing
          client.send :define_method, @method_name do |*x_a|
            absrb[ self, x_a ]
            do_super and super()  # imagine prepend, imagine block given
          end
        else
          client.send :define_method, @method_name do |x_a|
            absrb[ self, x_a ]
            do_super and super()
          end
        end ; nil
      end
    private
      def bld_proc
        is_passive = @is_passive
        -> instance, x_a do
          ivar_h = instance.class::BASIC_FIELDS_H_  # #ancestor-const-ok
          used_i_a = []
          while x_a.length.nonzero?
            i = x_a.first ; ivar = ivar_h[ i ]
            if ivar
              used_i_a.push i
              instance.instance_variable_set ivar, x_a[ 1 ]
              x_a[ 0, 2 ] = EMPTY_A_
            else
              is_passive or ivar_h.fetch i
              break
            end
          end
          Nil_out_the_rest__[ ivar_h, instance, used_i_a ] ; nil
        end
      end
    end

    # when you use the "struct like" "macro",
    #
    #     class Bar
    #       MetaHell_::Basic_Fields.with :client, self, :struct_like,
    #         :globbing, :absorber, :initialize,
    #         :field_i_a, [ :fiz, :faz ]
    #     end
    #
    # you get a `members` instance method
    #
    #     Bar.new.members  # => [ :fiz, :faz ]
    #
    # you get an attr reader and writer for each member
    #
    #     f = Bar.new :faz, :hi
    #     f.faz  # => :hi
    #     f.fiz  # => nil
    #     f.faz = :horf
    #     f.faz  # => :horf
    #     f.fiz = :heff
    #     f.fiz  # => :heff
    #
    # and you get an alias from '[]' to 'new'
    #
    #     Bar[ :fiz, :hoo, :faz, :harf ].fiz  # => :hoo
    #

    Define_struct_like_methods__ = -> mod, field_i_a do
      field_i_a.freeze  # we take what is not ours
      mod.class_exec do
        const_set :BASIC_FIELD_A_, field_i_a
        class << self
          alias_method :[], :new  # if you aren't using `initialize` then ??
        end
        def members ; self.class::BASIC_FIELD_A_ end
        attr_accessor( * field_i_a )
      end ; nil
    end

    Nil_out_the_rest__ = -> ivar_h, obj, i_a do
      obj.instance_exec do
        ( ivar_h.keys - i_a ).each do |ii|
          ivar = ivar_h.fetch ii
          instance_variable_defined? ivar or instance_variable_set ivar, nil
        end
      end
    end

    def self.iambic_detect
      Iambic_detect__
    end

    Iambic_detect__ = -> i, a do
      ( 0 ... ( a.length / 2 )).reduce 0 do |_, idx|
        i == a[ idx * 2 ] and break a[ idx * 2 + 1 ]
      end
    end

    # `iambic_detect` is a hack to peek into an iambic array
    #
    #     a = [ :one, 'two', :three, 'four' ]
    #     MetaHell_::Basic_Fields.iambic_detect[ :three, a ]  # => 'four'

  end
end
