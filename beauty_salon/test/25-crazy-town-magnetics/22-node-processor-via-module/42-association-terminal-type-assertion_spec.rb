# frozen_string_literal: true

require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - association terminal type assertion', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_ASSOCIATION_LYFE

    context 'a terminal association WITHOUT the correspoindng type sanitizers' do

      given :la_la_la_terminal

      it 'builds' do
        subject_association_ || fail
      end

      it 'but FAILS if you try to yadda', ex: true do
        _asc = subject_association_
        begin
         _asc.assert_type_of_terminal_value_ nil
        rescue ::NoMethodError => e
        end
        e || fail
      end

      shared_subject :subject_branch_ do
        build_subject_branch_ :Monzo_01
      end
    end

    context 'a terminal association WITH the corresponding type sanitizers', ex: true do

      given :la_la_la_terminal

      it 'if you try yadda and yadda is wrong - LOOSE' do
        _asc = subject_association_
        expect_exception_with_this_symbol_ :terminal_type_assertion_failure do
          _asc.assert_type_of_terminal_value_ 123
        end
      end

      it 'if you try yadda and yadda is right - WIN (no exception. result is nil' do
        _x = subject_association_.assert_type_of_terminal_value_ 321
        _x.nil? || fail
      end

      shared_subject :subject_branch_ do
        build_subject_branch_ :Monzo_0 do
          self::TERMINAL_TYPE_SANITIZERS = {
            la: -> d do
              321 == d
            end,
          }
        end
      end
    end

    def sandbox_module_
      X_ctm_npvm_atta
    end

    X_ctm_npvm_atta = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
