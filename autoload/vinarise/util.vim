"=============================================================================
" FILE: util.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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

function! vinarise#util#get_vital() abort "{{{
  if !exists('s:V')
    let s:V = vital#vinarise#new()
  endif
  return s:V
endfunction"}}}
function! s:get_prelude() abort "{{{
  if !exists('s:Prelude')
    let s:Prelude = vinarise#util#get_vital().import('Prelude')
  endif
  return s:Prelude
endfunction"}}}
function! s:get_string() abort "{{{
  if !exists('s:String')
    let s:String = vinarise#util#get_vital().import('Data.String')
  endif
  return s:String
endfunction"}}}
function! s:get_list() abort "{{{
  if !exists('s:List')
    let s:List = vinarise#util#get_vital().import('Data.List')
  endif
  return s:List
endfunction"}}}
function! s:get_process() abort "{{{
  if !exists('s:Process')
    let s:Process = vinarise#util#get_vital().import('Process')
  endif
  return s:Process
endfunction"}}}

function! vinarise#util#truncate_smart(...) abort "{{{
  return call(s:get_string().truncate_skipping, a:000)
endfunction"}}}

function! vinarise#util#truncate(...) abort "{{{
  return call(s:get_string().truncate, a:000)
endfunction"}}}

function! vinarise#util#strchars(...) abort "{{{
  return call(s:get_string().strchars, a:000)
endfunction"}}}

function! vinarise#util#strwidthpart(...) abort "{{{
  return call(s:get_string().strwidthpart, a:000)
endfunction"}}}
function! vinarise#util#strwidthpart_reverse(...) abort "{{{
  return call(s:get_string().strwidthpart_reverse, a:000)
endfunction"}}}
function! vinarise#util#is_windows(...) abort "{{{
  return call(s:get_prelude().is_windows, a:000)
endfunction"}}}
function! vinarise#util#is_mac(...) abort "{{{
  return call(s:get_prelude().is_mac, a:000)
endfunction"}}}

function! s:buflisted(bufnr) abort "{{{
  return exists('t:unite_buffer_dictionary') ?
        \ has_key(t:unite_buffer_dictionary, a:bufnr) && buflisted(a:bufnr) :
        \ buflisted(a:bufnr)
endfunction"}}}

function! vinarise#util#expand(path) abort "{{{
  return s:get_prelude().substitute_path_separator(
        \ (a:path =~ '^\~') ? substitute(a:path, '^\~', expand('~'), '') :
        \ (a:path =~ '^\$\h\w*') ? substitute(a:path,
        \               '^\$\h\w*', '\=eval(submatch(0))', '') :
        \ a:path)
endfunction"}}}

function! vinarise#util#substitute_path_separator(...) abort "{{{
  return call(s:get_prelude().substitute_path_separator, a:000)
endfunction"}}}
function! vinarise#util#escape_file_searching(...) abort "{{{
  return call(s:get_prelude().escape_file_searching, a:000)
endfunction"}}}
function! vinarise#util#iconv(...) abort "{{{
  return call(s:get_process().iconv, a:000)
endfunction"}}}

function! vinarise#util#sort_by(...) abort "{{{
  return call(s:get_list().sort_by, a:000)
endfunction"}}}

function! vinarise#util#is_cmdwin() abort "{{{
  return bufname('%') ==# '[Command Line]'
endfunction"}}}

function! vinarise#util#alternate_buffer() abort "{{{
  if s:buflisted(bufnr('#'))
    buffer #
    return
  endif

  let listed_buffer = filter(range(1, bufnr('$')),
        \ "s:buflisted(v:val) || v:val == bufnr('%')")
  let current = index(listed_buffer, bufnr('%'))
  if current < 0 || len(listed_buffer) < 2
    enew
  else
    execute 'buffer' ((current < len(listed_buffer) / 2) ?
          \ listed_buffer[current+1] : listed_buffer[current-1])
  endif
endfunction"}}}
function! vinarise#util#delete_buffer(...) abort "{{{
  let bufnr = get(a:000, 0, bufnr('%'))
  call vinarise#util#alternate_buffer()
  execute 'bdelete!' bufnr
endfunction"}}}
function! s:buflisted(bufnr) abort "{{{
  return exists('t:unite_buffer_dictionary') ?
        \ has_key(t:unite_buffer_dictionary, a:bufnr) && buflisted(a:bufnr) :
        \ buflisted(a:bufnr)
endfunction"}}}

" vim: foldmethod=marker
