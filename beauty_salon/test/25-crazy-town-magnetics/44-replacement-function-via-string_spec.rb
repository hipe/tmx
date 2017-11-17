require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - replacement function via string', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_PARSY_TOWN

    it 'magnetic loads' do
      parsy_subject_magnetic_ || fail
    end

    it 'empty string' do
      _against EMPTY_S_
      fails_with_these_normal_lines_ do |y|
        y << %q{expecting 'file':}
        y << %q{  }
        y << %q{  ^}
      end
    end

    it 'strange token' do
      _against 'wazoo'
      fails_with_these_normal_lines_ do |y|
        y << %q{expecting 'file':}
        y << %q{  wazoo}
        y << %q{  ^}
      end
    end

    it 'colon' do
      _against 'file'
      fails_with_these_normal_lines_ do |y|
        y << %q{expecting ':':}
        y << %q{  file}
        y << %q{  ----^}
      end
    end

    it 'no path' do
      _against 'file:'
      fails_with_these_normal_lines_ do |y|
        y << %q{expecting <path>:}
        y << %q{  file:}
        y << %q{  -----^}
      end
    end

    it 'no ent' do

      _path = TestSupport_::Fixtures.file :not_here
      # _path = '/tmp'  see EISDIR

      _against "file:#{ _path }"

      fails_with_these_normal_lines_ do |y|
        y << %r(\ANo such file or directory - [^[:space:]])
      end
    end

    it %q{file doesn't define const} do

      _against "file:#{ fixture_functions_ 'la-la-005.rb' }"

      fails_with_these_normal_lines_ do |y|

        y << %q{expecting something like Skylab::BeautySalon::CrazyTownFunctions::LaLa005}

        y << %r{to be defined in [^[:space:]]}

        s = '(?:La_La_000|Any_Name_You_Want__)'
        y << %r{\(had consts: #{ s }, #{ s }\)\z}
      end
    end

    context 'money' do

      it 'knows path' do
        _result.path || fail
      end

      it 'knows const' do
        _result.user_const == :La_La_010 || fail
      end

      it 'knows function' do
        _result.user_function.respond_to? :call or fail
      end

      shared_subject :_result do
        want_success_against_ "file:#{ fixture_functions_ 'la-la-010.rb' }"
      end
    end

    def _against s
      @STRING = s
    end

    def parsy_subject_magnetic_
      main_magnetics_::ReplacementFunction_via_String
    end
  end
end
