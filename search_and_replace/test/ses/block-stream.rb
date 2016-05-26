module Skylab::SearchAndReplace::TestSupport

  module SES::Block_Stream

    def self.[] tcc
      tcc.extend SES::Common_DSL::ModuleMethods
      tcc.include SES::Common_DSL::InstanceMethods
      tcc.send :define_singleton_method, :common_DSL_when_givens_are_given, This__
      tcc.include Instance_Methods__
    end

    # -
      This__ = -> do
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
        super()
      end
    # -

    module Instance_Methods__

      def build_first_block  # public for debugging
        instance_exec( & common_DSL_given_proc )
        __build_first_block
      end

      lib = -> do
        lib = nil
        Build_match_stream__ = SES::Build_match_scanner
        Build_line_stream__ = SES::Build_line_scanner
        Block__ = SES::Asset[]::Block_
        NIL_
      end

      define_method :__build_first_block do

        lib && lib[]

        _rx = remove_instance_variable :@common_DSL_given_regex
        s = remove_instance_variable :@common_DSL_given_string

        _match_st = Build_match_stream__[ s, _rx ]

        _line_st = Build_line_stream__[ s ]

        _ = Block__::Ingredients.new _line_st, _match_st, nil

        Block__.via_ingredients__ _
      end

      # -- assertion

      # ~

      def begin_expect_atoms_for_ a
        @atoms = a
        @cursor = 0
      end

      def expect_atoms_ * a

        len = a.length
        a_ = @atoms[ @cursor, len ]
        @cursor += len

        if a_ != a  # eek
          a_.should eql a
        end
      end

      def end_expect_atoms_
        @atoms.length == @cursor or fail
      end

      # ~

      def atoms_of_ block
        block.___to_throughput_atom_stream.to_a
      end

      def at_ d
        block_at_( d ).has_matches ? :M : :S  # S = "static"
      end

      def first_block_
        block_array.fetch 0
      end

      def block_at_ d
        block_array.fetch d
      end

      def block_count_
        block_array.length
      end
    end
  end
end
