module Skylab::Headless

  class Name  # read [#152] the name narrative  # #storypoint-5

    class << self

      def qualified
        Qualified__
      end

      def humanize s
        s = s.dup
        Mutate_camelcase_string_by_humanizing__[ s ]
        s
      end

      def instance_methods
        I_M_Legacy_Compat__
      end

      def variegated_human_symbol_via_variable_name_symbol name_i
        s = name_i.id2name
        Mutate_string_by_chomping_any_trailing_name_convention_suffixes__[ s ]
        s.downcase.intern
      end

      def via_module_name_anchored_in_module_name s, s_
        Via_anchored_in_module_name_module_name__[ s_, s ]
      end

      def via_const * a
        if a.length.zero?
          Via_Const__
        else
          Via_Const__.new( a.shift.intern, * a )
        end
      end

      def via_symbol i
        Name_.new i
      end
    end

    # #storypoint-10

      Local_normal_name_from_module__ = -> mod do
        Normify__[ Const_basename__[ mod.name ] ]
      end

      Const_basename__ = -> name_s do
        idx = name_s.rindex COLON_
        idx ? name_s[ idx + 1 .. -1 ] : name_s
      end

      Constantify__ = -> do  # make a normalized symbol look like a const
        rx = /(?:^|[-_])([a-z])/
        -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
      end.call

      Labelize__ = -> do  # :+[#088]
        -> ivar_i do
          s = ivar_i.id2name
          Mutate_string_by_chomping_any_leading_at_character__[ s ]
          Mutate_string_by_chomping_any_trailing_name_convention_suffixes__[ s ]
          s.gsub! UNDERSCORE_, SPACE_
          Ucfirst__[ s ]
        end
      end.call

      Mutate_camelcase_string_by_humanizing__ = -> do
        rx = /([a-z])([A-Z])/
        -> s do
          s.gsub!( rx ) { "#{ $1 }#{ SPACE_ }#{ $2 }" }
          s.downcase! ; nil
        end
      end.call

      Mutate_string_by_chomping_any_leading_at_character__ = -> do
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

      Ucfirst__ = -> do
        rx = /\A[a-z]/
        -> s do
          s.sub rx, & :upcase
        end
      end.call

      Metholate__ = -> i do  # in case your normal is a slug for some reason
        i.to_s.gsub DASH_S_, UNDERSCORE_
      end

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
          Naturalize__[ Normify__[ s ] ]
        end * TERM_SEPARATOR_STRING_
      end

      Module_moniker__ = Module_moniker___.curry[ 1 ]

      Naturalize__ = -> i do  # for normals only. handle dashy or underscored normals
        s = i.id2name
        Mutate_string_by_humanizing_word_separators__[ s ]
        s
      end

      Mutate_string_by_humanizing_word_separators__ = -> do
        rx = %r([-_])
        -> s do
          s.gsub! rx, SPACE_
          nil
        end
      end.call

      Normify__ = -> do  # make a const-looking string be normalized. :+[#081]
        rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
        -> x do
          x.to_s.gsub( rx ) { UNDERSCORE_ }.downcase.intern
        end
      end.call

      Slugulate__ = -> i do  # for normals only. centralize this simple transform.
        i.to_s.gsub UNDERSCORE_, DASH_S_
      end

    o = -> i, p do
      define_singleton_method i do | * a |
        if a.length.zero?
          p
        else
          p[ * a ]
        end
      end
    end

    o[ :const_basename, Const_basename__ ]

    o[ :constantify, Constantify__ ]

    o[ :labelize, Labelize__ ]

    o[ :local_normal_name_from_module, Local_normal_name_from_module__ ]

    o[ :metholate, Metholate__ ]

    o[ :module_moniker, Module_moniker___ ]

    o[ :naturalize, Naturalize__ ]

    o[ :normify, Normify__ ]

    o[ :slugulate, Slugulate__ ]

    DASH_S_ = '-'.freeze ;  # there is another 'DASH_'

    UNDERSCORE_ = '_'.freeze

      def initialize local_normal_i
        @local_normal_i = local_normal_i
      end

      def local_normal
        @local_normal_i
      end

        def as_const
          Constantify__[ @local_normal_i ].intern
        end

        def as_method  # #storypoint-15
          Metholate__[ @local_normal_i ].intern
        end

        def as_natural
          Naturalize__[ @local_normal_i ]
        end

        def as_slug
          Slugulate__[ @local_normal_i ]
        end

      class Via_Const__ < self  # #storypoint-30

        class << self

          def via_module_name const_name_s
            new Const_basename__[ const_name_s ].intern
          end
        end

        def initialize const_i  # symbol! :[#032] :+#API-lock this signature.
          @const_i = const_i
          @local_normal_i = Normify__[ const_i ] ; nil
        end

        # ~ :+[#mh-021] typical base class implementation:
        def dupe
          dup
        end
        def initialize_copy otr
          init_copy( * otr.get_args_for_copy ) ; nil
        end
      protected
        def get_args_for_copy
          [ @const, @local_normal_i ]
        end
      private
        def init_copy const_i, local_normal_i
          @const = const_i ; @local_normal_i = local_normal_i ; nil
        end

        # ~

      public

        alias_method :local_slug, :as_slug

        def as_const
          @const_i
        end
      end

      Via_anchored_in_module_name_module_name__ = -> s, s_ do  # #storypoint-105  # :+#curry-friendly

        # the first arg is the one that existed first - the surrounding module

        if 0 != s_.index( s )
          raise "sanity - #{ s } does not contain #{ s_ }"
        end

        _name_a = if s == s_
          EMPTY_A_
        else
          s_[ s.length + 2 .. -1 ].split( CONST_SEP_ ).reduce [] do |m, c|
            m.push Via_Const__.new( c.intern ).freeze
            # freeze each name because we expose them individually
          end
        end

        Qualified__.new _name_a
      end

      class Qualified__  # #storypoint-55

        class << self

          def via_symbol_list name_i_a
            _name_a = name_i_a.map do |i|
              Name_.new i
            end
            new _name_a
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
          @anchored_normal ||= @name_a.map(& :local_normal ).freeze
        end
      end

    module I_M_Legacy_Compat__
    end

    Name_ = self

  end
end
