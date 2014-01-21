"=============================================================================
" FILE: view.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 06 Oct 2013.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! vinarise#view#print_error(string) "{{{
  echohl Error | echo a:string | echohl None
endfunction"}}}
function! vinarise#view#print_lines(lines, ...) "{{{
  " Get last address.
  if a:0 >= 1
    let address = a:1
  else
    let [_, address] = vinarise#helper#parse_address(
          \ (a:lines < 0 ? getline(1) : getline('$')), '')
  endif

  let line_address = address / b:vinarise.width

  if a:lines < 0
    let max_lines = line_address + a:lines
    if max_lines < 0
      let max_lines = 0
    endif
    let line_numbers = range(max_lines, line_address-1)
  else
    let max_lines = b:vinarise.filesize / b:vinarise.width

    if max_lines > line_address + a:lines
      let max_lines = line_address + a:lines
    endif
    if max_lines - line_address < winheight(0)
          \ && line('$') == 1
      let line_address = max_lines - winheight(0) + 1
    endif
    if line_address < 0
      let line_address = 0
    endif
    let line_numbers = range(line_address, max_lines)
  endif

  let lines = []
  for line_nr in line_numbers
    call add(lines, vinarise#view#make_line(line_nr))
  endfor

  setlocal modifiable
  let modified_save = &l:modified

  if a:lines < 0
    call append(0, lines)
  else
    call setline('$', lines)
  endif

  let &l:modified = modified_save
  setlocal nomodifiable
endfunction"}}}
function! vinarise#view#make_line(line_address) "{{{
  " Make new line.
  let bytes = b:vinarise.get_bytes(
        \ a:line_address * b:vinarise.width, b:vinarise.width)

  let ascii_line =
        \ vinarise#multibyte#make_ascii_line(a:line_address, bytes)

  let hex_line = ''
  for offset in range(0, b:vinarise.width - 1)
    let hex_line .= offset >= len(bytes) ?
          \ '   ' : printf('%02x', bytes[offset]) . ' '
  endfor

  return printf('%07x0: %-48s|%s',
        \ a:line_address, hex_line, ascii_line)
endfunction"}}}

function! vinarise#view#set_cursor_address(address) "{{{
  let line_address = (a:address / b:vinarise.width) * b:vinarise.width
  let hex_line = repeat(' \x\x', a:address - line_address + 1)
  let [lnum, col] = searchpos(
        \ printf('%08x:%s', line_address, hex_line), 'cew')
  call cursor(lnum, col-1)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker