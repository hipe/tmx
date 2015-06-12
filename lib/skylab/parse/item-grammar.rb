module Skylab::Parse

  class Item_Grammar  # see [#005]

    class << self

      alias_method :__orig_new, :new

      def new adj_i_a, keyword_sym, pp_i_a

        ::Class.new( self ).class_exec do

          # const_set :ADJ_I_A__, adj_i_a.freeze

          const_set :ADJ_H___, ::Hash[ adj_i_a.map { |i| [ i, i ] } ].freeze

          const_set :Adj_Struct___, Sexp__.new( * adj_i_a )

          const_set :KW_SYM__, keyword_sym

          # const_set :PP_I_A__, pp_i_a.freeze

          const_set :PP_H___, ::Hash[ pp_i_a.map { |i| [ i, true ] } ].freeze

          const_set :PP_Struct___, Sexp__.new( * pp_i_a )

          const_set :SP_Struct___, ::Struct.new( :adj, :keyword_value_x, :pp )

          class << self
            alias_method :new, :__orig_new
            private :new
          end

          self
        end
      end

      # ~ singleton methods for subclasses

      def simple_stream_of_items_via_polymorpic_array x_a

        _st = Callback_::Polymorphic_Stream.via_array x_a

        simple_stream_of_items_via_polymorpic_stream _st
      end

      def simple_stream_of_items_via_polymorpic_stream _st

        new _st
      end
    end  # >>

    class Sexp__ < ::Struct

      # hack a struct to remember what keys were used in its making

      class << self
        def new * a
          if a.length.zero?
            EMPTY_NT___
          else
            super
          end
        end
      end

      def initialize( * )
        @_key_set = Parse_.lib_.stdlib_set.new
        super
      end

      def keys
        @_key_set.to_a
      end

      alias_method :struct_each_pair, :each_pair

      def each_pair & p
        if p
          @_key_set.each do | k |
            p[ [ k, self[ k ] ] ]
          end
        else
          enum_for __method__
        end
      end

      def []= k, x
        @_key_set.add? k
        super
      end
    end

    EMPTY_NT___ = :this_nonterminal_symbol_is_empty

    def initialize st

      gets_one = -> do  # assume token stream is not empty

        o = self.class

        adj_h = o::ADJ_H___
        adj_struct = o::Adj_Struct___

        keyword_sym = o::KW_SYM__

        pp_h = o::PP_H___
        pp_struct = o::PP_Struct___

        sp_struct = o::SP_Struct___

        adj_sct = nil

        # parse any adjectives

        begin

          if adj_h[ st.current_token ]

            adj_sct ||= adj_struct.new
            adj_sct[ st.gets_one ] = true
            if st.unparsed_exists
              redo
            end
          end
          break
        end while nil

        # parse the name

        if st.unparsed_exists && keyword_sym == st.current_token

          st.advance_one

          sp_sct = sp_struct.new adj_sct, keyword_sym

          pp_sct = nil

          # parse any prepositional phrases

          begin

            st.unparsed_exists or break

            if pp_h[ st.current_token ]

              pp_sct ||= pp_struct.new

              _k = st.gets_one

              pp_sct[ _k ] = st.gets_one

              redo
            end
            break
          end while nil

          if pp_sct
            sp_sct.pp = pp_sct
          end

          sp_sct

        elsif adj_sct

          raise ::ArgumentError, __say_failure( pp_h, adj_h, st )
        end
      end

      @__gets = -> do

        if st.no_unparsed_exists
          NIL_
        else
          gets_one[]
        end
      end

      NIL_
    end

    def gets
      @__gets.call
    end

    def __say_failure pp_h, adj_h, st

      y = []

      y << "encountered unrecognized token `#{ st.current_token }` #{
        }before reaching required token `#{ self.class::KW_SYM__ }`"

      if adj_h.length.nonzero?
        y << "an adjective among #{ adj_h.keys * ', ' }"
      end

      if pp_h.length.nonzero?
        y << "the start of a prepositional phrase from among (#{
          }#{ pp_h.keys * ', ' })"
      end

      y.join ' or '
    end
  end
end
