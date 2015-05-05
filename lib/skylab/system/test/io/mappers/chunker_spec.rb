require_relative 'test-support'

module Skylab::Headless::TestSupport::IO::Mappers::Chunker

  ::Skylab::Headless::TestSupport::IO::Mappers[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods
    counter = 0
    define_method :const_set do |mod|
      stem = case mod
             when ::Class  ; 'KLS'
             when ::Module ; 'MOD'
             else          ; 'CONST'
             end
      const = "#{ stem }_#{ counter += 1 }".intern
      TS_.const_set const, mod
      mod
    end

    def expect act, *exp
      act.should eql( exp )
      act.clear
      nil
    end
  end

  describe "[hl] IO interceptors chunker common" do

    extend TS_

    let :klass do
      Headless_::IO::Mappers::Chunkers::Common
    end

    it 'chunks' do
      a = [ ]
      o = klass.new -> str do
        a << str
      end
      o.write "foo\nbar"
      expect a, "foo\n"
      o.write "barbar"
      expect a
      o.write "\n"
      expect a, "barbarbar\n"
      o.write 'z'
      expect a
      o.flush
      expect a, 'z'
    end
  end
end
