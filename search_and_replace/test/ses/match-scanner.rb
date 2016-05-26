module Skylab::SearchAndReplace::TestSupport

  module SES::Match_Scanner  # 1x

    def self.[] tcc
      tcc.send :define_singleton_method, :given, Given___
      tcc.include self
    end

    # -
      Given___ = -> & p do

        yes = true ; x = nil
        define_method :match_scanner_array do

          if yes
            yes = false
            instance_exec( & p )
            x = __build_match_scanner_array
          end
          x
        end
      end
    # -

    # -

      # -- DSL

      def rx rx
        @__rx = rx
      end

      def str s
        @__str = s
      end

      # --

      def matches_count
        match_scanner_array.length
      end

      def __build_match_scanner_array

        _rx = remove_instance_variable :@__rx
        _s = remove_instance_variable :@__str

        ms = SES::Build_match_scanner[ _s, _rx ]

        a = []
        begin
          x = ms.gets
          x or break
          a.push x
          redo
        end while nil
        a
      end

    # -
  end
end
