
# line 1 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"

# line 193 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"


module Skylab__BeautySalon

  # (it's not strictly necessary, but creating our own modules and being
  # standalone (rather than using the modules and facilities of our host
  # sidesystem) makes it easier for us to implement the detection of
  # warnings for reasons explained at #spot1.3 but keep in mind this could change.)

  class CrazyTownMagnetics___Selector_via_String__Grammar_

    class << self
      def call_by & p
        new( & p ).execute
      end
      private :new
    end  # >>

    def initialize
      yield self
      @_did_finish = false
    end

    attr_writer(
      :input_string,
      :listener,
      :on_callish_identifier,
      :on_error_message,
      :on_is_AND_not_OR,
      :on_literal_string,
      :on_regex_body,
      :on_test_identifier,
      :on_true_keyword,
    )

    def execute

      @THE_data = @input_string.unpack C_STAR

      @THE_data.push 0
        # make this look like a null-terminated string in C
        # (there might be a more elegant/idiomatic way, but for now we
        # just want to fly close to the C-hosted version of this.)

      eof = @THE_data.length

      # -- begin exactly [#020.B] as documented exhaustively there.

      # (this list was originally generated. it is a known fragility/liabilitly as documented at [#same])

      _my_grammar_actions = nil
      _my_grammar_eof_actions = nil
      _my_grammar_index_offsets = nil
      _my_grammar_indicies = nil
      _my_grammar_key_offsets = nil
      _my_grammar_range_lengths = nil
      _my_grammar_single_lengths = nil
      _my_grammar_trans_actions = nil
      _my_grammar_trans_keys = nil
      _my_grammar_trans_targs = nil
      my_grammar_start = nil
      _NOT_USED_my_grammar_first_final = nil
      _NOT_USED_my_grammar_error = nil
      _NOT_USED_my_grammar_en_main = nil

      sym_a, arrays = Lazy_guy___[]
      bnd = binding
      sym_a.each do |m|
        bnd.local_variable_set m, arrays.send( m )
      end

      # -- end intense hack

      # stack = []
      
# line 81 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rb"
begin
	p ||= 0
	pe ||= @THE_data.length
	@THE_cs = my_grammar_start
end

# line 268 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
      @_binding = binding  # you're gonna want the `p` and `pe` local generated above #here1
      # hello i'm bewteen init and exec
      
# line 92 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if @THE_cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _my_grammar_key_offsets[@THE_cs]
	_trans = _my_grammar_index_offsets[@THE_cs]
	_klen = _my_grammar_single_lengths[@THE_cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if @THE_data[p].ord < _my_grammar_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif @THE_data[p].ord > _my_grammar_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _my_grammar_range_lengths[@THE_cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if @THE_data[p].ord < _my_grammar_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif @THE_data[p].ord > _my_grammar_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	@THE_cs = _my_grammar_trans_targs[_trans]
	if _my_grammar_trans_actions[_trans] != 0
		_acts = _my_grammar_trans_actions[_trans]
		_nacts = _my_grammar_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _my_grammar_actions[_acts - 1]
when 0 then
# line 22 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_callish_identifier[ _release_string_buffer ]
  		end
when 1 then
# line 26 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_is_AND_not_OR[ false ]
  		end
when 2 then
# line 30 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_is_AND_not_OR[ true ]
  		end
when 3 then
# line 34 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_test_identifier[ _release_string_buffer ]
  		end
when 4 then
# line 38 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_regex_body[ _release_string_buffer ]
  		end
when 5 then
# line 42 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_literal_string[ _release_string_buffer ]
  		end
when 6 then
# line 46 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @on_true_keyword[]
    nil
  		end
when 7 then
# line 51 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @__begin_offset_for_string_buffer = p  # current_position_
  		end
when 8 then
# line 55 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    __terminate_string_buffer
  		end
when 9 then
# line 59 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @_bytes = []
  		end
when 10 then
# line 63 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    @_bytes.push @THE_data.fetch p
  		end
when 11 then
# line 67 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin

    _d_a = remove_instance_variable :@_bytes
    @_current_string_buffer = _d_a.pack( C_STAR ).freeze
  		end
when 12 then
# line 78 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting true keyword" ); 		end
when 13 then
# line 87 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting callish identifier ([a-z][_a-z0-9]*)" ); 		end
when 14 then
# line 112 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '=='" ); 		end
when 15 then
# line 113 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '='" ); 		end
when 16 then
# line 116 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting open single quote" ); 		end
when 17 then
# line 122 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting close single quote" ); 		end
when 18 then
# line 127 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '=~'" ); 		end
when 19 then
# line 128 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '~'" ); 		end
when 20 then
# line 131 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting open forward slash" ); 		end
when 21 then
# line 137 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting close forward slash" ); 		end
when 22 then
# line 142 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting identifier" ); 		end
when 23 then
# line 154 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '&&'" ); 		end
when 24 then
# line 155 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '&'" ); 		end
when 25 then
# line 166 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '||'" ); 		end
when 26 then
# line 167 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '|'" ); 		end
when 27 then
# line 182 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting open parenthesis" ); 		end
when 28 then
# line 187 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting close parenthesis" ); 		end
when 29 then
# line 189 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting end of input" ); 		end
when 30 then
# line 190 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 @_did_finish = true; 		end
# line 322 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if @THE_cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	__acts = _my_grammar_eof_actions[@THE_cs]
	__nacts =  _my_grammar_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _my_grammar_actions[__acts - 1]
when 12 then
# line 78 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting true keyword" ); 		end
when 13 then
# line 87 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting callish identifier ([a-z][_a-z0-9]*)" ); 		end
when 14 then
# line 112 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '=='" ); 		end
when 15 then
# line 113 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '='" ); 		end
when 16 then
# line 116 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting open single quote" ); 		end
when 17 then
# line 122 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting close single quote" ); 		end
when 18 then
# line 127 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '=~'" ); 		end
when 19 then
# line 128 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '~'" ); 		end
when 20 then
# line 131 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting open forward slash" ); 		end
when 21 then
# line 137 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting close forward slash" ); 		end
when 22 then
# line 142 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting identifier" ); 		end
when 23 then
# line 154 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '&&'" ); 		end
when 24 then
# line 155 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '&'" ); 		end
when 25 then
# line 166 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '||'" ); 		end
when 26 then
# line 167 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting '|'" ); 		end
when 27 then
# line 182 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting open parenthesis" ); 		end
when 28 then
# line 187 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting close parenthesis" ); 		end
when 29 then
# line 189 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
		begin
 oops( "expecting end of input" ); 		end
# line 422 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
	end
	end
	if _goto_level <= _out
		break
	end
	end
end

# line 271 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
      @_did_finish
    end

    # -- parsing support (methods that appear in actions)

    def __terminate_string_buffer
      _begin = remove_instance_variable :@__begin_offset_for_string_buffer
      _end = current_position_
      @_current_string_buffer =
        @THE_data[ _begin ... _end ].pack( C_STAR ).freeze
    end

    def _release_string_buffer
      remove_instance_variable :@_current_string_buffer
    end

    # --

    def oops msg
      @on_error_message[ msg ]
    end

    def current_position_
      @_binding.local_variable_get :p
    end

    attr_reader(
      :THE_data,
    )

    # ==
    # see note [#020.B]

    Lazy_guy___ = -> do

      tuple = -> do
        arrays = module TABLES____  # is module just for debuggability
          # hello: begin write data
          
# line 476 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rb"
class << self
	attr_accessor :_my_grammar_actions
	private :_my_grammar_actions, :_my_grammar_actions=
end
self._my_grammar_actions = [
	0, 1, 1, 1, 2, 1, 6, 1, 
	7, 1, 9, 1, 10, 1, 13, 1, 
	16, 1, 17, 1, 20, 1, 21, 1, 
	22, 1, 24, 1, 26, 1, 27, 1, 
	28, 1, 29, 1, 30, 2, 8, 0, 
	2, 8, 3, 2, 9, 10, 2, 11, 
	4, 2, 11, 5, 2, 14, 18, 2, 
	15, 19, 2, 22, 12, 2, 23, 28, 
	2, 25, 28, 3, 8, 3, 6, 3, 
	9, 11, 4, 3, 9, 11, 5, 3, 
	14, 18, 28, 3, 23, 25, 28
]

class << self
	attr_accessor :_my_grammar_key_offsets
	private :_my_grammar_key_offsets, :_my_grammar_key_offsets=
end
self._my_grammar_key_offsets = [
	0, 0, 2, 8, 14, 16, 18, 20, 
	23, 26, 27, 35, 38, 40, 43, 47, 
	51, 56, 57, 61, 69, 72, 74, 77, 
	81, 85, 89, 89, 92, 96, 100, 100, 
	101, 105, 113, 116, 118, 121, 125, 129, 
	133, 133, 136, 140, 144, 144, 144, 147, 
	151, 155, 155, 165, 175, 185, 194, 198
]

class << self
	attr_accessor :_my_grammar_trans_keys
	private :_my_grammar_trans_keys, :_my_grammar_trans_keys=
end
self._my_grammar_trans_keys = [
	97, 122, 40, 95, 48, 57, 97, 122, 
	9, 32, 84, 116, 97, 122, 82, 114, 
	85, 117, 69, 101, 9, 32, 41, 9, 
	32, 41, 0, 9, 32, 61, 95, 48, 
	57, 97, 122, 9, 32, 61, 61, 126, 
	9, 32, 39, 39, 92, 32, 126, 39, 
	92, 32, 126, 9, 32, 38, 41, 124, 
	38, 9, 32, 97, 122, 9, 32, 61, 
	95, 48, 57, 97, 122, 9, 32, 61, 
	61, 126, 9, 32, 39, 39, 92, 32, 
	126, 39, 92, 32, 126, 9, 32, 38, 
	41, 9, 32, 47, 47, 92, 32, 126, 
	47, 92, 32, 126, 124, 9, 32, 97, 
	122, 9, 32, 61, 95, 48, 57, 97, 
	122, 9, 32, 61, 61, 126, 9, 32, 
	39, 39, 92, 32, 126, 39, 92, 32, 
	126, 9, 32, 41, 124, 9, 32, 47, 
	47, 92, 32, 126, 47, 92, 32, 126, 
	9, 32, 47, 47, 92, 32, 126, 47, 
	92, 32, 126, 9, 32, 61, 82, 95, 
	114, 48, 57, 97, 122, 9, 32, 61, 
	85, 95, 117, 48, 57, 97, 122, 9, 
	32, 61, 69, 95, 101, 48, 57, 97, 
	122, 9, 32, 41, 61, 95, 48, 57, 
	97, 122, 9, 32, 41, 61, 0
]

class << self
	attr_accessor :_my_grammar_single_lengths
	private :_my_grammar_single_lengths, :_my_grammar_single_lengths=
end
self._my_grammar_single_lengths = [
	0, 0, 2, 4, 2, 2, 2, 3, 
	3, 1, 4, 3, 2, 3, 2, 2, 
	5, 1, 2, 4, 3, 2, 3, 2, 
	2, 4, 0, 3, 2, 2, 0, 1, 
	2, 4, 3, 2, 3, 2, 2, 4, 
	0, 3, 2, 2, 0, 0, 3, 2, 
	2, 0, 6, 6, 6, 5, 4, 0
]

class << self
	attr_accessor :_my_grammar_range_lengths
	private :_my_grammar_range_lengths, :_my_grammar_range_lengths=
end
self._my_grammar_range_lengths = [
	0, 1, 2, 1, 0, 0, 0, 0, 
	0, 0, 2, 0, 0, 0, 1, 1, 
	0, 0, 1, 2, 0, 0, 0, 1, 
	1, 0, 0, 0, 1, 1, 0, 0, 
	1, 2, 0, 0, 0, 1, 1, 0, 
	0, 0, 1, 1, 0, 0, 0, 1, 
	1, 0, 2, 2, 2, 2, 0, 0
]

class << self
	attr_accessor :_my_grammar_index_offsets
	private :_my_grammar_index_offsets, :_my_grammar_index_offsets=
end
self._my_grammar_index_offsets = [
	0, 0, 2, 7, 13, 16, 19, 22, 
	26, 30, 32, 39, 43, 46, 50, 54, 
	58, 64, 66, 70, 77, 81, 84, 88, 
	92, 96, 101, 102, 106, 110, 114, 115, 
	117, 121, 128, 132, 135, 139, 143, 147, 
	152, 153, 157, 161, 165, 166, 167, 171, 
	175, 179, 180, 189, 198, 207, 215, 220
]

class << self
	attr_accessor :_my_grammar_trans_targs
	private :_my_grammar_trans_targs, :_my_grammar_trans_targs=
end
self._my_grammar_trans_targs = [
	2, 0, 3, 2, 2, 2, 0, 3, 
	3, 4, 50, 10, 0, 5, 5, 0, 
	6, 6, 0, 7, 7, 0, 8, 8, 
	9, 0, 8, 8, 9, 0, 55, 0, 
	11, 11, 12, 10, 10, 10, 0, 11, 
	11, 12, 0, 13, 46, 0, 13, 13, 
	14, 0, 16, 45, 15, 0, 16, 45, 
	15, 0, 16, 16, 17, 9, 31, 0, 
	18, 0, 18, 18, 19, 0, 20, 20, 
	21, 19, 19, 19, 0, 20, 20, 21, 
	0, 22, 27, 0, 22, 22, 23, 0, 
	25, 26, 24, 0, 25, 26, 24, 0, 
	25, 25, 17, 9, 0, 24, 27, 27, 
	28, 0, 25, 30, 29, 0, 25, 30, 
	29, 0, 29, 32, 0, 32, 32, 33, 
	0, 34, 34, 35, 33, 33, 33, 0, 
	34, 34, 35, 0, 36, 41, 0, 36, 
	36, 37, 0, 39, 40, 38, 0, 39, 
	40, 38, 0, 39, 39, 9, 31, 0, 
	38, 41, 41, 42, 0, 39, 44, 43, 
	0, 39, 44, 43, 0, 43, 15, 46, 
	46, 47, 0, 16, 49, 48, 0, 16, 
	49, 48, 0, 48, 11, 11, 12, 5, 
	10, 51, 10, 10, 0, 11, 11, 12, 
	6, 10, 52, 10, 10, 0, 11, 11, 
	12, 7, 10, 53, 10, 10, 0, 54, 
	54, 9, 12, 10, 10, 10, 0, 54, 
	54, 9, 12, 0, 0, 0
]

class << self
	attr_accessor :_my_grammar_trans_actions
	private :_my_grammar_trans_actions, :_my_grammar_trans_actions=
end
self._my_grammar_trans_actions = [
	7, 13, 37, 0, 0, 0, 29, 0, 
	0, 0, 7, 7, 58, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 5, 5, 
	5, 31, 0, 0, 0, 31, 35, 33, 
	40, 40, 40, 0, 0, 0, 52, 0, 
	0, 0, 52, 0, 0, 55, 0, 0, 
	0, 15, 75, 9, 43, 17, 49, 0, 
	11, 17, 0, 0, 3, 0, 1, 83, 
	0, 25, 0, 0, 7, 23, 40, 40, 
	40, 0, 0, 0, 52, 0, 0, 0, 
	52, 0, 0, 55, 0, 0, 0, 15, 
	75, 9, 43, 17, 49, 0, 11, 17, 
	0, 0, 3, 0, 61, 11, 0, 0, 
	0, 19, 71, 9, 43, 21, 46, 0, 
	11, 21, 11, 0, 27, 0, 0, 7, 
	23, 40, 40, 40, 0, 0, 0, 52, 
	0, 0, 0, 52, 0, 0, 55, 0, 
	0, 0, 15, 75, 9, 43, 17, 49, 
	0, 11, 17, 0, 0, 0, 1, 64, 
	11, 0, 0, 0, 19, 71, 9, 43, 
	21, 46, 0, 11, 21, 11, 11, 0, 
	0, 0, 19, 71, 9, 43, 21, 46, 
	0, 11, 21, 11, 40, 40, 40, 0, 
	0, 0, 0, 0, 52, 40, 40, 40, 
	0, 0, 0, 0, 0, 52, 40, 40, 
	40, 0, 0, 0, 0, 0, 52, 67, 
	67, 5, 40, 0, 0, 0, 79, 0, 
	0, 0, 0, 79, 0, 0
]

class << self
	attr_accessor :_my_grammar_eof_actions
	private :_my_grammar_eof_actions, :_my_grammar_eof_actions=
end
self._my_grammar_eof_actions = [
	0, 13, 29, 58, 0, 0, 0, 31, 
	31, 33, 52, 52, 55, 15, 17, 17, 
	83, 25, 23, 52, 52, 55, 15, 17, 
	17, 61, 0, 19, 21, 21, 0, 27, 
	23, 52, 52, 55, 15, 17, 17, 64, 
	0, 19, 21, 21, 0, 0, 19, 21, 
	21, 0, 52, 52, 52, 79, 79, 0
]

class << self
	attr_accessor :my_grammar_start
end
self.my_grammar_start = 1;
class << self
	attr_accessor :my_grammar_first_final
end
self.my_grammar_first_final = 55;
class << self
	attr_accessor :my_grammar_error
end
self.my_grammar_error = 0;

class << self
	attr_accessor :my_grammar_en_main
end
self.my_grammar_en_main = 1;


# line 310 "lib/skylab/beauty_salon/crazy-town-magnetics-/selector-via-string/grammar-.rl"
          # hello: end write data
          self
        end

        a = []
        a.push arrays.instance_variables.map { |sym| sym[ 1..-1 ].intern }
        a.push arrays
        tuple = -> { a } ; a
      end

      -> { tuple[] }
    end.call

    # ==

    C_STAR = 'c*'

    # ==
    # ==
  end
end
# #history-A.1: experimentally try fragile efficientizing thing
# #born
