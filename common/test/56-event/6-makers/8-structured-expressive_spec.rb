require_relative '../../test-support'

module Skylab::Common::TestSupport

  describe "[co] event - makers - structured expressive" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module
    end

    it "makes a purely structured class" do

      expect( _structured_class.members ).to eql [ :a, :b, :c ]
    end

    it "..which works (attr readers, `to_a`)" do

      _cls = _structured_class

      o = _cls.new 'A', 'B'
      expect( o.a ).to eql 'A'
      expect( o.b ).to eql 'B'
      expect( o.c ).to be_nil

      expect( o.to_a ).to eql [ 'A', 'B',  nil ]
    end

    shared_subject :_structured_class do

      X_e_m_SE_01 = _subject_module.new :a, :b, :c
    end

    it "expressive guy makes" do

      _expressive_class
    end

    it "with this form of generated class, your message can only be one line" do

      _cls = _expressive_class

      o = _cls.new 'ONE', 'TWO'

      _expag = Home_.lib_.brazen::API.expression_agent_instance

      _y = o.express_into_under [], _expag

      expect( _y ).to eql [ '"ONE", "TWO"' ]
    end

    shared_subject :_expressive_class do

      _mod = _subject_module

      X_e_m_SE_02 = _mod.new do | one, two |

        "#{ code one }, #{ ick two }"
      end
    end

    def _subject_module
      Home_::Event.structured_expressive
    end
  end
end
