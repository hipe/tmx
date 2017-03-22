require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization intro" do

    # #c15n-test-family-1

    TS_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization

    it "loads" do
      subject_class_
    end

    context "(classic setup)" do

      dangerous_memoize :_prototype do
        o = _beginning_prototype.dup
        o.trilean = false
        o
      end

      it "builds" do
        _prototype
      end

      it "(when empty selection stack, still the string \"failed\" comes thru)" do
        _against 'failed'
      end

      exp1 = 'tanman failed'
      it exp1 do
        _against 'tanman', exp1
      end

      same = "(as ss)"
      it same do
        _against nil, 'failed'
      end

      exp2 = 'tanman failed to add'
      it exp2 do
        _against 'tanman', 'add', exp2
      end

      it same do
        _against nil, 'add', 'failed to add'
      end

      exp3 = 'tanman failed to add remote'
      it exp3 do
        _against 'tanman', 'remote', 'add', exp3
      end

      it same do
        _against nil, 'remote', 'add', 'failed to add remote'
      end

      exp4 = 'tanman failed to set graph starter'
      it exp4 do
        _against 'tanman', 'graph', 'starter', 'set', exp4
      end

      it same do
        _against nil, 'graph', 'starter', 'set', 'failed to set graph starter'
      end

      exp5 = 'tanman failed to set internationalization language preference'
      it exp5 do
        _against 'tanman', 'internationalization', 'language', 'preference', 'set', exp5
      end

      exp6 = 'tanman trepidatious external services failed to delete connection'
      it exp6 do
        _against 'tanman', 'services', 'external', 'trepidatious', 'connection', 'delete', exp6
      end
    end

    context "(success)" do

      dangerous_memoize :_prototype do
        o = _beginning_prototype.dup
        o.trilean = true
        o
      end

      it '(2)' do
        _against 'jib', 'add', 'jib added'
      end

      it '(2_)' do
        _against nil, 'add', 'added'
      end

      it '(3)' do
        _against 'jib', 'foo', 'add', 'jib added foo'
      end

      it '(3_)' do
        _against nil, 'foo', 'add', 'added foo'
      end
    end

    context "(neutral)" do

      dangerous_memoize :_prototype do
        o = _beginning_prototype.dup
        o.trilean = nil
        o
      end

      it '(2)' do
        _against 'zerper', 'add', 'while zerper was adding,'
      end

      it '(2_)' do
        _against nil, 'add', 'while adding,'
      end

      it '(3)' do
        _against 'zerper', 'foo', 'add', 'while zerper was adding foo,'
      end

      it '(3_)' do
        _against nil, 'foo', 'add', 'while adding foo,'
      end
    end

    def _against * s_a, expected_s

      o = _prototype.dup
      o.selection_stack = s_a
      o.build_string.should eql expected_s
    end

    dangerous_memoize :_beginning_prototype do

      o = subject_class_.begin

      o.to_say_selection_stack_item = -> s do

        # (in this file we represent the selection stack items as strings
        # for readability. as such we need this custom hook to "render" them.)

        s  # might be nil for those root "frames" that we make be nil
      end

      o
    end
  end
end
