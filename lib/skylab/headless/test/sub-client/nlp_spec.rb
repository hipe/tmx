require_relative 'test-support'

module ::Skylab::Headless::TestSupport::SubClient

  describe "#{ Headless::SubClient } NLP" do

    extend SubClient_TestSupport

    def sc
      self.class.sc
    end

    define_singleton_method :sc, & MetaHell::FUN.memoize[ -> do
      o = ::Object.new
      o.extend Headless::SubClient::InstanceMethods
      o
    end ]

    it "an - matches a/an, case" do
      sc.instance_exec{ an 'apple' }.should eql( 'an ' )
      sc.instance_exec{ an 'PEAR' }.should eql( 'A ' )
      sc.instance_exec{ an 'beef', 0 }.should eql( 'no ' )
      sc.instance_exec{ an 'wing', 2 }.should eql( nil )
    end

    it "`s` - memoizes last numeric" do
     sc.instance_exec{ s 2 }.should eql( 's' )
     sc.instance_exec{ s }.should eql( 's' )
     sc.instance_exec{ s 1 }.should eql( nil )
     sc.instance_exec{ s }.should eql( nil )
    end

    it "`and_` - memoizes last numeric" do
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

    # ( has a complimentary test in `minitesimal_spec.rb` )
    # ( note the example is somewhat un-realistic because we are using the
    # same count-variable referrant for two different noun phrases. )

    context "integration" do

      def self.expect arr, str, *tags
        it str, *tags do
          x = sc.instance_exec do
            "#{ s arr, :no }known person#{ s } #{ s :exis }#{ _and arr }#{
              } in #{ s :this }#{ _non_one } location#{ s }."
          end
          x.should eql( str )
        end
      end

      expect %w(), "no known persons exist in these 0 locations."

      expect %w(A), "the only known person is A in this location."

      expect %w(A B), "known persons are A and B in these 2 locations."

    end
  end
end
