" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_style_guard#💂
" License: GPLv3 / Copyright © 2009, 2015-2017 Landon Bouma.
" Summary: Auto-sense Whitespace Style (spaces v. tabs)

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_dubs_style_guard_plugin
endif

if exists('g:loaded_dubs_style_guard_plugin') || &cp

  finish
endif

let g:loaded_dubs_style_guard_plugin = 1

" -------------------------------------------------------------------

" See also: tpope's Sleuth: https://github.com/tpope/vim-sleuth
"      and: http://www.vim.org/scripts/script.php?script_id=1171
"           DetectIndent: Automatically detect indent
"                         (expandtab, shiftwidth, tabstop) settings
" Sleuth is pure Vim and more complete (it doesn't consider spacing
" style of comments, for example). DetectIndent is also pure Vim.
"
" But this plugin is a decent solution, too.

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Smart Style Guide Functionality
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" If no modeline, .editorconfig, or other external settings identified,
" fallback on these predefined styles (which the user can also easily
" cycle through).
let s:dubs_style_file_modeline = -1
let s:dubs_style_2_char_spaced = 0
let s:dubs_style_4_char_tabbed = 1
let s:dubs_style_4_char_spaced = 2
" The 8-char tabbed setting is common to :help text.
" - This style is not generally an available style that the user may cycle
"   through, but it's included automatically for ft=help files. (You could
"   make always available by increasing s:dubs_styles_count).
let s:dubs_style_8_char_tabbed = 3
" Per s:dubs_styles_count (set below), the following settings
" are not cycleable with \e (unless you bump dubs_styles_count):
let s:dubs_style_2_char_tabbed = 4
let s:dubs_style_3_char_spaced = 5
let s:dubs_style_3_char_tabbed = 6
" We don't actually cycle through all of the styles above.
" We only cycle over a few of them, depending on our taste.
" Feel free to change this count to cycle over more styles.
" - Too many:
"   let s:dubs_styles_count = s:dubs_style_3_char_tabbed + 1
let s:dubs_styles_count = s:dubs_style_4_char_spaced + 1

" Default spaces and tabbed styles.

function s:DefineStyleGuardStyles() abort
  let g:dubs_style_guard_styles = {
    \ '2_char_spaced': s:dubs_style_2_char_spaced,
    \ '4_char_tabbed': s:dubs_style_4_char_tabbed,
    \ '4_char_spaced': s:dubs_style_4_char_spaced,
    \ '8_char_tabbed': s:dubs_style_8_char_tabbed,
    \ '2_char_tabbed': s:dubs_style_2_char_tabbed,
    \ '3_char_spaced': s:dubs_style_3_char_spaced,
    \ '3_char_tabbed': s:dubs_style_3_char_tabbed,
    \ }
endfunction

call s:DefineStyleGuardStyles()

" HSTRY/2025-01-19: How author embraced 2 spaces-per-tab for default spaced indentation:
" - If a file is obviously tab-indented, but there's no modeline
"   or ./.editorconfig, it's not trivial to determine the likely
"   number of spaces per tab. So we'll default to the 'tabbed'
"   value set here.
"   - In author's anecdotal experience, most tab-widths I see
"     used with tab indents is 4 spaces-per-tab, with the notable
"     exception being Vim help files, which use 8 spaces-per-tab.
"     - So we'll default to 4 spaces-per-tab with tab indentation on.
" - If a file is space-indented, or if this script fails to identify
"   the type of indentation, it falls back on the 'spaced' value
"   set here.
"   - Some reasons to use text:
"     - PEP 8 says use 4 spaces for indentation
"       https://www.python.org/dev/peps/pep-0008/
"     - Bash scripts should use spaces so copy-pasting to the
"       terminal works without triggering tab completion.
"     - Tab indents seem dated, so just assume spaced, unless not.
" - The defaults used in the this file were unstable until 2018:
"   - For a handful of years, the author wavered on the "correct"
"     number of spaces-per-tab:
"     - By 2016-11-18, I had tried three different settings for
"       reST files: 2 spaces, 4 spaces, and 3 spaces per tab.
"       - Re: 3 spt: The ".. directive" syntax in reST means blocks often
"         align after the third column. So using 3 spaces for *rstdentation*
"         can be useful.
"       - From 2016-11-18 until 2018-01-19, I tried 3 spaces-per-tab for rst.
"       - Since 2018-01-19, I've been using 2 spaces-per-tab.
"     - For other files, I tried 2 spaces for a while, then I tried 4 spaces
"       *but tabbed* from 2016-10-28 until 2016-11-18, but I reverted back to
"       using 4 *spaces* after realizing how much I disliked tab-indentation.
"       - Then on 2018-01-29, I changed from 4 down to 2 spaces-per-tab after
"         having this ephihany:
"         - THOTS/2018-01-29: You can make 4 spaces from 2, but you cannot
"                             make 2 spaces from 4. So 2 is more flexible.

if !exists('g:dubs_style_fallback_indent_width_spaced')
  let g:dubs_style_fallback_indent_width_spaced = g:dubs_style_guard_styles['2_char_spaced']
endif

if !exists('g:dubs_style_fallback_indent_width_tabbed')
  let g:dubs_style_fallback_indent_width_tabbed = g:dubs_style_guard_styles['4_char_tabbed']
endif

" User interface.

if !exists('g:dubs_style_preferred_expand_tab')
  let g:dubs_style_preferred_expand_tab = 0
endif

if !exists('g:dubs_style_preferred_indent')
  let g:dubs_style_preferred_indent = 2
endif

" How deep to `head` and `tail` for a modeline.

if !exists('g:dubs_style_search_depth_head')
  let g:dubs_style_search_depth_head = 13
endif

if !exists('g:dubs_style_search_depth_tail')
  " MAGIC: Inspect two more lines than normal.
  " - Use case: Sneak in a .txt file modeline that GitHub won't
  "             see, to render said file as .rst in your editor.
  let g:dubs_style_search_depth_tail = 7
endif

" -------------------------------------------------------------------

" ------------------------------------------------------
" Setup global autocmd (as opposed to file-specific ~/.vim/ftplugin/)
" ------------------------------------------------------

" This style is applied by default for new files and other files without
" an apparent indent scheme already in place or whose file extension is
" not recognized, such that CycleThruStyleGuides doesn't enforce the style.

" [lb] tried just BufEnter but it doesn't quite work -- e.g.,
" when toggling the Quickfix window, if we only catch BufEnter,
" when checking the buffer to see what it is, not all of its
" settings are set (so we don't know it's the Quickfix window
" on BufEnter, but on BufRead -- when it's settings are set --
" then we can deduce that the buffer is the Quickfix buffer).

" SAVVY/2025-02-14: Added BufNewFile for at least `pass edit {new-file}`.

augroup dubs_style_guard_style_guides
  au!

  autocmd BufRead,BufWritePost,BufNewFile * call s:CycleThruStyleGuides_ApplyStyle()
augroup END

function! s:CycleThruStyleGuides_ApplyStyle() abort
  if !s:CycleThruStyleGuides_VerifyBufferEligibility()

    return
  endif

  call s:CycleThruStyleGuides_SetMatch(s:dubs_style_2_char_spaced)

  call s:CycleThruStyleGuides_FixMatch()
endfunction

" ------------------------------------------------------
" Toggle Style Guide Enforcement
" ------------------------------------------------------

nnoremap <silent> <script>
  \ <Plug>(dubs-style-guard-cycle-thru-style-guides)
  \ :call <SID>CycleThruStyleGuides(0, 1, 0)<CR>

" HSTRY/2024-12-11: Was <Leader>e, but I've moved Dubs maps under \d.
call g:embrace#style_guard#CreateMaps_CycleThruStyleGuides('<Leader>de')

" 2012.10.03: I don't use the built-in Ctrl-e often -- in
" command and select mode, it moves the buffer one line up
" in the window; it doesn't do anything in insert mode. But
" it seems too built-in to remap (see :h Ctrl-e and you'll
" see it's only mapped to one key-combo).
"  NO: noremap <C-e> :call <SID>CycleThruStyleGuides()<CR><CR>
"  NO: inoremap <C-e> <C-O>:call <SID>CycleThruStyleGuides()<CR><CR>
" 2014.11.18: I started using <Leader>de more often to switch styles
" as I started working on different projects. But I also added more
" intelligence to auto-detect the current project's style whenever
" switching buffers. So I still don't manually switch styles very
" often, but it's still at least proving itself to be handy when
" needed.
" - 2024-12-11: I rarely do any manual style switching.
"   - Mostly EditorConfig and modelines do all the magic.

" ------------------------------------------------------

" We could make a more robust blocklist, but for now just don't
" run on Git commit message buffers.
" - Use case: Committing changes to a modeline.

function! s:CycleThruStyleGuides_VerifyBufferEligibility() abort
  return match(expand('%:p'), '.git/COMMIT_EDITMSG$') == -1
endfunction

" ------------------------------------------------------

" Initialize the variable used to track which template is active.
function! s:CycleThruStyleGuides_SetMatch(style_index) abort
  " NOTE: By checking exists, the style is only applied the very first time
  "       a buffer is opened (so you'll have to reload Vim to have it default
  "       back, as opposed to us not checking exists here but always resetting
  "       the style whenever the user re-enters a buffer).
  if !exists('b:dubs_style_index')
    if (g:dubs_style_preferred_indent == 2)
      if (g:dubs_style_preferred_expand_tab == 0)
        let b:dubs_style_index = s:dubs_style_2_char_spaced
      else
        let b:dubs_style_index = s:dubs_style_2_char_tabbed
      endif
    elseif (g:dubs_style_preferred_indent == 3)
      if (g:dubs_style_preferred_expand_tab == 0)
        let b:dubs_style_index = s:dubs_style_3_char_spaced
      else
        let b:dubs_style_index = s:dubs_style_3_char_tabbed
      endif
    elseif (g:dubs_style_preferred_indent == 3)
      if (g:dubs_style_preferred_expand_tab == 0)
        let b:dubs_style_index = s:dubs_style_3_char_spaced
      else
        let b:dubs_style_index = s:dubs_style_3_char_tabbed
      endif
    else
      let b:dubs_style_index = a:style_index
    endif
  endif

  if !exists('b:dubs_style_locked')
    let b:dubs_style_locked = 0
  endif
endfunction

" ------------------------------------------------------

" When a buffer is initially read, try to guess its style.
function! s:CycleThruStyleGuides_FixMatch() abort
  if exists('b:dubs_style_index')
    let l:dont_cycle = 1
    let l:do_echom = 0
    let l:force_reset = 0

    call s:CycleThruStyleGuides(l:dont_cycle, l:do_echom, l:force_reset)
  endif
endfunction

" ------------------------------------------------------

" Reset the style (possibly by reading the file for its modeline).
" - HSTRY/2024-12-11: Was <Leader>E, but I've moved Dubs maps under \d.
if !hasmapto('<Plug>DG_CycleResetLocking')
  nnoremap <silent> <Leader>dE
    \ <Plug>DG_CycleResetLocking
  inoremap <silent> <Leader>dE
    \ <Plug>DG_CycleResetLocking
endif

nnoremap <silent> <script>
  \ <Plug>DG_CycleResetLocking
  \ :call <SID>DG_CycleResetLocking()<CR>

function! s:DG_CycleResetLocking() abort
  let b:dubs_style_locked = 0

  call <SID>CycleThruStyleGuides(1, 1, 1)
endfunction

" -------------------------------------------------------------------

" ------------------------------------------------------
" Choose or Sense a Specific Indent Style or Manually Cycle Through
" ------------------------------------------------------

" ------------------------------------------

" (lb): The `expand` help indicates:
"         Note: Use |shellescape()| or |::S| with |expand()| or |fnamemodify()|
"         to escape special characters in a command argument.
"       but I'm not quite sure that the :S is all about, not in docs, didn't work for me.
function! s:ShellEscapedFullPath() abort
  return shellescape(expand('%:p'))
endfunction

" ------------------------------------------
" "Echo" to variable

" SAVVY: Vim Command name cannot be underscored, e.g., DG_CTSG_Echo is no good.
" https://stackoverflow.com/questions/8629452/is-it-possible-to-clear-message-history-in-gvim
"  command! -nargs=1 -bar Echo :let g:messages=get(g:, 'messages', [])+[<q-args>]
" This gives errors when Echo is run:
"  command! -nargs=1 -bar Echo :let g:messages=get(g:, 'messages', [])+[eval(<args>)] | echom <args>
" But using q-args works.
" FIXME: Correct stack overflow answer.
"  command! -nargs=1 -bar Echo :let g:messages=get(g:, 'messages', [])+[eval(<q-args>)] | echom <args>
" But without the echom:
command! -nargs=1 -bar DGCTSGEcho :let g:style_log=get(g:, 'style_log', [])+[eval(<q-args>)]
" ===============
" CPYST: To see the log:
" ===============
"   echo g:style_log
"   TabMessage echo g:style_log
"   for aline in g:style_log | echom " " | echom aline | endfor
" ===============
" CPYST: To clear the log:
" ===============
"   unlet g:style_log
" ===============
" NOTE: You have to use single quotes with Echo, e.g.,
"       __command__         __response__
"       Echo Whatever       E121: Undefined variable: Whatever
"       Echo "Whatever"     E471: Argument required
"       Echo 'Whatever'     Whatever

let g:style_cnt = 0

" ------------------------------------------
" The Style Guide Cycler

function! s:CycleThruStyleGuides(dont_cycle, do_echom, force_reset) abort
  if exists('g:style_log')
    unlet g:style_log

    let g:style_cnt += 1
  endif

  if (a:force_reset == 0)
    DGCTSGEcho '[#' .. g:style_cnt .. ']: Setting style: ' . expand('%:p')
  else
    DGCTSGEcho '[#' .. g:style_cnt .. ']: Resetting style: ' . expand('%:p')
  endif

  let l:change_style = 1

  if (a:dont_cycle == 1)
     \ && (b:dubs_style_locked == 1)
     \ && (a:force_reset == 0)
    DGCTSGEcho 'Style locked!'
    let l:change_style = 0
  endif

  if l:change_style == 1
    call <SID>CycleThruStyleGuides_(a:dont_cycle, a:do_echom)
  endif
endfunction

function! s:CycleThruStyleGuides_(dont_cycle, do_echom) abort
  DGCTSGEcho 'Setting style_: ' . expand('%:p')

  " FIXME: Check that the editorconfig plugin is installed, otherwise skip this.
  " Prefer an .editorconfig file over a .dubs_style.vim file or guessing.
  let s:editconf_f = findfile('.editorconfig', '.;')

  let l:bufnr = bufnr()
  let l:bufname = bufname(l:bufnr)
  let l:isreadable = filereadable(l:bufname)

  let l:use_style = 1
  " NO: \ || (&tw == 0)
  if (!exists('b:dubs_style_index')
      \ || (!l:isreadable && !g:embrace#windows2#IsNormalBuffer(l:bufnr))
      \ || ((s:editconf_f != '') && (a:dont_cycle != 0)))
    DGCTSGEcho 'Style guide: not use_style'
    let l:use_style = 0
  endif

  if !exists('b:dubs_styles_count_ft')
    let b:dubs_styles_count_ft = s:dubs_styles_count
  endif

  if (l:use_style == 1) && (a:dont_cycle == 0)
    if (&filetype == 'help')
      " When the user starts cycling through the styles, if they're looking
      " at a help file, change its filetype to 'text' first, so they can edit
      " it more easily. And leave the tabbing as it is (which is probably
      " 8-char-tabbed). The user can cycle again to change tabbing.
      set filetype=text
    else
      let b:dubs_style_index = b:dubs_style_index + 1
      if (b:dubs_style_index >= b:dubs_styles_count_ft)
        let b:dubs_style_index = 0
      endif
    endif
    " A 'locked' style simply means the user is deliberately cycling
    " through the styles, so we shouldn't reset the style for the
    " buffer automatically. This should only matter if the autocmd
    " specifies BufEnter, which it doesn't anymore.
    let b:dubs_style_locked = 1
  endif

  " We always don't use "soft tabs".
  setlocal softtabstop=0
  " BWARE: If you use dubs_edit_juice/plugin/smart-tabs.vim
  "        and set softtabstop, you'll bork the undo stack.
  "   ~/.kit/nvim/landonb/dubs_edit_juice/plugin/smart-tabs.vim
  " Bad?: setlocal softtabstop=3
  " Below, we'll set tabstop and shiftwidth.
  " Ignoring: copyindent, preserveindent.

  if (a:dont_cycle == 1) && (l:use_style == 1)
    " If user has not fixed the tab style, look for a modeline in the
    " head or tail of the buffer.
    " - If not found, we'll count the number of lines that start with a
    "   space and compare to the number of lines that start with a tab.
    let l:extracted_cmds = s:ExtractModelineCmdsFromBufferHeadOrTail()

    if l:extracted_cmds != ''
      let l:unsafe = 0
      if l:unsafe
        try
          execute 'setlocal ' . l:extracted_cmds
          DGCTSGEcho 'execute setlocal ' . l:extracted_cmds
          let b:dubs_style_index = s:dubs_style_file_modeline
        catch
          " E.g., "E518: Unknown option: foo=bar"
          " - Or more specifically:
          "     catch /^Vim\%((\a\+)\)\=:E518/
          " - Note from Normal mode, you'll see this message.
          "   - But from Insert mode, Vim writes save info, e.g.,
          "       dubs_style_guard.vim" 725L, 28023B written
          "     then it prints the message emitted here.
          "     - But then Vim echoes "-- INSERT --".
          "     - So user might not notice this message.
          echom 'dubs_style_guard: modeline failed: ' .. l:extracted_cmds .. ' | file: ' .. expand('%:p')
          DGCTSGEcho 'setlocal failed: ' . l:extracted_cmds
          " Clear var. so we keep sussing.
          let l:extracted_cmds = ''
        endtry
      else
        " REFER: https://github.com/ciaranm/securemodelines
        DGCTSGEcho 'dubs_style_guard: *securely* applying modeline: ' .. l:extracted_cmds
        call g:embrace#securemodelines#DoModeline('vim: ' .. l:extracted_cmds)
        let b:dubs_style_index = s:dubs_style_file_modeline
      endif
    endif

    if l:extracted_cmds == ''
      if expand('%:e') == 'help'
        " From the bottom of most help files:
        "   setlocal tw=78 ts=8 ft=help norl
        " Except *.help is a hack so we can get the same tab width...
        setlocal tw=78 ts=8 ft=text norl
        " 2011.01.27: Use setlocal, not set, so command applies just to cur buf.
        let b:dubs_style_index = s:dubs_style_file_modeline
        DGCTSGEcho 'a help file'
      else
        let [l:n_spaced, l:n_tabbed] = s:CountFileTabsAndSpaces()

        if (l:n_tabbed > 10) && (l:n_tabbed > (2 * l:n_spaced))
          " If the file is already mostly tabbed, setup tabbing.
          DGCTSGEcho 'Style guess: Tab-indented > 10 and more than 2x space starts'
          let b:dubs_style_index = g:dubs_style_fallback_indent_width_tabbed
        elseif (l:n_tabbed > 0) && (l:n_spaced == 0)
          DGCTSGEcho 'Style guess: Tab-indented > 0 and no space-starts'
          let b:dubs_style_index = g:dubs_style_fallback_indent_width_tabbed
        elseif (l:n_spaced > 0) && (l:n_tabbed == 0)
          DGCTSGEcho 'Style guess: No tab starts but space starts'
          let b:dubs_style_index = g:dubs_style_fallback_indent_width_spaced
        elseif expand('%:e') == 'rst'
          DGCTSGEcho 'Style guess: Space-indented / rst'
          let b:dubs_style_index = g:dubs_style_fallback_indent_width_spaced
          DGCTSGEcho 'dubs_style_index: ' . b:dubs_style_index
        else
          DGCTSGEcho 'Style guess: no guess (fallback: spaces)'
          let b:dubs_style_index = g:dubs_style_fallback_indent_width_spaced
        endif
      endif
    endif

    if (&filetype == 'help')
      let b:dubs_styles_count_ft = s:dubs_style_8_char_tabbed + 1
    else
      let b:dubs_styles_count_ft = s:dubs_styles_count
    endif
  endif " end: if (a:dont_cycle == 1) && (l:use_style == 1)

  call s:ApplyCurrentStyle(b:dubs_style_index, l:use_style)

  if (&expandtab == 1)
    let l:ws_style_units = 'sp/t (spaced)'
  else
    let l:ws_style_units = 'ch/t (tabbed)'
  endif

  let l:style_msg = 'Whitespace Style: ' . &tabstop . ' ' . l:ws_style_units

  if (a:dont_cycle == 0) || (a:do_echom == 1)
    echomsg l:style_msg
  endif
  DGCTSGEcho l:style_msg

  " See also: dubs_edit_juice/plugin/smart-tabs.vim, which translates tabs
  " to spaces if we're tabbing but not indenting (i.e., if we're pressing
  " the tab key because we want to quickly add spaces to help us
  " align text).
  "  Note also: The Intelligent Indent smart tabber also smartly deletes
  "             by deleting to the previous tab stop... which might be
  "             annoying, so maybe change softtabstop to something less.
  " 2014.11.18: Weird: I set softtabstop to 3 after adding
  "             dubs_edit_juice/plugin/smart-tabs.vim and now the undo
  "             stack doesn't work!
  "             Well, I disabled softtabstop, and it doesn't fail as often,
  "             but I'm still having undo problems.
  " Here's one try:
  let g:ctab_disable_checkalign = 1
  " except it has to be set before the plugin is sourced, so I edited the
  " plugin.
  " 2014.11.18: I'm either not used or just plain don't like smart delete
  "             so I disabled it (if I tab past where I'm trying to align,
  "             I'd rather my delete back up by one and not just back up
  "             to the previous tab stop, 'cause I still gotta type spaces
  "             so it's really just more keypresses total.
endfunction

" ***

function! s:ApplyCurrentStyle(dubs_style_index, use_style) abort
  if (a:use_style == 0)
    " Default for Quickfix and other special windows is 2-spaced.
    "   setlocal tabstop=2
    "   setlocal shiftwidth=2
    "   setlocal expandtab
    :
  elseif (a:dubs_style_index == s:dubs_style_2_char_spaced)
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal expandtab
  elseif (a:dubs_style_index == s:dubs_style_2_char_tabbed)
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal noexpandtab
  elseif (a:dubs_style_index == s:dubs_style_3_char_spaced)
    " Cyclopath uses trips! 321 Polo? 321 Cyclopath!
    setlocal tabstop=3
    setlocal shiftwidth=3
    setlocal expandtab
  elseif (a:dubs_style_index == s:dubs_style_3_char_tabbed)
    setlocal tabstop=3
    setlocal shiftwidth=3
    setlocal noexpandtab
  elseif (a:dubs_style_index == s:dubs_style_4_char_spaced)
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal expandtab
  elseif (a:dubs_style_index == s:dubs_style_4_char_tabbed)
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal noexpandtab
  elseif (a:dubs_style_index == s:dubs_style_8_char_tabbed)
    setlocal tabstop=8
    setlocal shiftwidth=8
    setlocal noexpandtab
  elseif (a:dubs_style_index == s:dubs_style_file_modeline)
    " Already setup.
    :
  else
    " assert(False)
    call confirm('Programmer Error: ' . a:dubs_style_index
                 \ . ' ' . expand('%'), 'OK')
  endif
endfunction

" ***

" HSTRY: This used to be two system() calls using head, tail, grep and sed.
" - TIMED: Baseline system() reltime() on author's Mac Mini 2 is ~0.06
"          seconds (e.g., for just a simple `echo`).
"   - Using pure Vimscript, on the other hand, is blazingly quick, ~0.002s.
function s:ExtractModelineCmdsFromBufferHeadOrTail() abort
  let l:extracted_cmds = s:ExtractModelineCmdsFromBuffer(1, g:dubs_style_search_depth_head)

  if l:extracted_cmds == ''
    let l:lnum = max([1, line('$') - g:dubs_style_search_depth_tail + 1])

    let l:extracted_cmds = s:ExtractModelineCmdsFromBuffer(l:lnum, '$')
  endif

  return l:extracted_cmds
endfunction

function s:ExtractModelineCmdsFromBuffer(lnum, end) abort
  if v:version < 900
    " No matchbufline

    return ''
  endif

  let l:extracted_cmds = ''

  " Note that the captured input associated with a matchbufline "submatches"
  " group is always the subsequence that the group most recently matched.
  " I.e., we cannot match a variable number of pattern groups. So match the
  " whole set command, and split during post. (Also note that the
  " "submatches" List always contains 9 items (for nine possible match
  " groups).)
  " - Note we could try to check for comment leaders, e.g.,
  "     let l:pattern = '^\W*\%(\#\+\|\.\+\|\-\+\|\/\+\|\/\*\+\)\W*vim\s\?...'
  "   but it's simpler to just check that only whitespace or punctuation
  "   precedes the 'vim:'. Which isn't 'perfect', but good enough.
  let l:pattern = '^\W*vim\s\?:\s*\%(set\s\+\)\?\(\%(\w\+\%(=\w\+\)\?\%(\s\+\|:\)\?\)\+\)\W*$'

  let l:matches = matchbufline(bufnr(), l:pattern, a:lnum, a:end, { 'submatches': v:true })

  if len(l:matches) > 0
    " echom "l:matches: " .. join(l:matches, ' / ')

    let l:first_match = l:matches[0]

    let l:first_group = l:first_match['submatches'][0]

    let l:extracted_cmds = substitute(l:first_group, ':', ' ', 'g')

    DGCTSGEcho 'Found modeline on line no.: ' . l:first_match.lnum
  endif

  return l:extracted_cmds
endfunction

" ***

" Count number of lines that start with space vs. tab for current buffer.
"
" TIMED/2025-01-19: Using reltime(), e.g.,
"     let start_time = reltime()
"     ...
"     echom "elapsed time: " .. reltimestr(reltime(start_time))
" - Running reltime() before/after `DGCTSGEcho`:           0.000073 secs.
" - Running reltime() before/after `system('echo "foo"')`: 0.064276 secs.
" - Running reltime() before/after 2 system(`grep ...`)'s: 0.130494 secs.
"   - HSTRY: This fcn. used to shell out, e.g.,
"       let l:ggrep = '$(command -v ggrep || command -v grep)'
"       let l:grep_tabbed = l:ggrep .. ' -c -P "^\t" "' .. expand('%:p') .. '"'
"       " Use an OR fallback so that system() only fails if grep is absent
"       " or not GNU grep — but don't fail if grep didn't find any results.
"       let l:safety_check = ' || echo "" | ' .. l:ggrep .. ' -c -P "^$" >/dev/null'
"       let l:cnt_tabbed = l:grep_tabbed .. l:safety_check
"     - You can see that the cost of these 2 grep commands is basically
"       the cost of two system() commands.
" - Running reltime() before/after current function below: 0.000730 secs.
"   - DUNNO: Not sure why this used to use system() commands, other than
"     perhaps "I didn't know any better back then", or maybe "I copy-
"     pasted something from Stack Overflow but didn't think too deeply
"     about it otherwise".
"     - In any case, lesson learned: ** Avoid system() calls. **

function! s:CountFileTabsAndSpaces() abort
  if v:version < 900
    " No matchbufline

    return [0, 0]
  endif

  let l:pattern_spaced = '^ '
  let l:pattern_tabbed = '^\t'

  let l:matches_spaced = matchbufline(bufnr(), l:pattern_spaced, 1, '$')
  let l:matches_tabbed = matchbufline(bufnr(), l:pattern_tabbed, 1, '$')

  let l:n_spaced = len(l:matches_spaced)
  let l:n_tabbed = len(l:matches_tabbed)

  DGCTSGEcho 'Tab styl anlyss: n_spaced: ' . l:n_spaced
                       \ . ' / n_tabbed: ' . l:n_tabbed
                       \ . ' / line cnt: ' . line('$')

  return [l:n_spaced, l:n_tabbed]
endfunction

" -------------------------------------------------------------------

" ------------------------------------------
" The Line Length Checker Cycler

" ONGNG/2024-12-21: I'm convert to autoload/ as I touch things, but I
" wouldn't expect me to tackle this whole file anytime soon.
" - Here's our first autoload/ conversion.

function! s:EnableLineLengthStyleToogle() abort
  let l:key_sequence_cycle = '<Leader>dr'
  let l:key_sequence_reset = '<Leader>dR'
  let l:default_line_style = 'highlight_violators'

  call g:embrace#col_col_cycle#Enable(
    \ l:key_sequence_cycle,
    \ l:key_sequence_reset,
    \ l:default_line_style,
    \ )
endfunction

call s:EnableLineLengthStyleToogle()

" -------------------------------------------------------------------

" ------------------------------------------
" EditorConfig config

" REFER: To ensure that this plugin works well with Tim Pope's fugitive,
"        use the following patterns array:
" https://github.com/editorconfig/editorconfig-vim?tab=readme-ov-file#excluded-patterns
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

