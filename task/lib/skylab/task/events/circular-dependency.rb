require 'skylab/callback'

class Skylab::Task

  Events::CircularDependency = Callback_::Event.prototype_with(
    :circular_dependency,
    :task_name, nil,
    :arc_streamer, nil,
    :error_category, :argument_error,
    :ok, false,

  ) do |y, o|
    o.dup.__express_into_under y, self
  end

  # the "arc streamer" is no joke: it is a proc that builds a stream.
  # each item in the stream is a "pair" structure that represents a node
  # and all its depedencies. the `name_x` component of the pair is the
  # name function of the node. the `value_x` component is .. yet another
  # streamer. this streamer builds a stream, each item of which is the name
  # function of each depended upon node for that node. whew!

  class Events::CircularDependency  # this is :[#007]. others are like it

    class << self

      def build_via__ task, index

        _streamer = -> do

          bx = index.dependees_of_box_
          a = bx.a_
          h = bx.h_

          Callback_::Stream.via_times a.length do |d|

            k = a.fetch d

            _nf = Callback_::Name.via_variegated_symbol k  # ..

            _st_p = -> do

              sym_a = h.fetch k

              Callback_::Stream.via_times sym_a.length do |d_|

                Callback_::Name.via_variegated_symbol sym_a.fetch d_  # ..
              end
            end

            Callback_::Pair.via_value_and_name _st_p, _nf
          end
        end

        Here_.new_with(
          :arc_streamer, _streamer,
          :task_name, task.name,
        )
      end
    end  # >>

    def __express_into_under y, expag  # assume mutable, ad-hoc for task instance

      arc_st = @arc_streamer.call
      task_name = @task_name

      expag.calculate do

        y << "circular dependency detected while trying to #{ nm task_name }:"

        pair = arc_st.gets  # assume at least one

        explain = -> prefix=nil do

          name = pair.name_x
          k = name.as_variegated_symbol

          dpe_st = pair.value_x.call
          name_ = dpe_st.gets
          if name_

            done = false
            s_a = []
            begin
              if k == name_.as_variegated_symbol
                done = true
                break
              end
              s_a.push nm name_
              name_ = dpe_st.gets
            end while name_

            if done
              y << "#{ nm name } depends on itself."
              done
            else
              y << "#{ prefix }to #{ nm name } we must #{ and_ s_a }."
              NOTHING_  # keep going
            end
          else
            NOTHING_ # the node that depends on nothing gets no mention here
          end
        end

        explain_last = -> do
          explain[ "but " ]
        end

        begin
          nxt = arc_st.gets
          if nxt
            _done = explain[]
            if _done
              break
            end
            pair = nxt
            redo
          end
          explain_last[]
          break
        end while nil
      end
      y
    end

    Here_ = self
  end
end
