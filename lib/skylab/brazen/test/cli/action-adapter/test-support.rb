require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI::A_A_

  ::Skylab::Brazen::TestSupport::CLI[ T_S__ = self ]

  include Constants

  extend TestSupport_::Quickie

  Brazen_ = Brazen_

  module ModuleMethods
    def with_class & blk
      contxt = self
      before :all do
        _the_class = nil.instance_exec( & blk )
        _ARG_A_ = _the_class.properties.each_value.to_a.freeze
        contxt.send :define_method, :arg_a do _ARG_A_ end
      end
    end
  end

  module InstanceMethods

    def with * x_a
      _n11n = Brazen_::CLI::Action_Adapter_::Arguments.normalization arg_a
      @normalization = _n11n.new_via_argv x_a
      @result = @normalization.execute
    end

    def expect_failure event_channel_i, x_i
      if @result
        @result.terminal_channel_i.should eql event_channel_i
        if :missing == event_channel_i
          @result.property.name_symbol.should eql x_i
        else
          @result.x.should eql x_i
        end
      else
        fail "expected result, had none"
      end
    end

    def expect_success * x_a
      a = @normalization.release_result_iambic
      a.should eql x_a
    end
  end

  Ent_ = -> do

    p = -> do

      Entete_ = Brazen_::Entity.call do

        o :enum, [ :zero, :one ],
          :default, :one,
          :meta_property, :argument_arity,

          :enum, [ :zero_or_one, :one ],
          :default, :zero_or_one,
          :meta_property, :parameter_arity


        entity_property_class_for_write

        class self::Entity_Property

          def is_required
            :one == @parameter_arity
          end

          def takes_many_arguments
            :zero_or_more == @argument_arity ||
              :one_or_more == @argument_arity
          end

          def takes_argument
            :one == @argument_arity
          end

          def has_default
            false  # per f.w
          end
        end
      end

      p = -> do
        Entete_
      end
      Entete_
    end

    -> { p.call }
  end.call
end
