require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] Hash" do

    it "the loquacious default proc tries to generate sexy helpful messages" do

      h = { foo: 'bar', biff: 'baz' }
      h.default_proc = Home_::Hash.loquacious_default_proc.curry[ 'beefel' ]
      _rx = ::Regexp.new "\\Ano\\ such\\ beefel\\ 'luhrmann'\\.\\ did\\ you\\ mean\\ 'foo'\\ or\\ 'biff'\\?\\z"

      begin
        h[ :luhrmann ]
      rescue KeyError => e
      end

      e.message.should match _rx
    end

    it "`unpack_equal` flattens a hash's values into an array" do

      h = { age: 2, name: "me" }
      name, age = Home_::Hash.unpack_equal h, :name, :age
      name.should eql "me"
      age.should eql 2
    end
  end
end
