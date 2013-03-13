require_relative '../../../../test-support'

module ::Skylab::MyTree::TestSupport
  module API
    module Actions
      module Tree
        # forward delcarations for possible future nerks
      end
    end
  end
end

module ::Skylab::MyTree::TestSupport::API::Actions::Tree::Tree
  ::Skylab::MyTree::TestSupport[ self ] # #regret

  module InstanceMethods
    include CONSTANTS

    attr_accessor :debug

    def debug!
      self.debug = true
    end

    def makes str
      spy = Headless::TestSupport::Client_Spy.new
      spy.debug = -> { self.debug }
      o = MyTree::API::Actions::Tree::Tree.new spy, { }
      @with.split( "\n" ).each do |s|
        o.puts s
      end
      o.flush
      actual = spy.emitted.map(& :string ).join "\n"
      expected = str.unindent.chomp
      actual.should eql(expected)
      nil
    end

    def with str
      @with = str.unindent.chomp
      nil
    end
  end
end
