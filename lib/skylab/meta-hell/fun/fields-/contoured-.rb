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
      #                              :bar, -> { "y:#{ @ohai } },
      #                              :bif, -> { "_#{ foo }_" },
      #                              :baz, -> { "<#{ foo }>" } )
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
        }.freeze

        def flush
          m = ( @absorber_method_name || :initialize )
          @client.send :define_method, m, & Absorb_
          @client.const_set :FIELDS_CONTOURED_, @fields
          nil
        end
        Absorb_ = -> *a do
          bx = self.class::FIELDS_CONTOURED_
          while a.length.nonzero?
            fld = bx.fetch a.shift
            fld.absorb self, a
          end
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

        class Procesque_
          def initialize method_i, block
            @method_i = method_i
            @is_memoized = false
            @ivar = :"@#{ method_i }"
            block and block[ self ]
            freeze  # or not
          end
          attr_reader :method_i
          attr_accessor :is_memoized
          def absorb client, a
            prock = a.fetch( 0 ) ; a.shift
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
  end
end
