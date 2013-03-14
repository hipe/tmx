module Skylab::FileMetrics

  module Model
    #                    ~ tree with struct-like nodes ~
  end

  class Model::Node

    #                     ~ read about the children ~

    attr_reader :child_a

    def child_count
      child_a ? @child_a.length : 0
    end

    def zero_children?
      child_a ? @child_a.length.zero? : true
    end

    def nonzero_children?
      @child_a.length.nonzero? if child_a  # important - we hackishly ..
    end

    def first_child  # meh
      if nonzero_children?
        @child_a[ 0 ]
      end
    end

    def each_child &blk
      ea = ::Enumerator.new do |y|
        if child_a
          @child_a.each(& y.method( :yield ) )
        end
        nil
      end
      blk ? ea.each(& blk ) : ea
    end  # (think big)

    #                       ~ mutate constituency ~
    def add_child child
      ( @child_a ||= [] ) << child
      nil
    end

    alias_method :<<, :add_child  # NOTE experimental!

    #                     ~ mutate (non-constituency) ~

    def sort_children_by! &b  # assumes children
      @child_a.sort_by!(& b )
      nil
    end

    def initialize
    end
  end

  class Model::Node::Structure < Model::Node

    orig_new = method( :new ).unbind

    first_kls = self ; produce_class = nil

    define_singleton_method :new do |field, *fields|
      first_kls == self or fail 'sanity'
      kls = produce_class[ fields.unshift( field ) ]
      kls.class_exec do                        # only for the first produced
        members.each { |m| attr_accessor m }   # class, out of the box you
      end                                      # get these NOTE there is danger
      kls
    end

    subclass = ->( *fields ) do                # empty works as expected
      if ( members & fields ).length.nonzero?
        raise ::ArgumentError, "ocd sanity check - #{ members & fields }"
      end
      all = [ * members, * fields ]
      kls = produce_class[ all, self ]
      kls.class_exec do                        # NOTE - only the new fields.
        fields.each do |m|                     # allow parent class to define
          method_defined? m or attr_reader m   # child accessors even when
          method_defined? "#{ m }=" or attr_writer m  # they are not present in
        end                                    # parent class as a member
      end
      kls
    end

    membrs = set_get_field = initialize = nil

    produce_class = -> field_a, base_kls=nil do
      ::Class.new( base_kls || first_kls ).class_exec do

        define_singleton_method :new, & orig_new.bind(self).to_proc
          # restore the expected meaning of 'new' - NOTE you've got to do
          # this for each new subclass not just the base one!

        if ! base_kls  # hopefully we only need to define this one once.
          define_singleton_method :subclass, & subclass
        end
        field_a = instance_exec field_a, &membrs
        instance_exec field_a, &set_get_field
        define_method :initialize, & ( initialize[ field_a, member_index_h ] )
        self
      end
    end

    membrs = -> field_a do
      field_a = field_a.dup.freeze           # mine now. like ::Struct#members
      define_singleton_method :members do field_a end
      member_index_h = ::Hash[ field_a.each_with_index.to_a ].freeze
      define_singleton_method :member_index_h do member_index_h end
      field_a
    end

    set_get_field = -> field_a do
      set_h = { } ; get_h = { }
      field_a.each do |key|
        ivar = "@#{ key }"
        set_h[ key ] = -> v { instance_variable_set ivar, v }
        get_h[ key ] = ->   { instance_variable_get ivar    }
      end
      define_method :set_field do |k, v|
        instance_exec v, & set_h.fetch( k )
      end
      define_method :get_field do |k|
        instance_exec(& get_h.fetch( k ) )
      end
    end

    initialize = -> field_a, member_index_h do
      length = field_a.length

      ->( *args ) do
        super( ) # might be going here, might be there.
        if args.length > length
          raise ::ArgumentError, "wrong number of arguments (#{
            }#{ args.length } for #{ length })"
        else
          h = args.pop.dup if ::Hash === args.last
          len = args.length                  # expand the args array to the
          if args.length < length            # correct length now (so we set
            args[ length - 1 ] = nil         # all ivars at the end.)
          end
          if h
            h.each do |k, v|
              i = member_index_h.fetch k  # (raise ::KeyError on bad keys)
              if i < len
                raise ::ArgumentError, "hash argument in conflict with #{
                  }positional argument - index #{ i }, \"#{ k }\""
              else
                args[i] = v
              end
            end
          end
          length.times { |x| set_field field_a.fetch( x ), args.fetch( x ) }
        end
      end
    end
  end
end
