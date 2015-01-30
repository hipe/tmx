module Skylab::Callback

    class Event

      class Prototype__ < self  # :[#012].

        class << self
          def via_deflist_and_message_proc i_a, p
            Build__[ i_a, p ]
          end
        end

        class Build__

          Callback_::Actor[ self, :properties,
            :deflist_a,
            :message_proc ]

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
            scn = Callback_::Iambic_Stream.via_array @deflist_a
            cls = ::Class.new Prototype__
            _MESSAGE_PROC_ = @message_proc
            cls.class_exec do
              extend Module_Methods__
              _TERMINAL_CHANNEL_I_ = scn.gets_one
              define_method :terminal_channel_i do _TERMINAL_CHANNEL_I_ end
              define_method :message_proc do _MESSAGE_PROC_ end
              _BOX_ = Callback_::Box.new
              while scn.unparsed_exists
                prop = Prop__.new scn.gets_one, scn.gets_one
                _BOX_.add prop.name_i, prop
                attr_reader prop.name_i
              end
              _BOX_.freeze
              define_singleton_method :prop_bx do _BOX_ end
              define_method :reflection_box do _BOX_ end
            end
            cls
          end
        end

        class Prop__
          def initialize i, x
            @name_i = i
            @name_as_ivar = :"@#{ i }"
            @default_value = x
            freeze
          end
          attr_reader :name_i, :name_as_ivar, :default_value
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

          def with * x_a
            self._NO_EASY_use_new_with
          end

          def new_with * x_a
            construct do
              init_via_even_iambic x_a
              freeze
            end
          end
        end

        def replace_some_values * value_a
          value_a.each_with_index do |x, d|
            instance_variable_set ivar_box.at_position( d ), x
          end ; nil
        end

      private

        def init_via_value_list x_a
          bx = reflection_box
          x_a.length.times do |d|
            instance_variable_set bx.at_position( d ).name_as_ivar, x_a.fetch( d )
          end
          x_a.length.upto( bx.length - 1 ) do |d|
            prop = bx.at_position d
            instance_variable_set prop.name_as_ivar, prop.default_value
          end ; nil  # caller should freeze
        end

        def init_via_even_iambic x_a
          seen_h = {}
          bx = reflection_box
          x_a.each_slice 2 do |i, x|
            prop = bx.fetch i
            seen_h[ i ] = true
            instance_variable_set prop.name_as_ivar, x
          end
          bx.each_value do |prop|
            seen_h[ prop.name_i ] and next
            instance_variable_set prop.name_as_ivar, prop.default_value
          end ; nil  # caller should freeze
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
