module Skylab::SearchAndReplace::TestSupport

  module SES::Block_Stream

    def self.[] tcc
      tcc.extend SES::Common_DSL::ModuleMethods
      tcc.include SES::Common_DSL::InstanceMethods
      tcc.send :define_singleton_method, :common_DSL_when_givens_are_given, This__
      tcc.include InstanceMethods
    end

    # -
      This__ = -> do
        yes = true ; a = nil
        define_method :block_array do
          if yes
            yes = false
            a = build_block_array_via_first_block build_first_block
          end
          a
        end
        super()
      end
    # -

    module InstanceMethods

      def build_block_array_via_first_block blk
        a = []
        begin
          a.push blk
          blk = blk.next_block
        end while blk
        a
      end

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

        _expect_atoms a
      end

      def expect_last_atoms_ * a
        _expect_atoms a
        end_expect_atoms_
      end

      def _expect_atoms a

        len = a.length
        a_ = @atoms[ @cursor, len ]
        @cursor += len

        if a_ != a  # eek

          raise ___say_arrays_not_equal a_, a
        end
      end

      def ___say_arrays_not_equal act_a, exp_a  # assume they are not equal.

        act_st = Common_::Scanner.via_array act_a
        exp_st = Common_::Scanner.via_array exp_a

        begin

          if exp_st.no_unparsed_exists
            x = "array was longer than expected. expected no item at index #{
             }#{ act_st.current_index }. (had #{
              }#{ act_st.head_as_is.inspect }.)"
            break
          end

          if exp_st.head_as_is == act_st.head_as_is
            act_st.advance_one
            exp_st.advance_one
            if act_st.no_unparsed_exists
              x = "array ended early. expected an item at index #{
                } #{ exp_st.current_index }. (expected #{
                 }#{ exp_st.head_as_is.inspect }.)"
              break
            end
            redo
          end

          x = "at index #{ act_st.current_index } expected #{
           }#{ exp_st.head_as_is.inspect }, had #{
            }#{ act_st.head_as_is.inspect }."
          break
        end while nil
        x
      end

      def end_expect_atoms_
        @atoms.length == @cursor or fail
      end

      # ~

      def atoms_of_ block
        block.to_throughput_atom_stream_.to_a
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
