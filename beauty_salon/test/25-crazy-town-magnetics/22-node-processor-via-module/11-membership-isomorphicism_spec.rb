require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - membership', ct: true do

    TS_[ self ]
    use :memoizer_methods

    it '(subject magnetic loads)' do
      _subject_magnetic || fail
    end

    context '(c1)' do

      it 'man town builds around guy' do
        _man_town || fail
      end

      it 'read an item' do
        _deref :joomie or fail
      end

      it 'the names isomorph in this way' do
        _deref :xxx_foomie or fail
      end

      shared_subject :_man_town do

        _mod = module X_ctm_npvm_mis::ThisOneGuy
          module Items
            o = X_ctm_npvm_mis::THIS_ONE_MOCK
            Joomie = o
            XxxFoomie = o
          end
          IRREGULAR_NAMES = nil
          self
        end

        _subject_magnetic[ _mod ]
      end
    end

    context '(c2)' do

      it 'reach irregular spellings' do
        _deref :doofined? or fail
      end

      it %q{(not shown) hit that one cache, change that other state} do
        o = _man_town
        o.dereference :normie_formie or fail
        o.dereference :doofined? or fail
        o.dereference :__FOOLE__ or fail
        o.dereference :normie_formie or fail
        o.dereference :doofined? or fail
      end

      shared_subject :_man_town do

        _mod = module X_ctm_npvm_mis::ThisOtherGuy

          module Items
            o = X_ctm_npvm_mis::THIS_ONE_MOCK
            NormieFormie = o
            X__doofined__ = o
            X__FOOLE__ = o
          end

          IRREGULAR_NAMES = {
            :doofined? => :X__doofined__,
            :__FOOLE__ => :X__FOOLE__,
          }

          self
        end

        _subject_magnetic[ _mod ]
      end
    end

    def _deref sym
      _man_town.dereference sym
    end

    def _subject_magnetic
      Home_::CrazyTownMagnetics_::NodeProcessor_via_Module
    end

    module X_ctm_npvm_mis  # const namespace for tests in this file
      module THIS_ONE_MOCK ; class << self
        def __receive_constituent_construction_services_ _
        end
      end ; end
    end
  end
end
# #born.
