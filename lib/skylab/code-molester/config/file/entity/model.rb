module Skylab::CodeMolester::Config::File::Entity

  module Model

   # an #experiment to see how terrible an idea it is to maintain a separate
   # flyweight class and (strange base) controller class, and this module
   # to share functionality between the two..

  end

  module Model::InstanceMethods

    def inflection
      entity_story.inflection
    end

    # assumes `get_normalized_head_and_body_pairs`

    def jsonesque
      @jsonesque_renderer ||= -> do
        f = build_jsonesque_field_proc
        render_f_h = @fld_box.reduce( { } ) do |h, (nn,fld)|
          if fld.is_list
            h[ nn ] = build_function_for_list_field( f )
          else
            h[ nn ] = f
          end
          h
        end
        -> do
          a = get_normalized_head_and_body_pairs.reduce [] do |m, (nn, vx)|
            jx = render_f_h.fetch( nn ).call vx
            jx and m << "#{ nn }: #{ jx }"
            m
          end
          "{ #{ a * ', ' } }"
        end
      end.call
      @jsonesque_renderer.call
    end

    def build_jsonesque_field_proc

      #         ~ MWHAAAA HAAAA HAAAHAAHAHAHAHAHHA igaf ~
      #    (let's please just try for some normality around here)
      #      (also, why not just use a JSON library, duh #todo)
      #             (because this greases more wheels)

      f = -> x { x.inspect }
      h = {
        ::String => f,
        ::NilClass => -> x { },
        ::FalseClass => f,
        ::TrueClass => f,
      }
      h.default_proc = -> _h, k do
        raise ::KeyError, "we've just decided this is an invalid #{
          }CLASS for a normalized field to have - #{ k }"
      end
      -> vx do
        h.fetch( vx.class )[ vx ]
      end
    end
    private :build_jsonesque_field_proc

    def build_function_for_list_field f
      -> x do
        if ! x.respond_to? :reduce
          f[ x ]
        else
          a = x.reduce [] do |m, xx|
            jx = f[ xx ]
            jx and m << jx
            m
          end
          if a.length.nonzero?
            "[ #{ a * ', ' } ]"
          end
        end
      end
    end
    private :build_jsonesque_field_proc
  end
end
