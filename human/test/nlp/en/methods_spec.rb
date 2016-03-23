require_relative '../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - methods" do

    extend TS_

    it "an - matches a/an, case" do

      sc = _soliloquizing_client_for :an

      sc.instance_exec{ an 'apple' }.should eql( 'an apple' )
      sc.instance_exec{ an 'PEAR' }.should eql( 'A PEAR' )
      sc.instance_exec{ an 'beef', 0 }.should eql( 'no beef' )
      sc.instance_exec{ an 'wing', 2 }.should eql( 'wing' )
    end

    it "`s` - memoizes last numeric" do

      sc = _soliloquizing_client_for :s

     sc.instance_exec{ s 2 }.should eql( 's' )
     sc.instance_exec{ s }.should eql( 's' )
     sc.instance_exec{ s 1 }.should eql( nil )
     sc.instance_exec{ s }.should eql( nil )
    end

    it "`and_` - memoizes last numeric" do

      sc = _soliloquizing_client_for :and_, :s, :or_

      x = sc.instance_exec do
        "#{ and_ ['foo', 'bar'] } #{ s :is } ready"
      end

      x.should eql( "foo and bar are ready" )

      x = sc.instance_exec do
        "#{ or_ ['foo'] } #{ s :is } ready"
      end

      x.should eql( 'foo is ready' )

      x = sc.instance_exec do
        "#{ and_( [] ) || 'none' } #{ s :is } ready"
      end

      x.should eql( 'none are ready' )
    end

    it "integration 0" do

      _against
      _expect "no known persons exist in these 0 locations."
    end

    it "integration 1" do

      _against 'A'
      _expect "the only known person is A in this location."
    end

    it "integration 2" do

      _against 'A', 'B'
      _expect "known persons are A and B in these 2 locations."
    end

    def _against * s_a
      @_s_a = s_a
    end

    define_method :_expect, -> do

      # ( has a counterpart test in #spot-2 )
      # ( note the example is somewhat un-realistic because we are using the
      # same count-variable referrant for two different noun phrases. )

      o = nil
      -> exp_s do

        o ||= __dangerous_build
        s_a = @_s_a

        _s_ = ( o.instance_exec do
         "#{ s s_a, :no }known person#{ s } #{ s :exist }#{ _and s_a }#{
           } in #{ s :this }#{ _non_one } location#{ s }."
        end )

        _s_.should eql exp_s
      end
    end.call

    def __dangerous_build

      _soliloquizing_client_for :and_, :_and, :_non_one, :s

    end

    define_method :_soliloquizing_client_for, -> do

      d = 0
      prefix = "NLP_EN_Method_User_"
      -> * i_a do

        cls = ::Class.new
        TS_.const_set "#{ prefix }#{ d += 1 }", cls
        Home_::NLP::EN::Methods.edit_module_via_iambic cls, [ :public, i_a ]
        cls.new
      end
    end.call
  end
end
