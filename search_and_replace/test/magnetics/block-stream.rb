module Skylab::SearchAndReplace::TestSupport

  module Magnetics::Block_Stream

    def self.[] tcc
      tcc.send :define_singleton_method, :given, Given___
      tcc.include self
    end

    # -

      Given___ = -> & p do

        yes = true ; a = nil
        define_method :block_array do
          if yes
            yes = false
            a = []
            blk = self.build_first_block
            begin
              a.push blk
              blk = blk.next_block
            end while blk
          end
          a
        end

        define_method :build_first_block do  # public for debugging
          instance_exec( & p )
          __build_first_block
        end
      end

    # -
    # -

      # -- DSL (we intentionally mimic that other one)

      def rx rx
        @__rx = rx
      end

      def str s
        @__str = s
      end

      # --

      lib = -> do
        lib = nil
        Build_match_stream__ = Magnetics::Build_match_scanner_
        Build_line_stream__ = Magnetics::Build_line_scanner_
        Block__ = Magnetics::Lib_[]::Block___  # Block_
        NIL_
      end

      define_method :__build_first_block do

        lib && lib[]

        _rx = remove_instance_variable :@__rx
        s = remove_instance_variable :@__str

        _match_st = Build_match_stream__[ s, _rx ]

        _line_st = Build_line_stream__[ s ]

        _ = Block__::Ingredients.new _line_st, _match_st, nil

        Block__.via_ingredients__ _
      end

      # -- assertion

      def atoms_of_ block
        block.___to_throughput_atom_stream.to_a
      end

      def at_ d
        block_at_( d ).has_matches ? :M : :S  # S = "static"
      end

      def block_at_ d
        block_array.fetch d
      end

      def block_count_
        block_array.length
      end

    # -
  end
end
