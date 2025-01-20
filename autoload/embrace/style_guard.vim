" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/dubs_style_guard#💂
" License: GPLv3 / Copyright © 2009, 2015-2017, 2025 Landon Bouma.

" -------------------------------------------------------------------
"
" ------------------------------------------
" About:

" This script scans a file when the buffer is loaded and tries to
" guess the whitespace style of the document.
"
" For new documents, you can add a .dubs_style file somewhere in
" the path and specify the style therein. Use Vim modeline syntax,
" and filter by file type, if necessary.
"
" Or, you can manually switch between whitespace styles using <Leader>de.
" Caveat: The author prefers 2-character spaced indentation, but I also
"         work with 4-character tabbed indentation, so those are the two
"         recognized styles. You can easily modify the code below to use
"         different styles or to add more styles to the list.
"
" You can also enable and disable visual wrapping, automatic long-line
" breaking, and long-line highlighting using <Leader>dw from:
"   https://github.com/landonb/dubs_toggle_textwrap

" ------------------------------------------------------
" Toggle Style Guide Enforcement
" ------------------------------------------------------

" The user can cycle through the set of pre-defined style guide templates.
function! g:embrace#style_guard#CreateMaps_CycleThruStyleGuides(key_sequence = '<Leader>de') abort
  exec 'nnoremap <silent> ' .. a:key_sequence .. ' <Plug>(dubs-style-guard-cycle-thru-sytle-guides)'
  exec 'inoremap <silent> ' .. a:key_sequence .. ' <C-O><Plug>(dubs-style-guard-cycle-thru-sytle-guides)'
endfunction

