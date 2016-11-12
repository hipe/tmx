require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] method - curry unbound" do

    before :all do

      class X_m_cu_Wazzerly

        def sandwich bread, inside, toothpick
          "(#{ bread }(#{ inside })#{ toothpick })"
        end

        _im = instance_method :sandwich

        _mcu = Home_::Method.curry.unbound.new _im

        define_method :reuben, _mcu.curry[ :rye ]

        def not_curriable foo, bar=nil
        end
      end

      X_m_cu_WAZZERLY = X_m_cu_Wazzerly.new
    end

    it "arity is less than 1 - X" do

      _rx = /\bfor now, arity must be greater than or equal to 1 \(had -2\)/

      begin
        class X_m_cu_Wazzerly
          Home_::Method.curry.unbound instance_method :not_curriable
        end
      rescue Home_::ArgumentError => e
      end

      e.message =~ _rx || fail
    end

    it "when you call it with too few args - X" do

      _rx = /\bwrong number of arguments \(2 for 3\)/

      begin
        X_m_cu_WAZZERLY.reuben :one
      rescue Home_::ArgumentError => e
      end

      e.message =~ _rx || fail
    end

    it "when you call it with not enough args - X" do

      _rx = /\bwrong number.+\(4 for 3\)/

      begin
        X_m_cu_WAZZERLY.reuben :one, :two, :three
      rescue Home_::ArgumentError => e
      end

      e.message =~ _rx || fail
    end

    it "just right - o" do

      _s = X_m_cu_WAZZERLY.reuben :saukerkraut, :toothpick
      _s == "(rye(saukerkraut)toothpick)" || fail
    end
  end
end
