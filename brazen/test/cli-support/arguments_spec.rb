require_relative '../test-support'

module Skylab::Brazen::TestSupport

  module CLI_Support_Arguments_Namespace

    bruh = TS_.lib_ :CLI_support

    Ent_ = bruh::Ent

    # <-

  TS_.describe "[br] CLI support - arguments - parse ARGV (R=required, O=optional" do

    bruh[ self ]

    context "some syntaxes are not meant to be (O R O)" do

      with_class do
        class AAPA_ORO
          Ent_[].call self do
            o :property, :foo,
              :required, :property, :bar,
              :property, :baz
          end
          self
        end
      end

      it "they raise a runtime error at either declare or parse time" do
        _s = "optional argument 'baz' must but did not #{
          }occur immediately after optional argument 'foo'"
        -> do
          with
        end.should raise_error _s
      end
    end

    context "(R R O O R R)" do

      with_class do
        class AAPA_RROORR
          Ent_[].call self do
            o :required, :property, :alpha,
              :required, :property, :beta,
              :property, :gamma,
              :property, :delta,
              :required, :property, :epsilon,
              :required, :property, :zeta
          end
          self
        end
      end

      it "with 0 comes up short" do
        with
        expect_failure :missing, :alpha
      end

      it "with 1 comes us short" do
        with :A
        expect_failure :missing, :beta
      end

      it "with 2 comes up short" do
        with :A, :B
        expect_failure :missing, :epsilon
      end

      it "with 3 comes up short" do
        with :A, :B, :C
        expect_failure :missing, :zeta
      end

      it "with 4 comes up just right" do
        with :A, :B, :C, :D
        expect_success :alpha, :A, :beta, :B, :epsilon, :C, :zeta, :D
      end

      it "with 5 comes up just right" do
        with :A, :B, :C, :D, :E
        expect_success :alpha, :A, :beta, :B, :gamma, :C,
          :epsilon, :D, :zeta, :E
      end

      it "with 6 comes up just right" do
        with :A, :B, :C, :D, :E, :F
        expect_success :alpha, :A, :beta, :B, :gamma, :C, :delta, :D,
          :epsilon, :E, :zeta, :F
      end

      it "with 7 comes up long" do
        with :A, :B, :C, :D, :E, :F, :G
        expect_failure :extra, :E
      end
    end

    context "(R O)" do

      with_class do
        class AAPA_RO
          Ent_[].call self do
            o :required, :property, :foo,
              :property, :bar
          end
          self
        end
      end

      it "with 0 comes up short" do
        with
        expect_failure :missing, :foo
      end

      it "with 1 comes up ok" do
        with :A
        expect_success :foo, :A
      end

      it "with 2 comes up OK" do
        with :A, :B
        expect_success :foo, :A, :bar, :B
      end

      it "with 3 comes up long" do
        with :A, :B, :C
        expect_failure :extra, :C
      end
    end

    context "(O R)" do

      with_class do
        class AAPA_OR
          Ent_[].call self do
            o :property, :foo,
              :required, :property, :bar
          end
          self
        end
      end

      it "with 0 comes up short" do
        with
        expect_failure :missing, :bar
      end

      it "with 1 comes up OK" do
        with :A
        expect_success :bar, :A
      end

      it "with 2 comes up OK" do
        with :A, :B
        expect_success :foo, :A, :bar, :B
      end

      it "with 3 comes up long (NOTE which argument is considered 'extra')" do
        with :A, :B, :C
        expect_failure :extra, :B
      end
    end

    context "(R)" do

      with_class do
        class AAPA_R
          Ent_[].call self do
            o :required, :property, :foo
          end
          self
        end
      end

      it "with 0 comes up short" do
        with
        expect_failure :missing, :foo
      end

      it "with 1 comes up just right" do
        with :A
        expect_success :foo, :A
      end

      it "with 2 comes up long" do
        with :A, :B
        expect_failure :extra, :B
      end
    end

    context "(O)" do
      with_class do
        class AAPA_O
          Ent_[].call self do
            o :property, :foo
          end
          self
        end
      end

      it "with 0 comes up OK" do
        with
        expect_success
      end

      it "with 1 comes up just right" do
        with :A
        expect_success :foo, :A
      end

      it "with 2 comes up long" do
        with :A, :B
        expect_failure :extra, :B
      end
    end

    context "()" do
      with_class do
        class AAPA_
          Ent_[][ self ]
          self
        end
      end

      it "with 0 ok" do
        with
        expect_success
      end

      it "with 1 comes up long" do
        with :A
        expect_failure :extra, :A
      end
    end
  end
  # ->
  end
end
