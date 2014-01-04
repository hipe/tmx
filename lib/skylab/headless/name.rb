module Skylab::Headless

  module Name  # read [#152] the name narrative  # #storypoint-5

    module FUN  # #storypoint-10

      Local_normal_name_from_module = -> mod do
        Normify[ Const_basename[ mod.name ] ]
      end

      Const_basename = -> name_s do
        idx = name_s.rindex COLON_
        idx ? name_s[ idx + 1 .. -1 ] : name_s
      end

      Constantify = -> do  # make a normalized symbol look like a const
        rx = /(?:^|[-_])([a-z])/
        -> x { x.to_s.gsub( rx ) { $~[1].upcase } }
      end.call

      Labelize = -> do  # :+[#088]
        rx =  /\A@|_[a-z]\z/ ; rx_ = /\A[a-z]/
        -> i do
          i.to_s.gsub( rx, EMPTY_STRING_ ).
            gsub( UNDERSCORE_, TERM_SEPARATOR_STRING_ ).sub( rx_, & :upcase )
        end
      end.call

      Metholate = -> i do  # in case your normal is a slug for some reason
        i.to_s.gsub DASH_, UNDERSCORE_
      end

      Module_moniker_ = -> num_parts, mod do
        s_a = mod.name.split DOUBLE_COLON_
        _s_a_ = if ! num_parts then s_a
        elsif num_parts.respond_to? :cover?
          s_a[ num_parts ]
        elsif num_parts.zero?
          MetaHell::EMPTY_A_
        else
          s_a[ - num_parts .. -1 ]  # whether positive or negative
        end
        _s_a_.map do |s|
          Naturalize[ Normify[ s ] ]
        end * TERM_SEPARATOR_STRING_
      end

      Module_moniker = Module_moniker_.curry[ 1 ]

      Naturalize = -> do  # for normals only. handle dashy normals
        rx = %r([-_])
        -> i do
          i.to_s.gsub rx, TERM_SEPARATOR_STRING_
        end
      end.call

      Normify = -> do  # make a const-looking string be normalized. :+[#081]
        rx = /(?<=[a-z])(?=[A-Z])|_|(?<=[A-Z])(?=[A-Z][a-z])/
        -> x do
          x.to_s.gsub( rx ) { UNDERSCORE_ }.downcase.intern
        end
      end.call

      Slugulate = -> i do  # for normals only. centralize this simple transform.
        i.to_s.gsub UNDERSCORE_, DASH_
      end
    end

    COLON_ = ':'.freeze ; DASH_ = '-'.freeze ;
    DOUBLE_COLON_ = '::'.freeze ; UNDERSCORE_ = '_'.freeze

    class Function

      def initialize local_normal_i
        @local_normal = local_normal_i
      end

      attr_reader :local_normal

      include module InstanceMethods

        def as_const
          Name::FUN::Constantify[ local_normal ].intern
        end

        def as_method  # #storypoint-15
          Name::FUN::Metholate[ local_normal ].intern
        end

        def as_natural
          Name::FUN::Naturalize[ local_normal ]
        end

        def as_slug
          Name::FUN::Slugulate[ local_normal ]
        end

        self
      end

      def self.from_const const_s
        self::From::Constant.new const_s
      end

      From = ::Module.new

      class From::Constant < self  # #storypoint-30

        def self.from_name const_name_s
          new FUN::Const_basename[ const_name_s ].intern
        end

        def initialize const_i  # symbol! :[#032] :+#API-lock this signature.
          @const = const_i
          @local_normal = Headless::Name::FUN::Normify[ const_i ] ; nil
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
          [ @const, @local_normal ]
        end
      private
        def init_copy const_i, local_normal_i
          @const = const_i ; @local_normal = local_normal_i ; nil
        end
        # ~

      public

        alias_method :local_slug, :as_slug

        def as_const
          @const
        end
      end

      class Full  # #storypoint-55

        def self.from_normalized_name_path a
          new a.map( & Function.method( :new ) )
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

      class From::Module_Anchored <  Full  # #storypoint-105

        def initialize n2, n1  # n2 - your module name  n1 - box module name
          0 == n2.index( n1 ) or raise "sanity - #{ n1 } does not contain #{ n2 }"
          name_a = if n2 == n1
            EMPTY_A_
          else
            n2[ n1.length + 2 .. -1 ].split( '::' ).reduce [] do |m, c|
              m << Name::Function::From::Constant.new( c ).freeze
            end  # we freeze b.c we reveal the elements
          end
          super name_a
          nil
        end
      end
    end
  end
end
