require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - association terminal read write', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    it 'builds (use `via_node_)' do
      _this_one_structured_node || fail
    end

    it 'the first child - read it straightforwardly (the receiver) (one recurse happens)' do
      _first_recursion || fail
    end

    context 'the second child - read the terminal. uses just the stem name' do

      it 'works' do
        _second_child || fail
      end

      it 'is just the symbol - is NOT wrapped in anything' do
        _second_child == :foo || fail
      end
    end

    context 'EXPERIMENT - the list proxy' do

      it 'produces a crazy wrapper doo-hah' do
        _subject || fail
      end

      it 'you can know the length' do
        _subject.length == 2 || fail
      end

      it 'you can have random access (guy is memoized) (guy is structured child)' do
        o = _subject
        x1 = o.dereference 1
        x1 || fail
        x2 = o.dereference 1
        x2 || fail
        x2.object_id == x1.object_id || fail

        _x = x2.valuu
        _x == 3 || fail
      end

      def _subject
        _this_listy_child
      end
    end

    context 'write a new primitive value to the terminal' do

      it 'new guy is produced' do
        _new_guy || fail
      end

      it 'the new guy has the new primitive value (accessed with stem name)' do
        _new_guy.methodo_nameo == :zing_zang || fail
      end

      shared_subject :_new_guy do
        _guy = _this_one_structured_node
        _guy.new_by do |o|
          o.methodo_nameo = :zing_zang
        end
      end
    end

    shared_subject :_this_listy_child do
      _guy = _this_one_structured_node
      _guy.zero_or_more_argumentoso_expressions
    end

    shared_subject :_second_child do
      _guy = _this_one_structured_node
      _guy.methodo_nameo
    end

    shared_subject :_first_recursion do
      _guy = _this_one_structured_node
      _guy.receiverosa_expression
    end

    shared_subject :_this_one_structured_node do
      _ast = vendor_node_via_string_ '1.foo 2, 3'
      _cls = _this_one_class
      _cls.via_node_ _ast
    end

    # ~( NOTE - copy-paste-modify of previous test!

    def _this_one_class
      _this_one_feature_branch.dereference :sendoid
    end

    shared_subject :_this_one_feature_branch do

      _cls = build_subclass_with_these_children_( :XX1,
        :receiverosa_expression,
        :methodo_nameo_zymbol_terminal,
        :zero_or_more_argumentoso_expressions,
      )

      _cls2 = build_subclass_with_these_children_( :XX2,
        :valuu_TYPENOTCOVERED2_terminal,
      )

      build_subject_branch_(
        _cls, :Sendoid,
        _cls2, :Int,
        :ThisOneGuy,
      ) do
        self::TERMINAL_TYPE_SANITIZERS = {
          zymbol: -> x do  # MONADIC_TRUTH_
            true  # hi.
          end,
        }
      end
    end

    # ~)

    def sandbox_module_
      X_ctm_npvm_atrw
    end

    X_ctm_npvm_atrw = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
