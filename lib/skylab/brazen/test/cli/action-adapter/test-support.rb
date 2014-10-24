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
      @normalization = _n11n.with_x x_a
      @result = @normalization.execute
    end

    def expect_failure event_channel_i, x_i
      if @result
        @result.terminal_channel_i.should eql event_channel_i
        if :missing == event_channel_i
          @result.property.name_i.should eql x_i
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

      Entity_ = Entity_[][ -> do

        o :meta_property, :argument_arity,
            :enum, [ :zero, :one ],
            :default, :one

        o :meta_property, :default, :entity_class_hook, -> prop, cls do
          cls.add_iambic_event_listener :iambuc_normalize_and_validate,
            -> obj do
              obj.aply_dflt_proc_if_necessary prop ; nil
            end
        end

        o :meta_property, :parameter_arity,
            :enum, [ :zero_or_one, :one ],
            :default, :zero_or_one


        property_class_for_write

        class self::Property

          def initialize( * )
            @default = nil
            super
          end

          def has_default
            ! @default.nil?
          end

          def is_actually_required
            is_required
          end

          def is_required
            :one == @parameter_arity
          end

          def takes_argument
            :one == @argument_arity
          end

          o do

            o :iambic_writer_method_name_suffix, :'='

            def required=
              @parameter_arity = :one
            end
          end
        end
      end ]

      p = -> { Entity_ } ; Entity_
    end

    -> { p.call }
  end.call
end
