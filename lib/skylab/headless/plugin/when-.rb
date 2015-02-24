module Skylab

  module Headless

    class Plugin

      When_ = ::Module.new

      When_::Unused_Actuals = Callback_::Event.prototype_with :unused_actuals,

          :box, nil, :steps, nil, :plugins, nil do | y, o |

        # just for fun we make a hand-written :+[#it-002] EN expression of
        # aggregation:
        #
        # "the application would finish by expressing help before it would
        # build hob-nobbers or flush dingle-hoofers, making the '--foo'
        # option meaningless. also, '--x' would never be processed because
        # zipping the dipple [ or dopping the nopple ] would never happen."
        #
        # sentence 1 and sentence 2..N have different templates, which we
        # implement by processing the matrix as a stream.

        formal_and_plugins_matrix = o.box.to_enum( :each_value ).map do | unused_a |

          fo = nil
          _or_s_a = unused_a.map do | unused |

            fo ||= unused.formal  # use the first one for its name

            _pu = o.plugins.fetch( unused.plugin_idx )

            _pu.name.as_human

          end
          [ fo, _or_s_a ]
        end

        st = Callback_::Stream.via_nonsparse_array formal_and_plugins_matrix

        fo, or_s_a = st.gets

        pu = o.plugins.fetch o.steps.last.plugin_idx

        y << "the application would finish by #{
         }#{ progressive_verb pu.name.as_human } #{
          }before it would #{ or_ or_s_a }, making the #{
           }'#{ fo.local_identifier_x }' option meaningless."

        begin
          fo, or_s_a = st.gets
          fo or break
          or_s_a.map!( & method( :progressive_verb ) )

          y << "also, '#{ fo.local_identifier_x }' would never be processed #{
           }because #{ or_ or_s_a } would never happen"

          redo
        end while nil
      end
    end
  end
end
