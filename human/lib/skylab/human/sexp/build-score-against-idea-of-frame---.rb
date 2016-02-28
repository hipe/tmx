module Skylab::Human

  class NLP::Expression_Frame

    Actors_ = ::Module.new

    module Actors_::Build_score_against_idea_of_frame

      my_proc = -> idea, frame_mod do

        d = __score_required_terms 0, idea, frame_mod
        d &&= __score_optional_terms d, idea, frame_mod

        # (the above are put before below for grease only)
        d &&= __score_produces d, idea, frame_mod

        d and Score___.new( d, idea, frame_mod )
      end

      define_singleton_method :[], my_proc
      define_singleton_method :call, my_proc

      class << self

        def __score_produces simple_score_d, idea, frame_mod

          sym = idea.syntactic_category
          if sym
            _yes = frame_mod::PRODUCES.include? sym
            _yes or simple_score_d = nil
          end
          simple_score_d
        end

        def __score_required_terms simple_score_d, idea, frame_mod

          frame_mod::REQUIRED_TERMS.each do | sym |

            _has = idea.send sym
            if _has
              simple_score_d += 1
            else
              simple_score_d = nil
              break
            end
          end
          simple_score_d
        end

        def __score_optional_terms simple_score_d, idea, frame_mod

          a = frame_mod::OPTIONAL_TERMS
          if a
            a.each do | sym |

              _has = idea.send sym
              if _has
                simple_score_d += 1
              end
            end
          end
          simple_score_d
        end
      end  # >>

      class Score___

        include ::Comparable

        def initialize d, idea, frame_mod
          @_d = d
          @_frame_mod = frame_mod
          @_idea = idea
        end

        def <=> otr
          if otr.kind_of? Score___
            @_d <=> otr._d
          end
        end

        def to_expression_frame
          @_frame_mod.new_via_idea @_idea
        end

      protected
        attr_reader :_d
      end
    end
  end
end
