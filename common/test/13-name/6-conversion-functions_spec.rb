require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] name - conversion functions" do

    # TS_[ self ]

    memoizer_for = -> sym do
      p = -> x do
        p = Home_::Name::Conversion_Functions.const_get sym, false
        p[ x ]
      end
      -> x do
        p[ x ]
      end
    end

    format = "%-48s %18s => %s"

    context "`pathify` - tries to turn constants into path fragments:" do

      pathify = memoizer_for[ :Pathify ]

      define_singleton_method :o do |const, exp_path, desc, *a|

        it "#{ format % [ desc, const.inspect, exp_path.inspect ] }", *a do
          pathify[ const ].should eql( exp_path )
        end
      end

      o '', '', 'the empty case'

      o "Foo", 'foo', "(the atomic case)"

      o "FooBar", 'foo-bar', 'two part single token camel case'

      o "FB", 'fb', 'atomic adjacent upcase'

      o "HTTPAuth", "http-auth", 'but wait, look at this, magic! TLA at beginning'

      o 'topSecretNSA', 'top-secret-nsa', 'TLA at end'

      o 'WillIAm', 'will-i-am', 'ok, really guys?'

      o "Catch22Pickup", 'catch22pickup', 'numbers whatever this might change'

      o 'IMs', 'ims', "OH MY GOD THIS IS SO DIRTY"

    end

    constantize = memoizer_for[ :Constantize ]

    context "`constantize` tries to turn path framents #{
        }into constants-looking strings" do

       define_singleton_method :o do |path, exp_const, desc, *a|
        it "#{ format % [ desc, path.inspect, exp_const.inspect ] }", *a do
          constantize[ path ].should eql( exp_const )
        end
      end

      o '', '', 'the empty case'

      o 'a', 'A', 'atomic letter'

      o 'SomePath/that-is/99times/fun', 'SomePath::ThatIs::99Times::Fun',

        'might allow for some invalid const names'

      o 'underscores_too', 'UnderscoresToo', 'handles underscores too?'

      o 'foo-bar/baz/.rb', 'FooBar::Baz::', 'will strip extension names of .rb only'

      o 'yerp/hoopie-doopie.py', 'Yerp::HoopieDoopiepy', 'but only .rb'

      o 'one/////two', 'One::Two', 'corrects multiple slashes'

      o 'path Here This::Is::This', 'PathHereThisIsThis', 'sure spaces why not'

      o 'levensherp-', 'Levensherp_', 'an API private constant'

      o 'what-about-bob-', 'WhatAboutBob_', 'a typical multi-part API private constant'
    end

    context "`constantize` tries to turn method-looking #{
      }symbols into constants" do

      define_singleton_method :o do |in_str, out_str, desc, *tags|
        it "#{ format % [ desc, in_str, out_str ] }", *tags do
          constantize[ in_str ].should eql( out_str )
        end
      end

      o :cs_style, "CsStyle", 'normal nerk with underscore'

      o :c_style, "C_Style", 'tricky nerk with only one letter nerk'

    end

    context "`methodize` - tries to make whatevers look like method names" do

      methodize = memoizer_for[ :Methodize ]

      fmt = "%20s => %s"

      define_singleton_method :o do |in_s, out_s, *t|
        it "#{ fmt % [ in_s.inspect, out_s.inspect ] }", *t do
          methodize[ in_s ].should eql( out_s )
        end
      end

      o 'a b', :a_b

      o 'AbcDef', :abc_def

      o 'NASASpaceStation', :nasa_space_station

      o 'abc-def--hij', :abc_def_hij

      o 'F!@#$%^&*Oo', :f_oo
    end
  end
end
