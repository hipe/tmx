module Skylab::Brazen::TestSupport

  module CLI_Support

    def self.[] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end  # >>

    # <-

  module Module_Methods___

    def with_class & blk
      contxt = self
      before :all do
        _the_class = nil.instance_exec( & blk )
        _ARG_A_ = _the_class.properties.each_value.to_a.freeze
        contxt.send :define_method, :arg_a do _ARG_A_ end
      end
    end
  end

  module Instance_Methods___

    def with * x_a
      _n11n = Home_::CLI_Support::Arguments.normalization arg_a
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

  Ent = -> do

    p = -> do

      Entete_ = Home_::Entity.call do

        o :enum, [ :zero, :one ],
          :default, :one,
          :meta_property, :argument_arity,

          :enum, [ :zero_or_one, :one ],
          :default, :zero_or_one,
          :meta_property, :parameter_arity

      end

      module Entete_

        const_get( :Property, false ).class_exec do

          # -- ew, per f.w:

          def is_effectively_optional_
            ! is_required
          end

          def has_default
            false  # per f.w
          end

          # --

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
        end
      end

      p = -> do
        Entete_
      end
      Entete_
    end

    -> { p.call }
  end.call
  # ->
  end
end
