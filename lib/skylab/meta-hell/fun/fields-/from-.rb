module Skylab::MetaHell

  module FUN::Fields_::From_

    # let a class define its fields via particular methods it defines
    # in a special DSL block
    #
    #     class Foo
    #
    #       def one
    #       end
    #
    #       MetaHell::FUN::Fields_::From_.methods do
    #         def two a
    #           @two_value = a.shift
    #         end
    #       end
    #
    #       attr_reader :two_value
    #
    #       def three
    #       end
    #
    #       alias_method :initialize, :absorb
    #     end
    #
    #     Foo.new( :two, "foozle" ).two_value  # => 'foozle'
    #
    # a subclass will inherit the same behavior and fieldset (by default)
    #
    #     class Bar < Foo
    #     end
    #
    #     Bar.new( :two, "fazzle" ).two_value  # => 'fazzle'
    #
    # a subclasss can extend the fieldset (and it won't do the bad thing)
    #
    #     class Baz < Foo
    #
    #       MetaHell::FUN::Fields_::From_.methods do
    #         def four a
    #           @four_value = a.shift
    #         end
    #       end
    #
    #       attr_reader :four_value
    #     end
    #
    #     Baz.new( :four, "frick" ).four_value  # => 'frick'
    #     Foo.new( :four, "frick" )  # => ArgumentError: unrecognized argument name "four" - did you mean two?
    #

    def self.methods &blk
      mod = eval 'self', blk.binding
      box = mod.module_exec do
        if const_defined? CONST_
          existing = const_get CONST_
          if const_defined? CONST_, false
            existing
          else
            const_set CONST_, existing.dupe
          end
        else
          define_method :absorb, & Absorb_ ; private :absorb
          define_method :absorb_notify, & Absorb_notify_
          define_method :field_op_h , & Field_op_h_ ; private :field_op_h
          const_set CONST_, Box_.new
        end
      end
      Method_Added_Muxer_[ mod ].for_each_method_in_block_do_this blk do |m|
        box.add m, m  # field names and method names are one and the same
        nil
      end
    end

    CONST_ = :FIELDS_FROM_METHODS_BOX_

    Absorb_ = -> *a do
      op_h = field_op_h
      while a.length.nonzero?
        send op_h[ a.shift ], a
      end
      nil
    end

    Absorb_notify_ = -> a do
      op_h = field_op_h
      while a.length.nonzero?
        (( m = op_h.fetch( a.first ) { } )) or break
        a.shift
        send m, a
      end
      nil
    end

    Field_op_h_ = -> do
      self.class.const_get CONST_  # if the class added no
      # fields of its own to the box, ascend up to parent
    end

    class Box_ < MetaHell::Services::Basic::Box
      def initialize
        super()
        @h.default_proc = -> h, k do
          raise ::ArgumentError, "unrecognized argument name #{ FUN::Parse::
            Strange_[ k ] } - did you mean #{ Lev__[ @a, k ] }?"
        end
      end
      Lev__ = -> a, x do
        MetaHell::Services::Headless::NLP::EN::Levenshtein_::Templates_::
          Or_[a, x]
      end
      def dupe
        a = @a ; h = @h
        self.class.allocate.instance_exec  do
          @a = a.dup ; @h = h.dup
          self
        end
      end
    end

    class Method_Added_Muxer_
      # imagine having multiple subscribers to one method added event
      def self.[] mod
        me = self
        mod.module_exec do
          @method_added_muxer ||= begin  # ivar not const! boy howdy watch out
            muxer = me.new self
            singleton_class.instance_method( :method_added ).owner == self and
              fail "sanity - won't overwrite existing method_added hook"
            define_singleton_method :method_added, &
              muxer.method( :method_added_notify )
            muxer
          end
        end
      end
      def initialize mod
        @p = nil
        @mod = mod
      end
      def for_each_method_in_block_do_this blk, &do_this
        @p and fail "implement me - you expected this to actually mux?"
        @p = do_this
        @mod.module_exec( & blk )
        @p = nil
      end
    private
      def method_added_notify i
        @p && @p[ i ]
        nil
      end
    end
  end
end
