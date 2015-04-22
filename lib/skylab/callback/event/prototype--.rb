module Skylab::Callback

    class Event

      class Prototype__ < self  # :[#012].

        class << self
          def via_deflist_and_message_proc i_a, p
            Make___[ i_a, p ]
          end
        end  # >>

        class Make___

          Callback_::Actor.call self, :properties,
            :deflist_a,
            :message_proc

          def execute
            validate
            work
          end

          def validate
            len = @deflist_a.length
            1 == len % 2 or raise ::ArgumentError, say_odd_number
          end

          def say_odd_number
            "#{ @deflist_a.length } for odd number for deflist (#{ syntax_s })"
          end

          def syntax_s
            "<term_chan> [, <name>, <val> [..]]"
          end

          def work
            scn = Callback_::Polymorphic_Stream.via_array @deflist_a
            cls = ::Class.new Prototype__
            _MESSAGE_PROC_ = @message_proc
            cls.class_exec do
              extend Module_Methods__
              const_set :TERMINAL_CHANNEL_SYMBOL___, scn.gets_one
              define_method :message_proc do _MESSAGE_PROC_ end
              _BOX_ = Callback_::Box.new
              while scn.unparsed_exists
                prp = Prop__.new scn.gets_one, scn.gets_one
                _BOX_.add prp.name_symbol, prp
                attr_reader prp.name_symbol
              end
              _BOX_.freeze
              define_singleton_method :prop_bx do _BOX_ end
              define_method :formal_properties do _BOX_ end
            end
            cls
          end
        end

        class Prop__
          def initialize i, x
            @name_symbol = i
            @name_as_ivar = :"@#{ i }"
            @default_value = x
            freeze
          end
          attr_reader :name_symbol, :name_as_ivar, :default_value
        end

        module Module_Methods__

          def [] * x_a
            construct do
              init_via_value_list x_a
              freeze
            end
          end

          def new_mutable * x_a
            construct do
              init_via_value_list x_a
            end
          end

          def call_via_arglist a
            construct do
              init_via_value_list a
              freeze
            end
          end

          def new_with * x_a
            construct do
              process_iambic_fully x_a
              freeze
            end
          end
        end  # end module methds

        # ~ instance methods of event class

        def terminal_channel_i
          self.class::TERMINAL_CHANNEL_SYMBOL___
        end

        def replace_some_values * value_a
          value_a.each_with_index do |x, d|
            instance_variable_set ivar_box.at_position( d ), x
          end ; nil
        end

      private

        def init_via_value_list x_a  # caller should freeze
          bx = formal_properties
          x_a.length.times do |d|
            instance_variable_set bx.at_position( d ).name_as_ivar, x_a.fetch( d )
          end
          x_a.length.upto( bx.length - 1 ) do |d|
            prop = bx.at_position d
            instance_variable_set prop.name_as_ivar, prop.default_value
          end
          NIL_
        end

        def have * x_a
          _ok = process_iambic_fully x_a
          _ok && freeze
        end

        def process_iambic_fully x_a  # caller should freeze

          # (a custom amalgamation of the commonest two idioms: if it
          #  has a formal property, set the ivar; else call a custom
          #  iambic parsing method. also nil-out any not-set values.)

          bx = formal_properties
          ok = true
          st = Callback_::Polymorphic_Stream.new 0, x_a

          at_end = EMPTY_P_
          once = -> do
            once = EMPTY_P_
            at_end = -> do
              remove_instance_variable :@__methodic_actor_iambic_stream__
            end
            @__methodic_actor_iambic_stream__ = st
            NIL_
          end

          while st.unparsed_exists

            sym = st.gets_one
            prp = bx[ sym ]

            if prp
              instance_variable_set prp.name_as_ivar, st.gets_one
              next
            end

            once[]

            ok = send :"#{ sym }="
            ok or break

          end

          at_end[]

          if ok
            __init_defaults
          end

          ok or raise ::ArgumentError  # until this is universally normalized
        end

        def __init_defaults

          formal_properties.each_value do | prp |
            ivar = prp.name_as_ivar
            x = if instance_variable_defined? ivar
              instance_variable_get ivar
            end
            if x.nil?
              instance_variable_set ivar, prp.default_value
            end
          end
          NIL_
        end

        def iambic_property  # :+#cp
          @__methodic_actor_iambic_stream__.gets_one
        end

      protected
        def init_copy_via_iambic_and_message_proc x_a, p
          bx = ivar_box
          x_a.each_slice( 2 ) do |i, x|
            instance_variable_set bx.fetch( i ), x
          end
          if p  # or whtever
            define_singleton_method :message_proc do
              p
            end
          end
          self
        end
      private
        def ivar_box
          self.class.ivar_bx
        end

        class << self
          def ivar_bx
            @ivar_bx ||= bld_ivar_bx
          end
        private
          def bld_ivar_bx
            bx = Callback_::Box.new
            prop_bx.each_pair do |i, prop|
              bx.add i, prop.name_as_ivar
            end
            bx.freeze
          end
        end
      end
    end
end
