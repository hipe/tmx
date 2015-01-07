module Skylab::Headless

  module Name  # read [#152] the name narrative  # #storypoint-5

    class << self

      def simple_chain
        Simple_Chain__
      end

      def variegated_human_symbol_via_variable_name_symbol name_i
        s = name_i.id2name
        Mutate_string_by_chomping_any_trailing_name_convention_suffixes__[ s ]
        s.downcase.intern
      end

      def via_module_name_anchored_in_module_name s, s_
        Via_anchored_in_module_name_module_name__[ s_, s ]
      end
    end

    # #storypoint-10

      Labelize__ = -> do  # :+[#088]
        -> ivar_i do
          s = ivar_i.id2name
          Mutate_string_by_chomping_any_leading_at_character___[ s ]
          Mutate_string_by_chomping_any_trailing_name_convention_suffixes__[ s ]
          s.gsub! UNDERSCORE_, SPACE_
          Ucfirst___[ s ]
        end
      end.call

      Mutate_string_by_chomping_any_leading_at_character___ = -> do
        rx = /\A@/
        -> s do
          s.sub! rx, EMPTY_S_ ; nil
        end
      end.call

      Mutate_string_by_chomping_any_trailing_name_convention_suffixes__ = -> do
        rx = /(?<=[a-z]{2}) (?:  (?:_[a-z])+_* | _+  )  \z/ix
        -> s do
          s.sub! rx, EMPTY_S_ ; nil
        end
      end.call

      Ucfirst___ = -> do
        rx = /\A[a-z]/
        -> s do
          s.sub rx, & :upcase
        end
      end.call

      Module_moniker___ = -> num_parts, mod do
        s_a = mod.name.split CONST_SEP_
        _s_a_ = if ! num_parts then s_a
        elsif num_parts.respond_to? :cover?
          s_a[ num_parts ]
        elsif num_parts.zero?
          EMPTY_A_
        else
          s_a[ - num_parts .. -1 ]  # whether positive or negative
        end
        _s_a_.map do |s|
          Callback_::Name.via_const( s.intern ).as_human
        end * TERM_SEPARATOR_STRING_
      end

      Module_moniker__ = Module_moniker___.curry[ 1 ]


    o = -> i, p do
      define_singleton_method i do | * a |
        if a.length.zero?
          p
        else
          p[ * a ]
        end
      end
    end

    o[ :labelize, Labelize__ ]

    o[ :module_moniker, Module_moniker___ ]


      Via_anchored_in_module_name_module_name__ = -> s, s_ do  # #storypoint-105  # :+#curry-friendly

        # the first arg is the one that existed first - the surrounding module

        if 0 == s_.index( s )
          Simple_Chain__.new(
            if s == s_
              EMPTY_A_
            else
              s_[ s.length + 2 .. -1 ].split( CONST_SEP_ ).reduce [] do | m, c |
                m.push Callback_::Name.via_const c.intern
                  # freeze each name because we expose them individually
              end
            end )
        end
      end

      class Simple_Chain__  # #storypoint-55

        class << self

          def via_symbol_list name_i_a
            new( name_i_a.map do | sym |
              Callback_::Name.via_variegated_symbol sym
            end )
          end
        end

        def initialize a  # please provide an array of name functions
          @name_a = a ; nil
        end

        def length
          @name_a.length
        end

        def local
          @name_a.last
        end

        def map sym  # for now we protect constituents by doing it like this
          @name_a.map(& sym )
        end

        def anchored_normal
          @anchored_normal ||= @name_a.map( & :as_variegated_symbol ).freeze
        end
      end

  end
end
