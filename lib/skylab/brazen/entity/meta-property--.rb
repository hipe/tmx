module Skylab::Brazen

  module Entity

    module Meta_Property__

      Apply_default = -> mprop, default_x do

        mprop.against_property_class do

          during_property_normalize do |prop|
            x = prop.any_value_of_metaprop mprop
            if x.nil?
              prop.set_value_of_metaprop default_x, mprop
            end
            KEEP_PARSING_
          end

          include Evented_Property_Common_Instance_Methods__

          KEEP_PARSING_
        end
        KEEP_PARSING_
      end

      Apply_entity_class_hook = -> mprop, recv_parse_ctx_p do

        mprop.against_property_class do
          include Evented_Property_Common_Instance_Methods__
        end

        mprop.add_to_write_proc_chain do
          -> do
            _ctx = Parse_Context____.new @__methodic_actor_iambic_stream__
            _against_ec = instance_exec _ctx, & recv_parse_ctx_p
            against_entity_class( & _against_ec )
            KEEP_PARSING_
          end
        end

        KEEP_PARSING_
      end

      Apply_enum = -> mprop, enum_i_a do

        _ENUM_BOX = Callback_::Box.new

        enum_i_a.each do |i|
          _ENUM_BOX.add i, true
        end

        mprop.against_property_class do
          include Evented_Property_Common_Instance_Methods__
          KEEP_PARSING_
        end

        mprop.after_wrt do |prop|
          x = prop.any_value_of_metaprop mprop
          if _ENUM_BOX[ x ]
            KEEP_PARSING_
          else
            prop.receive_bad_enum_value x, mprop.name_symbol, _ENUM_BOX
          end
        end

        KEEP_PARSING_
      end

      Apply_property_hook = -> mprop, recv_parse_ctx_p do

        mprop.add_to_write_proc_chain do
          -> do
            _ctx = Parse_Context____.new @__methodic_actor_iambic_stream__
            _recv_prop = recv_parse_ctx_p[ _ctx ]
            _recv_prop[ self ]
          end
        end

        KEEP_PARSING_
      end

      Parse_Context____ = ::Struct.new :upstream

      module Evented_Property_Common_Instance_Methods__

        def against_entity_class & p
          ( @against_EC_p_a ||= [] ).push p
          nil
        end

        attr_reader :against_EC_p_a

        def normalize_property

          if self.class::NORM_P_A
            p_a = self.class::NORM_P_A
          end

          if p_a
            ok = true
            p_a.each do |p|
              ok = p[ self ]
              ok or break
            end
            ok && super
          else
            super
          end
        end

        def receive_bad_enum_value x, name_i, enum_box  # :+#hook-near
          maybe_send_event :error, :invalid_property_value do
            bld_bad_enum_value_event x, name_i, enum_box
          end
        end

        define_method :bld_bad_enum_value_event, Entity_.build_bad_enum_value_event_method_proc

        def maybe_send_event * i_a, & ev_p
          @__methodic_actor_handle_event_selectively__.call( * i_a, & ev_p )
        end
      end
    end
  end
end
