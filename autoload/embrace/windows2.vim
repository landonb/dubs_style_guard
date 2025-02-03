" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/dubs_style_guard#💂
" License: GPLv3 / Copyright © 2024 Landon Bouma.

" -------------------------------------------------------------------

" COPYD: See original for comment TMI.
" ~/.kit/nvim/embrace-vim/start/vim-buffer-delights/autoload/embrace/windows.vim
"
" NAMED: windows2.vim to not conflict with the original:
" ~/.kit/nvim/embrace-vim/start/vim-buffer-delights/autoload/embrace/windows.vim
" (or maybe Vim is smart enough to check same-named autoload files? probably).

function! g:embrace#windows2#IsNormalBuffer(bufnr) abort
  let l:bufnr = bufnr(a:bufnr)

  if l:bufnr == -1

    return 0
  endif

  let l:ftype = getbufvar(l:bufnr, "&filetype")

  if 0
    \ || getbufvar(l:bufnr, '&buftype') != ''
    \ || getbufvar(l:bufnr, "&previewwindow")
    \ || !getbufvar(l:bufnr, "&modifiable")
    \ || !buflisted(l:bufnr)
    \ || l:ftype == 'qf'
    \ || l:ftype == 'git'
    \ || l:ftype == 'fugitiveblame'
    \ || bufname(l:bufnr) == '-MiniBufExplorer-'

    return 0
  endif

  return 1
endfunction

