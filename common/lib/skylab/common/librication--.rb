module Skylab::Common

  class Librication__

    # generate a class for building a "shell" object to provide a more
    # conventional- (and less shouty-) looking interaction with our
    # now ubiquitous internal library ("Lib_") modules.

    class << self

      def [] lib_mod, top_mod
        if ! top_mod.const_defined? CONST__, false
          new( lib_mod, top_mod ).execute
        end
        top_mod.const_get( CONST__, false ).new
      end
    end

    CONST__ = :Library_Shell___

      def initialize * a
        @lib_mod, @top_mod = a
      end

      def execute
        lib = @lib_mod
        cls = @top_mod.const_set CONST__, ::Class.new

        cls.send :define_method, :members do  # meh
          self.class.public_instance_methods( false ) - [ :members ]
        end

        i_a = lib.constants
        d = i_a.length
        while d.nonzero?
          d -= 1
          const_i = i_a.fetch d
          const_s = const_i.id2name
          UNDERSCORE_BYTE__ == const_s.getbyte( -1 ) and next
          md = CONVERT_RX__.match const_s
          cls.send(
            :define_method,
            if md
              s = md[ :typical ]
              if s
                "#{ s.downcase }#{ md.post_match }".intern
              else
                "a_#{ md.post_match }".intern  # indefinite
              end
            else
              const_i
            end,
            lib.const_get( const_i, false ) )
        end
        cls
      end

      CONVERT_RX__ = %r(\A (?:
        (?<typical> [A-Z] (?= [a-z] ) ) |
        (?<indef>    A_ )
      ) )x

      UNDERSCORE_BYTE__ = UNDERSCORE_.getbyte 0
  end
end
