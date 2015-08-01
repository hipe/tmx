require_relative '../../test-support'

module Skylab::Callback::TestSupport

  describe "[ca] event - makers - structured expressive" do

    extend TS_

    it "loads" do
      _subject_module
    end

    it "makes a purely structured class" do

      _structured_class.members.should eql [ :a, :b, :c ]
    end

    it "..which works (attr readers, `to_a`)" do

      _cls = _structured_class

      o = _cls.new 'A', 'B'
      o.a.should eql 'A'
      o.b.should eql 'B'
      o.c.should be_nil

      o.to_a.should eql [ 'A', 'B',  nil ]
    end

    dangerous_memoize_ :_structured_class do

      TS_::E_M_SE_01 = _subject_module.new :a, :b, :c

    end

    it "expressive guy makes" do

      _expressive_class
    end

    it "with this form of generated class, your message can only be one line" do

      _cls = _expressive_class

      o = _cls.new 'ONE', 'TWO'

      _expag = Home_.lib_.brazen::API.expression_agent_instance

      _y = o.express_into_under [], _expag

      _y.should eql [ "'ONE', 'TWO'" ]
    end

    dangerous_memoize_ :_expressive_class do

      _mod = _subject_module

      TS_::E_M_SE_02 = _mod.new do | one, two |

        "#{ code one }, #{ ick two }"
      end
    end

    def _subject_module
      Home_::Event.structured_expressive
    end
  end
end
