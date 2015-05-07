require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] IO - mappers - chunker" do

    extend TS_

    it 'chunks' do

      a = []

      o = __class.new -> str do
        a << str
      end

      o.write "foo\nbar"
      _expect a, "foo\n"

      o.write "barbar"
      _expect a

      o.write "\n"
      _expect a, "barbarbar\n"

      o.write 'z'
      _expect a

      o.flush
      _expect a, 'z'
    end

    def __class
      System_::IO::Mappers::Chunkers::Common
    end

    def _expect act, *exp
      act.should eql( exp )
      act.clear
      nil
    end
  end
end
