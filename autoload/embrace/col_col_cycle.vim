" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/dubs_style_guard#💂
" License: GPLv3 / Copyright © 2009, 2015-2017, 2024 Landon Bouma.
" Summary: colorcolumn style toggle (cycler)

" -------------------------------------------------------------------

" ABOUT: Cycle (toggle) through Line Length Style profiles,
"          which affect highlighting and enforcement rules.

" -------------------------------------------------------------------

" Pick a style, any style.
let g:style_guard_line_len_style = {
  \ 'colorcolumn_only': 0,
  \ 'autowrap_and_highlight': 1,
  \ 'with_highlight': 2,
  \ 'all_off': 3,
  \ 'highlight_violators': 4,
  \ }

let s:linestyle_colorcolumn_only = 0
let s:linestyle_autowrap_and_highlight = 1
let s:linestyle_with_highlight = 2
let s:linestyle_all_off = 3
let s:linestyle_highlight_violators = 4

let s:linestyle_count = len(g:style_guard_line_len_style)

" -------------------------------------------------------------------

function! s:PrepareDefaults(linestyle = -1) abort
  let w:linestyle_default = get(
    \ g:, 'colorcolumn_linestyle_default', s:linestyle_colorcolumn_only
    \ )

  if !exists('w:style_guard_line_len_style')
    let w:style_guard_line_len_style =
      \ (a:linestyle != -1) ? a:linestyle : w:linestyle_default
  endif

  if !exists('w:colcol_match_id_violatation')
    let w:colcol_match_id_violatation = -1
  endif

  if !exists('w:colcol_match_id_violators')
    let w:colcol_match_id_violators = -1
  endif

  " Highlight long lines.
  " - Rather than pick an existing highlight, e.g.:
  "     match ErrorMsg '\%>79v.\+'  " Too red
  "   We'll use our own highlight group (which also
  "   lets the user easily configure it).
  if !hlexists('ColorColumnViolation')
    " If you use dubs_after_dark colorscheme, see:
    "   ~/.vim/pack/landonb/start/dubs_after_dark/colors/after-dark.vim
    " https://github.com/landonb/dubs_after_dark#🌃
    " USAGE: Define from your config to customize.
    " - This highlights paints the first character of a long line that breaches the barrier.
    " - THOTS: DarkBlue is subtle against a black bg. Or DarkMagenta or DarkGreen.
    "   - But DarkBlue seems noticeable without being grabby about it.
    highlight ColorColumnViolation term=standout ctermbg=8 guibg=DarkBlue
  endif
endfunction

" -------------------------------------------------------------------

" When a buffer is initially read, paint its colorcolumn
" or matching ColorColumn characters.
function! g:embrace#col_col_cycle#CycleThruLineLenStyles_ApplyStyle(linestyle) abort
  call s:PrepareDefaults(a:linestyle)

  let l:on_bufenter = 1
  call s:CycleThruLineLengthGuides(l:on_bufenter)
endfunction

" -------------------------------------------------------------------

function! s:CycleThruLineLenStyles_ResetStyle() abort
  call clearmatches(winnr())

  let w:style_guard_line_len_style = w:linestyle_default

  call <SID>CycleThruLineLengthGuides(0)
endfunction

function! s:CycleThruLineLengthGuides(on_bufenter) abort
  if 1
    \ && exists('w:style_guard_line_len_style')
    \ && g:embrace#windows2#IsNormalBuffer(bufnr())
    call s:CycleThruLineLengthGuides_NormalBuffer(a:on_bufenter)
  else
    setlocal colorcolumn=
    match none
    setlocal textwidth=0
  endif
endfunction

function! s:CycleThruLineLengthGuides_NormalBuffer(on_bufenter) abort
  if a:on_bufenter == 0
    let w:style_guard_line_len_style = w:style_guard_line_len_style + 1

    if w:style_guard_line_len_style >= s:linestyle_count
      let w:style_guard_line_len_style = 0
    endif
  endif

  if has_key(
      \ {
      \   s:linestyle_all_off: 1,
      \   s:linestyle_highlight_violators: 1,
      \ },
      \ w:style_guard_line_len_style
      \ )
    " CRUMB: s:linestyle_all_off
    setlocal colorcolumn=
  else
    " The only enablement for 'colorcolumn_only', also applies to
    " 'autowrap_and_highlight' and 'with_highlight'.

    " Highlight the three columns after 'textwidth'.
    "   setlocal colorcolumn=+1,+2,+3
    " On secondbetter thought, highlight the three columns *before* textwidth.
    "   setlocal colorcolumn=-2,-1,-0
    " Except we don't always use textwidth, so be specific.
    " Lightly highlight a few columns after the 80-char width
    " to encourage frequent and effusive and copious wrapping.
    "   setlocal colorcolumn=80,81,82
    setlocal colorcolumn=77,78,79
  endif

  let l:match_priority = 100

  let l:prev_match_id_violation = w:colcol_match_id_violatation

  if w:style_guard_line_len_style == s:linestyle_highlight_violators
    " - NTRST: Highlight individual characters over the line limit,
    "          vs. having a single column painted top-to-bottom.
    " - SAVVY: If you use a light ColorColumn highlight so that the
    "   colorcolumn columns aren't too bright, you might find the
    "   individual character highlights too dim.
    "   - MAYBE: We could support another highlight, e.g.,
    "     ColorColumnViolators. Or not. It's nice that the violator
    "     highlights aren't that bright, either.
    let w:colcol_match_id_violatation = matchadd(
      \ 'ColorColumn', '\%77v', l:match_priority
      \ )
  else
    silent! call matchdelete(w:colcol_match_id_violatation)

    let w:colcol_match_id_violatation = -1
  endif

  let l:prev_match_id_violators = w:colcol_match_id_violators

  let l:match_description = 'undef'
  if 0
      \ || (w:style_guard_line_len_style == s:linestyle_autowrap_and_highlight)
      \ || (w:style_guard_line_len_style == s:linestyle_with_highlight)

    if w:colcol_match_id_violators == -1
      let w:colcol_match_id_violators = matchadd(
        \ 'ColorColumnViolation', '\%>79v.\+', l:match_priority
        \ )
    endif
    let l:match_description = '>79'
  else
    " CRUMB: s:linestyle_all_off
    silent! call matchdelete(w:colcol_match_id_violators)

    let w:colcol_match_id_violators = -1
    let l:match_description = 'none'
  endif

  if w:style_guard_line_len_style == s:linestyle_autowrap_and_highlight
    " Enforce a 79 character line max -- if the user is typing, forcefully
    " wrap the line at 80 chars, but if the user copies and pastes, or if
    " the user appends to an existing long line, then don't care.
    setlocal textwidth=79
  else
    " Don't interfere with the programmer and split long lines as they're
    " being typed.
    " CRUMB: s:linestyle_all_off
    setlocal textwidth=0
  endif

  if a:on_bufenter == 0
    echomsg 'Long-line enforcement: '
            \ . printf('match=%-6s', l:match_description)
            \ . printf('tw=%-3s', &textwidth)
            \ . printf('cc=%-9s', &colorcolumn)
            \ . printf('match_id_one=%-5d', w:colcol_match_id_violatation)
            \ . printf('prev_id_one=%-5d', l:prev_match_id_violation)
            \ . printf('match_id_all=%-5d', w:colcol_match_id_violators)
            \ . printf('prev_id_all=%-5d', l:prev_match_id_violators)
  endif
endfunction

" -------------------------------------------------------------------

function! s:CreateAutocmds(default_line_style) abort
  let l:linestyle = g:style_guard_line_len_style[a:default_line_style]

  execute 'autocmd BufEnter,BufRead * call '
    \ .. 'g:embrace#col_col_cycle#CycleThruLineLenStyles_ApplyStyle(' .. l:linestyle .. ')'
endfunction

function! s:CreateMaps(
  \ key_sequence_cycle = '<Leader>dr',
  \ key_sequence_reset = '<Leader>dR',
) abort
  nnoremap <silent> <expr> <script> <Plug>(style-guide-color-column-cycle)
    \ <SID>CycleThruLineLengthGuides(0)

  nnoremap <silent> <expr> <script> <Plug>(style-guide-color-column-reset)
    \ <SID>CycleThruLineLenStyles_ResetStyle()

  execute 'nnoremap <silent> ' .. a:key_sequence_cycle .. ' <Plug>(style-guide-color-column-cycle)'

  execute 'nnoremap <silent> ' .. a:key_sequence_reset .. ' <Plug>(style-guide-color-column-reset)'
endfunction

" -------------------------------------------------------------------

" DEVEL: After editing file, <F9> to :source (using plugin:)
"          https://github.com/embrace-vim/vim-source-reloader#↩️
"        Then run:
"          call g:embrace#col_col_cycle#Enable()

function! g:embrace#col_col_cycle#Enable(
  \ key_sequence_cycle = '<Leader>dr',
  \ key_sequence_reset = '<Leader>dR',
  \ default_line_style = 'colorcolumn_only',
  \ ) abort
  call s:CreateAutocmds(a:default_line_style)
  call s:CreateMaps(a:key_sequence_cycle, a:key_sequence_reset)
endfunction

