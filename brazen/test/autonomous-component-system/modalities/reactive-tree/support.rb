module Skylab::Brazen::TestSupport

  module Autonomous_Component_System::Modalities::Reactive_Tree::Support

    class << self

      def [] tcc
        tcc.include self
      end

      define_method :_danger_memo, TestSupport_::DANGEROUS_MEMOIZE

      def _memoize sym, & p
        define_method sym, Callback_.memoize( & p )
      end
    end  # >>

    def call_ * x_a

      @result = kernel_.call( * x_a, & fut_p )
      future_is_now
      nil
    end

    def expect_failed_

      future_is_now  # assert no more events

      @result.should eql false
    end

    _danger_memo :kernel_ do

      ds = new_dynamic_source_for_unbounds_

      ds.add :Shoe, shoe_model_.new

      build_kernel_from_seed_and_module_ ds, Here_
    end

    def new_dynamic_source_for_unbounds_
      Subject[]::Dynamic_Source_for_Unbounds.new
    end

    def build_kernel_from_seed_and_module_ ds, mod

      Home_::Kernel.new mod do | ke |
        ke.reactive_tree_seed = ds
      end
    end

    _memoize :shoe_model_ do

      class Shoe  # similar to another model elsewhere

        def __lace__component_association

          Lace
        end

        # ~ to be an unbound

        def build_unordered_index_stream & oes_p
          Subject[]::Self_as_unbound_stream[ __nf, self, & oes_p ]
        end

        def __nf

          # (as the top model, it needs to give itself a name)

          @___nf ||= Callback_::Name.via_variegated_symbol( :shoe )
        end

        def __globbie_guy__component_operation

          -> * file do
            file
          end
        end

        def __globbie_complex__component_operation

          -> action, is_dry=false, verbose=false, *file do

            [ action, is_dry, verbose, file ]
          end
        end
      end

      Local_Lib__ = TS_.lib :autonomous_component_system_support

      class Lace

        Local_Lib__::Common_child_class_methods[ self ]

        def initialize & p

          @color = 'white'
          @_oes_p = p
        end

        def __get_color__component_operation

          -> do

            @_oes_p.call :info, :expression, :working do | y |
              y << "retrieving #{ highlight 'color' }"
            end

            @color
          end
        end

        def __set_length__component_operation

          -> length do

            x = length

            ok = if x.respond_to? :bit_length
              true
            else

              if /\A-?\d+\z/ =~ x
                x = x.to_i
                true
              else
                @_oes_p.call :info, :expression, :not_int do | y | y << 'not.' end
                false
              end
            end

            if ok

              if 0 >= x
                @_oes_p.call :info, :expression, :too_low do | y | y << 'low.' end
                false
              else
                @x = x
                :_yay_
              end
            else
              ok
            end
          end
        end
      end

      Shoe
    end

    Subject = -> do
      Home_::Autonomous_Component_System::Modalities::Reactive_Tree
    end

    Here_ = self
  end
end
