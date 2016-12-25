class Skylab::Task

  module Magnetics

    o = Here_::Models::TokenStream.begin
    o.word_regex = /[A-Z][a-z]+|[a-z][a-z]+/
    o.separator_regex = /_/
    token_stream_prototoype = o.finish

    _Eek = nil

    Magnetics_::TokenStream_via_Const = -> const do

      st = token_stream_prototoype.token_stream_via_string const.id2name

      _Eek.new do
        s = st.gets
        if s
          s.downcase
        end
      end
    end

    _Eek = ::Class.new ::Proc
    _Eek.class_exec do
      alias_method :gets, :call
      def ok
        ACHIEVED_
      end
    end
  end
end
# #history: born
