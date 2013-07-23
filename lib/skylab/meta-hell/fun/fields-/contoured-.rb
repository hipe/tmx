module Skylab::MetaHell

  module FUN

    module Fields_::Contoured_

      # use it
      # like so:
      #
      #     class Foo
      #       MetaHell::FUN::Fields_::Contoured_[ self,
      #         :absorber_method_name, :absorb,
      #         :proc, :foo,
      #         :memoized, :proc, :bar,
      #         :method, :bif,
      #         :memoized, :method, :baz ]
      #     end
      #
      #     f = Foo.new ; f.absorb( :foo, -> { :yes } ) ; f.foo  # => :yes
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

      def self.[] client, *a
        Front_.new( client ).absorb( a ).flush
      end

      class Front_

        def initialize c
          @client = c
          @absorber_method_name = nil
          @fields = MetaHell::Services::Basic::Box.new
        end

        def absorb a
          begin
            send FRONT_H_.fetch( a.shift ), a
          end while a.length.nonzero?
          self
        end
        FRONT_H_ = {
          absorber_method_name: :parse_absorber_method_name,
          proc: :parse_proc,
          memoized: :parse_memoized,
          method: :parse_method,
          required: :parse_required,
          field: :parse_field
        }.freeze

        def flush
          m = ( @absorber_method_name || :initialize )
          @client.const_set :FIELDS_CONTOURED_, @fields
          Define_absorber_methods_[ @client, m ]
          nil
        end

        Define_absorber_methods_ = -> client, absorber_method_name do
          client.class_exec do
            define_method absorber_method_name, & Absorb_method_
            define_method :post_absorb_notify, & Required_fields_check_method_
          end
          nil
        end

        Absorb_method_ = -> *a do
          bx = self.class::FIELDS_CONTOURED_
          while a.length.nonzero?
            fld = bx.fetch a.shift
            fld.absorb self, a
          end
          post_absorb_notify
          nil
        end

        Required_fields_check_method_ = -> do
          bx = self.class::FIELDS_CONTOURED_
          miss_a = bx._a.reduce [] do |m, method_i|
            (( fld = bx.fetch method_i )).is_required or next m
            instance_variable_defined? fld.ivar and
              ! instance_variable_get( fld.ivar ).nil? and next m
            m << fld
          end
          miss_a.length.nonzero? and
            Missing_required_fields_notify_[ self, miss_a ]
          nil
        end

        Missing_required_fields_notify_ = -> client, miss_a do
          s, op, cp = 1 == miss_a.length ? MetaHell::EMPTY_A_ : %w[ s ( ) ]
          raise ::ArgumentError, "missing required argument#{ s } - #{ op }#{
            }#{ miss_a.map( & :method_i ) * ', ' }#{ cp }"
          nil
        end

      private

        def parse_absorber_method_name a
          m = a.fetch( 0 ) ; a.shift
          @absorber_method_name = m
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
          loc = caller_locations( 1, 1 )[ 0 ]
          define_singleton_method loc.base_label, &
            Branch_.curry[ self, h ]
          nil
        end

        Branch_ = -> r, h, a do
          m = h.fetch( a.fetch 0 ) ; a.shift
          r.send m, a
        end

        def curry_field_builder field_class
          bn = caller_locations( 1, 1 )[ 0 ].base_label
          define_singleton_method bn, &
            Add_to_fields_with_class_and_name_.curry[ @fields, field_class ]
          nil
        end

        Add_to_fields_with_class_and_name_ = -> fields, klass, a, &blk do
          method_i = a.fetch( 0 ) ; a.shift
          fld = klass.new method_i, blk
          fields.add method_i, fld
          fld
        end

        # i just blue myself

        class Aspect_
          def initialize method_i, block
            @method_i = method_i
            @ivar = :"@#{ method_i }"
            block and block[ self ]
            freeze  # or not
          end
          attr_reader :method_i, :ivar
          attr_reader :is_required  # where available
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
    #     Foo.new  # => ArgumentError: missing required argument - foo
    #
    # passing false is not the same as passing nil, passing false is valid.
    #
    #     Foo.new( :foo, false ).foo  # => false
    #
    # you can of course pass nil as the value for a non-required field
    #
    #     Foo.new( :foo, :x, :bar, nil ).bar  # => nil
    #

    module Fields_::Contoured_
      class Front_
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
