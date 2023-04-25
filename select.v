module sterm

import term
import readline

pub struct Selection {
	items []string
	hide_cursor bool
	catch_sig bool
pub mut:
	idx int
}

pub fn (s &Selection) value_at(i int) string {
	return s.items[i]
}

pub fn (s &Selection) value() string {
	return s.items[s.idx]
}

pub fn (mut s Selection) next() {
	s.idx = (s.idx + 1) % s.items.len
}

pub fn (mut s Selection) prev() {
	s.idx = (s.idx - 1 + s.items.len) % s.items.len
}

pub fn (mut s Selection) draw() {
	// term.clear()
	for i, item in s.items {
		if i == s.idx {
			print(term.green(' ◉ ${item}'))
		} else {
			print(' ○ ${item}')
		}
		term.erase_line_toend()
		// term.cursor_down(1)
		println("")
	}
}

pub fn (mut s Selection) redraw() {
	term.cursor_up(s.items.len)
	s.draw()
}

pub fn (mut s Selection) run() {
	if s.hide_cursor {
		term.hide_cursor()
		defer {
			term.show_cursor()
		}
	}
	mut r := readline.Readline{}
	if s.catch_sig {
		r.enable_raw_mode()
	} else {
		r.enable_raw_mode_nosig()
	}
	defer {
		r.disable_raw_mode()
	}

	mut cmd_state := CommandState{
		stack: []int{cap: 3}
	}
	for {
		entered := r.read_char() or { panic(err) }
		code := unsafe { KeyCode(entered) }
		// dump(typeof(entered).name)
		// dump(code)
		// println('got ${entered}')

		match cmd_state.stack.len {
			0 {
				match code {
					.enter {
						break
					}
					.escape {
						cmd_state.stack << entered
					}
					else {
						// dump(code)
					}
				}
			}
			1 {
				match code {
					.escape {
						eprintln('Exiting selection')
						exit(0)
					}
					else {
						cmd_state.stack << entered
					}
				}
			}
			2 {
				match entered {
					65 {
						s.prev()
						s.redraw()
					}
					66 {
						s.next()
						s.redraw()
					}
					else {
						// eprintln('unexpected')
						// dump(cmd_state)
						// dump(entered)
					}
				}
				cmd_state.stack.clear()
			}
			else {
				// eprintln('unexpected')
				// dump(cmd_state)
				// dump(entered)
				// exit(1)
			}
		}
	}
	for _ in 0..s.items.len {
		term.clear_previous_line()
	}
}

pub struct CommandState {
mut:
	stack []int
}

pub enum KeyCode {
	tab = 9
	enter = 13
	escape = 27
	space = 32
	delete = 127
	exclamation = 33
	double_quote = 34
	hashtag = 35
	dollar = 36
	percent = 37
	ampersand = 38
	single_quote = 39
	left_paren = 40
	right_paren = 41
	asterisk = 42
	plus = 43
	comma = 44
	minus = 45
	period = 46
	slash = 47
	_0 = 48
	_1 = 49
	_2 = 50
	_3 = 51
	_4 = 52
	_5 = 53
	_6 = 54
	_7 = 55
	_8 = 56
	_9 = 57
	colon = 58
	semicolon = 59
	less_than = 60
	equal = 61
	greater_than = 62
	question = 63
	at = 64
	// up = 65
	// down = 66
	// right = 67
	// left = 68
	square_bracket_left = 91
	backslash = 92
	square_bracket_right = 93
	caret = 94
	underscore = 95
	backtick = 96 // a.k.a "grave"
	a = 97
	b = 98
	c = 99
	d = 100
	e = 101
	f = 102
	g = 103
	h = 104
	i = 105
	j = 106
	k = 107
	l = 108
	m = 109
	n = 110
	o = 111
	p = 112
	q = 113
	r = 114
	s = 115
	t = 116
	u = 117
	v = 118
	w = 119
	x = 120
	y = 121
	z = 122
	curly_bracket_left = 123
	pipe = 124
	curly_bracket_right = 125
	tilde = 126
}
