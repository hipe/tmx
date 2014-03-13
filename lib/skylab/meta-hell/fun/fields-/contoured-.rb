module Skylab::MetaHell

  module FUN::Fields_

    self::Mechanics_.touch

    module Contoured_

      # use it
      # like so:
      #
      #     class Foo
      #       MetaHell::FUN::Fields_::Contoured_[ self,
      #         :absorb_method, :absorb,
      #         :proc, :foo,
      #         :memoized, :proc, :bar,
      #         :method, :bif,
      #         :memoized, :method, :baz ]
      #         public :absorb
      #     end
      #
      #     foo = Foo.new
      #     foo.absorb_fully( :foo, -> { :yes } )
      #     foo.foo  # => :yes
      #
      # and so:
      #
      #     @ohai = :hi
      #     f = Foo.new ; f.absorb(  :foo, -> { 'x' },
      #                              :bar, -> { "y:#{ @ohai }" },
      #                              :bif, -> { "_#{ foo }_" },
      #                              :baz, -> { "<#{ foo }>" } )
      #     f.foo  # => 'x'
      #     f.bar  # => 'y:hi'
      #     f.bif  # => '_x_'
      #     ( f.baz.object_id == f.baz.object_id )  # => true
      #
      #

      class << self
        def [] client, *a
          from_iambic_and_client a, client
        end
        def from_iambic_and_client a, client
           Glint_.new( client ).absorb( a ).flush
        end
      end

      class Glint_

        def initialize client
          @field_box = @absorb_method_x = nil
          @client = client
          nil
        end

        def absorb a
          begin
            send OP_H_.fetch( a.shift ), a
          end while a.length.nonzero?
          self
        end
        #
        OP_H_ = {
          absorb_method: :parse_absorb_method,
          proc: :parse_proc,
          memoized: :parse_memoized,
          method: :parse_method,
          required: :parse_required,
          field: :parse_field
        }.freeze

        def flush
          @field_box or field_box
          Touch_const_with_dupe_for_[ -> _ do
            p = Required_fields_check_[ @field_box ]
            @client.facet_muxer.add_hook_listener :post_absorb, p
            p
          end, :CONTOURED_REQUIRED_CHECK_, @client ]
          nil
        end
        #
        Required_fields_check_ = -> field_box do  # on dupe, rewrite the func
          on_dupe_for = -> client do
            Dupable_Proc_.new on_dupe_for, &
              Req_check_[ client.const_get CONST_ ]
          end
          Dupable_Proc_.new on_dupe_for, & Req_check_[ field_box ]
        end
        #
        Req_check_ = -> field_box do
          -> agent do
            miss_a = field_box._a.reduce [] do |m, method_i|
              (( fld = field_box.fetch method_i )).is_required or next m
              agent.instance_variable_defined? fld.ivar and
                ! agent.instance_variable_get( fld.ivar ).nil? and next m
              m << fld
            end
            miss_a.length.nonzero? and
              Missing_required_fields_notify_[ agent, miss_a ]
            nil
          end
        end
        #
        class Dupable_Proc_ < ::Proc
          class << self ; alias_method :[], :new end
          def initialize on_dupe_for, &blk
            super( &blk )
            @on_dupe_for = on_dupe_for
            nil
          end
          def dupe_for x
            @on_dupe_for[ x ]
          end
        end
        #
        Missing_required_fields_notify_ = -> agent, miss_a do  # etc
          s, op, cp = 1 == miss_a.length ? MetaHell::EMPTY_A_ : %w[ s ( ) ]
          raise ::ArgumentError, "missing required argument#{ s } - #{ op }#{
            }#{ miss_a.map( & :method_i ) * ', ' }#{ cp }"
          nil
        end

      private

        def field_box
          @field_box ||= begin
            Touch_client_and_give_box_[
              @absorb_method_x || [ :override, :initialize ] , @client ]
          end
        end

        def parse_absorb_method a
          x = a.fetch( 0 ) ; a.shift
          @absorb_method_x = x
          nil
        end

        def parse_proc a
          ( add_proc_field_with_name a ).flush @client
          nil
        end

        def parse_method a
          ( add_method_field_with_name a ).flush @client
          nil
        end

        def parse_memoized a
          curry_branch proc: :parse_memoized_proc,
                     method: :parse_memoized_method
          parse_memoized a
          nil
        end

        def parse_memoized_proc a
          add_proc_field_with_name a do |fld|
            fld.is_memoized = true
          end.flush @client
          nil
        end

        def parse_memoized_method a
          add_method_field_with_name a do |fld|
            fld.is_memoized = true
          end.flush @client
          nil
        end

        def add_proc_field_with_name a, &blk
          curry_field_builder Proc_
          add_proc_field_with_name a, &blk
        end

        def add_method_field_with_name a, &blk
          curry_field_builder Method_
          add_method_field_with_name a, &blk
        end

        def curry_branch h
          define_singleton_method caller_locations( 1, 1 )[ 0 ].base_label, &
            Branch_.curry[ self, h ]
          nil
        end

        Branch_ = -> r, h, a do
          m = h.fetch( a.fetch 0 ) ; a.shift
          r.send m, a
        end

        def curry_field_builder field_class
          define_singleton_method caller_locations( 1, 1 )[ 0 ].base_label, &
            Add_to_fields_with_class_and_name_.curry[ field_box, field_class ]
          nil
        end
        #
        Add_to_fields_with_class_and_name_ = -> fields, klass, a, &blk do
          method_i = a.fetch( 0 ) ; a.shift
          fld = klass.new method_i, blk
          fields.add method_i, fld
          fld
        end

        # i just blue myself
      end

      class Procesque_ < Aspect_
        def initialize( * )
          @is_memoized = false
          super
        end
        attr_accessor :is_memoized
        def absorb client, a
          prock = a.fetch( 0 ) ; a.shift
          prock.respond_to? :call or fail "sanity - #{ prock.class }"
          client.instance_variable_set @ivar, prock
          nil
        end
      end

      class Proc_ < Procesque_
        def flush client
          ivar = @ivar
          if @is_memoized
            did = value = nil
            client.send :define_method, @method_i do
              if did then value else
                did = true
                value = instance_variable_get( ivar ).call  # etc
              end
            end
          else
            client.send :define_method, @method_i do
              instance_variable_get( ivar ).call  # etc
            end
          end
        end
      end

      class Method_ < Procesque_
        def flush client
          ivar = @ivar
          if @is_memoized
            did = value = nil
            client.send :define_method, @method_i do
              if did then value else
                did = true
                value = instance_exec( & instance_variable_get( ivar ) )
              end
            end
          else
            client.send :define_method, @method_i do
              instance_exec( & instance_variable_get( ivar ) )  # etc
            end
          end
        end
      end

    # [ `required` ] `field`s -
    #
    # failing to pass a required field triggers an argument error
    #
    #     class Foo
    #       MetaHell::FUN::Fields_::Contoured_[ self,
    #         :required, :field, :foo, :field, :bar ]
    #     end
    #
    #     Foo.new  # => ArgumentError: missing required argument - foo
    #
    # passing nil is considered the same as not passing an argument
    #
    #     Foo.new( :foo, nil )  # => ArgumentError: missing required argument - foo
    #
    # passing false is not the same as passing nil, passing false is valid.
    #
    #     Foo.new( :foo, false ).foo  # => false
    #
    # you can of course pass nil as the value for a non-required field
    #
    #     Foo.new( :foo, :x, :bar, nil ).bar  # => nil
    #

      class Field_ < Aspect_
        attr_writer :is_required  # not pushed up yet
        def flush client
          client.send :attr_reader, @method_i
        end
        def absorb client, a
          x = a.fetch 0 ; a.shift
          client.instance_variable_set @ivar, x
          nil
        end
      end

      class Glint_
      private
        def parse_required a
          curry_branch field: :parse_required_field
          parse_required a
          nil
        end
        def parse_field a
          add_field_with_name( a ).flush @client
          nil
        end
        def parse_required_field a
          add_field_with_name a do |fld|
            fld.is_required = true
          end.flush @client
          nil
        end
        def add_field_with_name a, &blk
          curry_field_builder Field_
          add_field_with_name a, &blk
        end
      end
    end
  end
end
