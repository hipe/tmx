require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] pathname - FEATURE ISLAND extname experiment" do

    # #todo this isn't used anywhere. but we are keeping it around
    # in case we we ever decide to raw-dog the extname logic

    _RX = /\A (?: (?<stem>|.*[^\.]|\.+)
      (?<extname>\.[^\.]*)
      |(?<stem>[^\.]*)
    ) \z/x

    define_singleton_method :o do | input_s, output_a, * a |

      it "#{ input_s.inspect } -> #{ output_a.inspect }", *a do

        md = _RX.match input_s
        if md
          stem, extname = output_a
          md[ :stem ].should eql stem
          md[ :extname ].should eql extname
        else
          fail "did not match - #{ input_s.inspect }"
        end
      end
    end

    context "matches the set of all strings" do
      o '', ['', nil]
      o '.', ['', '.']
      o '..', ['.','.']
      o '...', ['..','.']
      o '.abc', ['', '.abc']
      o 'abc.', ['abc', '.']
      o 'foo', ['foo', nil]
      o 'foo.bar', ['foo', '.bar']
      o 'foo.bar.baz', ['foo.bar', '.baz']
    end
  end
end
