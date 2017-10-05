require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - parse child associations', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_THIS_STUFF

    it %q{you wouldn't know it by looking, but defs are eval'd lazily} do

        build_subclass_with_these_children_( :XX1,
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

        _cls = build_subclass_with_these_children_( :XX2,
          :any_lefty_expression,
          :righty_expression,
        )
        build_subject_branch_ _cls, :FajozieFlozie, :ThisOneGuy
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

        _cls = build_subclass_with_these_children_( :XX3,
          :one_or_more_wazoogle_expressions,
          :wazingle_expression,
        )
        build_subject_branch_ _cls, :MisraTopeka, :ThisOtherGuy
      end
    end

    context '(groups) (ROUGH SKETCH)' do

      it 'voila' do
        a = _assocs
        h = a.first.group_information
        h[ :jimmy1 ] || fail
        h[ :jimmy2 ] || fail
        h = a.last.group_information
        h[ :jimmy3 ] || fail
        h[ :jimmy4 ] || fail
      end

      def _class
        _feature_branch.dereference :chamunkulous_bunkulous
      end

      shared_subject :_feature_branch do

        _cls = build_subclass_with_these_children_( :XX4,
          :wiz_bang_chiz_bang_wadunkulouz,
          :miz_bang_shiz_band_chadunkulouz,
        )
        build_subject_branch_ _cls, :ChamunkulousBunkulous, :ThisThirdGuy do
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

    def sandbox_module_
      X_ctm_npvm_pca
    end

    X_ctm_npvm_pca = ::Module.new  # const namespace for tests in this file
  end
end
# #pending-rename: perhaps remove "child" from the name for consistency
# #born.
