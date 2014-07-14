require_relative 'test-support'

module Skylab::Callback::Test::Name::EE__

  describe "[ca] name extname experiment" do

    # #todo this isn't used anywhere. but we are keeping it around
    # in case we we ever decide to raw-dog the extname logic

    RX__ = /\A (?: (?<stem>|.*[^\.]|\.+)
      (?<extname>\.[^\.]*)
      |(?<stem>[^\.]*)
    ) \z/x

    def self.o input_s, output_a, *a
      it "#{ input_s.inspect } -> #{ output_a.inspect }", *a do
        if (( md = RX__.match( input_s  ) ))
          stem, extname = output_a
          md[ :stem ].should eql( stem )
          md[ :extname ].should eql( extname )
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
