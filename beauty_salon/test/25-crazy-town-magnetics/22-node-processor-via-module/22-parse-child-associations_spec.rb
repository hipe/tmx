require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - parse child associations', ct: true do

    TS_[ self ]
    use :memoizer_methods

    it %q{you wouldn't know it by looking, but defs are eval'd lazily} do

        _build_subclass_with_these_children( :XX1,
          :zzz_zib_zab_zabunga,
          :qqq_quntio_finto_fafoofa,
        ) or fail
    end

    context '(is any)' do

      it 'parse the assocs' do
        2 == _assocs.length || fail
      end

      it 'first one knows it is yes any' do
        _assocs.first.is_any || fail
      end

      it 'second one knows it is not any' do
        _assocs.last.is_any && fail
      end

      def _class
        _feature_branch.dereference :fajozie_flozie
      end

      shared_subject :_feature_branch do

        _cls = _build_subclass_with_these_children( :XX2,
          :any_lefty_expression,
          :righty_expression,
        )
        _build_subject_branch :ThisOneGuy, _cls, :FajozieFlozie
      end
    end

    context '(plural arities)' do

      it 'first one knows it *does* have plural arity' do
        _asc = _assocs.first
        _asc.has_plural_arity || fail
      end

      it 'second one knows it does *not* have plural arity' do
        _asc = _assocs.last
        _asc.has_plural_arity && fail
      end

      def _class
        _feature_branch.dereference :misra_topeka
      end

      shared_subject :_feature_branch do

        _cls = _build_subclass_with_these_children( :XX3,
          :one_or_more_wazoogle_expressions,
          :wazingle_expressions,
        )
        _build_subject_branch :ThisOtherGuy, _cls, :MisraTopeka
      end
    end

    context '(groups) (ROUGH SKETCH)' do

      it 'voila' do
        a = _assocs
        h = a.first.group_INFORMATION
        h[ :jimmy1 ] || fail
        h[ :jimmy2 ] || fail
        h = a.last.group_INFORMATION
        h[ :jimmy3 ] || fail
        h[ :jimmy4 ] || fail
      end

      def _class
        _feature_branch.dereference :chamunkulous_bunkulous
      end

      shared_subject :_feature_branch do

        _cls = _build_subclass_with_these_children( :XX4,
          :wiz_bang_chiz_bang_wadunkulouz,
          :miz_bang_shiz_band_chadunkulouz,
        )
        _build_subject_branch :ThisThirdGuy, _cls, :ChamunkulousBunkulous do
          self::GROUPS = {
            wadunkulouz: [
              :jimmy1,
              :jimmy2,
            ],
            chadunkulouz: [
              :jimmy3,
              :jimmy4,
            ],
          }
        end
      end
    end

    def _assocs
      _assocs_index.associations
    end

    def _assocs_index
      _class.children_association_index
    end

    def _build_subject_branch c, cls, c2, & p

      mod = ::Module.new
      X_ctm_npvm_pca.const_set c, mod
      mod_ = ::Module.new
      mod.const_set :Items, mod_
      mod.const_set :IRREGULAR_NAMES, nil
      mod_.const_set c2, cls

      if p
        mod.module_exec( & p )
      end

      _subject_magnetic[ mod ]
    end

    def _build_subclass_with_these_children c, * sym_a

      cls = ::Class.new _subject_base_class
      X_ctm_npvm_pca.const_set c, cls
      cls.class_exec do
        children( * sym_a )
      end
      cls
    end

    def _subject_base_class
      _subject_magnetic::GrammarSymbol
    end

    def _subject_magnetic
      Home_::CrazyTownMagnetics_::NodeProcessor_via_Module
    end

    X_ctm_npvm_pca = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
