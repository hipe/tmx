module Skylab::MetaHell

  module FUN

    module Fields_::Contoured_

      def self.[] client, *a
        Front_.new( client ).absorb( a ).flush
      end

      class Front_

        def initialize c
          @client = c
          @fields = MetaHell::Services::Basic::Box.new
        end

        def absorb a
          begin
            send H_.fetch( a.shift ), a
          end while a.length.nonzero?
          self
        end
        H_ = { proc: :parse_proc,
               memoized: :parse_memoized }.freeze

        def flush
          @client.send :define_method, :initialize, & Absorb_
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

        def parse_memoized a
          m = PMH_.fetch( a.fetch 0 ) ; a.shift
          send m, a
        end
        PMH_ = { proc: :create_memoized_proc }.freeze

        def parse_proc a  # is also `create_nonmemoized_proc` ..
          i = a.fetch( 0 ) ; a.shift
          @fields.add i, (( fld = Proc_.new i ))
          ivar = fld.ivar
          @client.send :define_method, i do
            instance_variable_get( ivar ).call
          end
          nil
        end

        def create_memoized_proc a
          i = a.fetch( 0 ) ; a.shift
          @fields.add i, (( fld = Proc_.new i, true ))
          ivar = fld.ivar
          did_once = false ; the_value = nil
          @client.send :define_method, i do
            if did_once then the_value else
              did_once = true
              the_value = instance_variable_get( ivar ).call
            end
          end
        end

        class Proc_
          def initialize i, is_memoized=false
            @name_i = i
            @ivar = :"@#{ i }"
            @is_memoized = is_memoized
            freeze
          end
          attr_reader :name_i, :ivar, :is_memoized
          def absorb instance, a
            x = a.fetch( 0 ) ; a.shift
            instance.instance_variable_set @ivar, x
            nil
          end
        end
      end
    end
  end
end
