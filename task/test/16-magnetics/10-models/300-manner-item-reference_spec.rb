require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - models - manner intro" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics

    sandbox = nil

    it "enhancing the class adds one method for each slot" do

      cls = _enhanced_class
      cls.method_defined? :express_problem or fail
      cls.method_defined? :sorting_algorithm or fail
    end

    it "this method when called produces a \"slot setter\" that reflects its members" do

      _guy = _enhanced_class.new

      _setter = _guy.express_problem

      _x = _setter.members

      _x == [ :friendly, :perturbed ] || fail
    end

    it "this slot setter can then instantiate the manner for this slot" do

      client = _enhanced_class.new
      _x = client.express_problem.friendly
      _x.nil? || fail
      _ma = client.instance_variable_get :@express_problem
      _ma.mock_manner_shibboleth == :_hello_123_ || fail
    end

    shared_subject :_enhanced_class do

      _col = _collection

      cls = ::Class.new

      sandbox::MyClass1 = cls

      cls.class_exec do

        def receive_magnetic_manner cls, ma, col

          _ma = cls.magnetic_manner_for self, col

          _ivar = ma.ivar

          instance_variable_set ma.ivar, _ma
          NIL_
        end
      end

      _col.write_manner_methods_onto cls
    end

    shared_subject :_collection do

      h = {
        Express_Problem_as_Friendly: -> do
          build_mock_manner_class_( :_hello_123_ )
        end,
      }

      _p = -> mit do  # item_resolver
        h.fetch( mit.const ).call
      end

      item_ticket_collection_via_(
        _p,
        %w( express problem as friendly ),
        %w( chip chop via yin and yang ),
        %w( express problem as perturbed ),
        %w( sorting algorithm as quickly ),
      )
    end

    sandbox = module X_Mag_Mo_Manner_One
      self
    end
  end
end
