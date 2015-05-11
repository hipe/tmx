require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash

  describe "[ba] Hash" do

    it "the loquacious default proc tries to generate sexy helpful messages" do

      h = { foo: 'bar', biff: 'baz' }
      h.default_proc = Subject_[].loquacious_default_proc.curry[ 'beefel' ]

      _rx = ::Regexp.new( "\\Ano\\ such\\ beefel\\ 'luhrmann'\\.\\ did\\ you\\ mean\\ 'foo'\\ or\\ 'biff'\\?\\z" )
      -> do
        h[ :luhrmann ]
      end.should raise_error( KeyError, _rx )
    end

    it "`unpack_equal` flattens a hash's values into an array" do

      h = { age: 2, name: "me" }
      name, age = Subject_[].unpack_equal h, :name, :age
      name.should eql "me"
      age.should eql 2
    end
  end
end
