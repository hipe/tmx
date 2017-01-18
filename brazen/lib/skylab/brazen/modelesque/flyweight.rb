module Skylab::Brazen

  Modelesque::Flyweight = ::Module.new

  # ->

    class Modelesque::Flyweight::Property_Box

      # if iterating over a dataset, only allocate memory when you chose to

      def initialize unbound

        @_h = nil
        @_hash_is_mine = false

        symbol_to_string_h = {}
        unbound.properties.get_keys.each do |i|
          symbol_to_string_h[ i ] = i.id2name
        end

        @_SHARED_symbol_to_string = symbol_to_string_h
      end

      def initialize_copy _

        unless @_hash_is_mine
          @_h = @_h.dup
          @_hash_is_mine = true
        end
        NIL_
      end

      def [] sym

        s = @_SHARED_symbol_to_string[ sym ]
        s and @_h[ s ]
      end

      def fetch sym, & p

        s = @_SHARED_symbol_to_string[ sym ]
        if s
          @_h.fetch s, & p
        elsif p
          p[]
        else
          raise ::KeyError, __say_key_error( sym )
        end
      end

      def __say_key_error sym
        "key not found: '#{ sym }'"
      end

      def replace_name_in_hash s

        if @_h
          @_hash_is_mine = false
        else
          @_h = {}
          @_hash_is_mine = false
          # the hash still isn't yours - you're a flyweight
        end

        @_h[ NAME_S___ ] = s

        NIL_
      end

      NAME_S___ = NAME_SYMBOL.id2name

      def replace_hash h

        @_hash_is_mine = true
        @_h = h
        NIL_
      end
    end
    # <-
end
