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

augroup dubs_style_guard_style_guides
  au!
  
  autocmd BufRead,BufWritePost * call s:CycleThruStyleGuides_ApplyStyle()
augroup END

function! s:CycleThruStyleGuides_ApplyStyle() abort
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

  let l:use_style = 1
  " NO: \ || (&tw == 0)
  if (!exists('b:dubs_style_index')
      \ || !g:embrace#windows2#IsNormalBuffer(bufnr())
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
  " Note: If you use dubs_edit_juice/plugin/smart-tabs.vim and set
  "       softtabstop, you'll bork the undo stack.
  " Bad?: setlocal softtabstop=3
  " Below, we'll set tabstop and shiftwidth.
  " Ignoring: copyindent, preserveindent.

  if (a:dont_cycle == 1) && (l:use_style == 1)

    " If user is not deliberately toggling the tab style, intelligently set
    " it based on project style, file extension, and existing convention.
    "
    " Count the number of tabbed indents and spaced indents.
    " (Keywords: Count line matches to variable,
    "            Set variable to number of lines matching search.)
    "

" FIXME: COMMENT ON ANSWER: give a vote to the guy who provided better answer.
    " For help on this Vim trickery, see
    "   https://stackoverflow.com/questions/8073780/
    "     using-vim-how-do-you-use-a-variable-to-store-count-of-patterns-found
    "   and also
    "     :help sub-replace-\=
    " EXPLAIN: How does the bar/pipe operator work?
    "          When I type :echo 1 | 2 it spits out 1 and sends the cursor
    "          to the top of the file. In command mode, | sends the cursor
    "          to the start of the line.
    " EXPLAIN: How come sending the new variable to map() works when
    "          we haven't initialized the variable yet?
    " SEE ALSO: :help /\zs and :help /\ze
    "           These ensure that no substitution happens because
    "           they make sure the pattern has zero width.
    ""let n = [0] | bufdo %s/pattern\zs/\=map(n,'v:val+1')[1:]/ge
    "let count_list = [0] | %s/^ \zs/\=map(count_list,'v:val+1')[1:]/ge
    "let match_count = count_list[0]
    "":DGCTSGEcho 'Substitution trick indicates: ' . match_count
    "
    " Another user answered with an easier-to-understand solution, and one
    " that works better. The problem with the former solution is that the
    " substitution trick has three side effects: It echoes the result of the
    " substitution command, it moves the cursor to the end of the buffer, and
    " most annoyingly, it adds a command to the undo stack and then the buffer
    " is marked dirty.
    " NOTE: expand('%:p') returns full path of current buffer. :help expand
    " NOTE: Prefix :let with bufdo to count all buffers' matches.
    "       I.e., bufdo let found = found + (system(...))
    " NOTE: Using Perl-Compatible RegEx because egrep doesn't know "^\t".
    "       Note that we could also use grep -P.
    let l:n_spaced = (system('pcregrep "^ " "' . expand('%:p') . '" | wc -l'))
    let l:n_tabbed = (system('pcregrep "^\t" "' . expand('%:p') . '" | wc -l'))
    let l:n_spaced = substitute(l:n_spaced, "\n", "", "")
    let l:n_tabbed = substitute(l:n_tabbed, "\n", "", "")
    DGCTSGEcho 'Tab styl anlyss: n_spaced: ' . l:n_spaced
                         \ . ' / n_tabbed: ' . l:n_tabbed
    " See also: tpope's Sleuth: https://github.com/tpope/vim-sleuth
    "      and: http://www.vim.org/scripts/script.php?script_id=1171
    "           DetectIndent: Automatically detect indent
    "                         (expandtab, shiftwidth, tabstop) settings
    " Sleuth is pure Vim and more complete (it doesn't consider spacing
    " style of comments, for example). DetectIndent is also pure Vim.
    " But this is a pretty good solution

    " We can also look for modeline strings.
    " Test: tail doc-------dubs_cycloplan.txt \
    "       | /bin/egrep '^\W*vim:([\=\:a-z0-9]+)\W*$' \
    "       | /usr/bin/env sed 's/([\=\:a-z0-9]+)\W*$/\1/' \
    "       | /usr/bin/env sed 's/:/ /g'
    "
    " We'll look for a modeline in the file itself.
    let l:modeline_grep_prefix = 'egrep --max-count=1 "^\W*'
    " SYNC_ME: l:modeline_grep_postfix and l:modeline_seds_postfix.
    " SAVVY: \W: non-word characters: [^a-zA-Z0-9_]
    let l:modeline_grep_postfix = ':([\=\:a-z0-9 ]+)\W*$" '
    " NOTE: grep syntax is just '?' but in sed you'll see '\?'.
    let l:modeline_grep =
      \ l:modeline_grep_prefix . 'vim\s?' . l:modeline_grep_postfix
    let l:modeline_seds_prefix =
      \ '| /usr/bin/env sed "s/^\W*'
    " SYNC_ME: l:modeline_grep_postfix and l:modeline_seds_postfix.
    let l:modeline_seds_postfix =
      \ ':\([\=\:a-z0-9 ]\+\)\W*$/\1/"'
      \ . ' | /usr/bin/env sed "s/:/ /g"'
      \ . ' | /usr/bin/env sed "s/\bset\b/ /g"'
    let l:modeline_seds =
      \ l:modeline_seds_prefix . 'vim\s\?' . l:modeline_seds_postfix
    let l:modeline_search = l:modeline_grep . l:modeline_seds
    let l:modeline_embedded = ''
    if filereadable(expand('%:p'))
      let l:escaped_path = <SID>ShellEscapedFullPath()
      " 2015.04.10: If you open a file with a space in it's path, you'll see, e.g.,
      "      "./Electronica-House/Daft Punk/.audfs" 2L, 64C^[[2;2R
      "      Error detected while processing function
      "         <SNR>40_CycleThruStyleGuides_FixMatch
      "           ..<SNR>40_CycleThruStyleGuides
      "             ..<SNR>40_DG_CycleThruStyleGuides_:
      "      line  217:
      "      E518: Unknown option: /usr/bin/head:
      "      E486: Pattern not found: usr
      "      E518: Unknown option: /usr/bin/head:
      "      E486: Pattern not found: usr
      "      Press ENTER or type command to continue
      "
      " Modeline is expected to be in first or final lines of file.
      " - NOTED/2020-08-26: macOS head uses -n, not --lines.
      let l:bash_cmd11 =
        \ 'command head -n ' . g:dubs_style_search_depth_head . ' ' . l:escaped_path
        \ . ' | ' . l:modeline_search
      " Note: [lb] sent the head a bad filename but v:shell_error
      "       indicates 0, which could be because the pipe to grep
      "       succeeded and that's what the v:shell_error represents.
      "       Anyway, I added a filereadable above, which should fix
      "       most errors we'd have here. FYI: If the system() command
      "       fails, it might return the error string, and if we set
      "       try "execute 'set ' . l:modeline_embedded" we'll get
      "       an obscure error like: "E518: Unknown option: head:",
      "       i.e., Vim's response to "set head: cannot read file",
      "       i.e., we sent the error string to the 'set' command.
      "       MAYBE: Check the syntax of l:modeline_embedded, maybe
      "              using matchstr.
      DGCTSGEcho 'Modeline search: 1st l:bash_cmd11: ' . l:bash_cmd11
      let l:modeline_embedded = system(l:bash_cmd11)
      if l:modeline_embedded == ''
        " - NOTE/2020-08-26 14:55: macOS head has -n, but not --lines.
        let l:bash_cmd12 =
          \ 'command tail -n ' . g:dubs_style_search_depth_tail . ' ' . l:escaped_path
          \ . ' | ' . l:modeline_search
        DGCTSGEcho 'Modeline search: 2nd l:bash_cmd12: ' . l:bash_cmd12
        let l:modeline_embedded = system(l:bash_cmd12)
      endif
      if l:modeline_embedded != ''
        DGCTSGEcho 'Found embedded modeline: ' . l:modeline_embedded
      endif
    else
        DGCTSGEcho 'File is not readable: ' . expand('%:p')
    endif

    let l:found_modeline = ''
    if l:modeline_embedded != ''
      let l:found_modeline = l:modeline_embedded
    endif

    if l:found_modeline != ''
      " Either the file or a .dubs_style.vim file contains a modeline.
      DGCTSGEcho 'execute setlocal ' . l:found_modeline
      execute 'setlocal ' . l:found_modeline
      let b:dubs_style_index = s:dubs_style_file_modeline
    elseif expand('%:e') == 'help'
      " From the bottom of most help files:
      "setlocal tw=78 ts=8 ft=help norl
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
        " Vim help files are 8 spaces per tab, but most other times
        " it's 4 spaces per tab. At least that's [lb]'s experience.
        let b:dubs_style_index = s:dubs_style_4_char_tabbed
      elseif (l:n_tabbed > 0) && (l:n_spaced == 0)
        DGCTSGEcho 'Style guess: Tab-indented > 0 and no space-starts'
        let b:dubs_style_index = s:dubs_style_4_char_tabbed
      elseif (l:n_spaced > 0) && (l:n_tabbed == 0)
        DGCTSGEcho 'Style guess: No tab starts but space starts'
        " 2016-11-18: 2, 4, next I'll just try 3 again.
        "let b:dubs_style_index = s:dubs_style_2_char_spaced
        "let b:dubs_style_index = s:dubs_style_4_char_spaced
        " 2018-01-19: Heh. Back to 2.
        let b:dubs_style_index = s:dubs_style_2_char_spaced
      elseif expand('%:e') == 'rst'
        " Because of the ".. directive" convention in reST, which means blocks
        " often align after the third column, make rstdentation 3-spaced. Or 4.
        " I keep changing my mind.
        DGCTSGEcho 'Style guess: Space-indented / rst'
        "let b:dubs_style_index = s:dubs_style_3_char_spaced
        let b:dubs_style_index = s:dubs_style_2_char_spaced
        DGCTSGEcho 'dubs_style_index: ' . b:dubs_style_index
      else
        " Just use spaces.
        DGCTSGEcho 'Style guess: no guess'
        " 2016-10-28: From 2-spaces spaced to 4-spaces tabbed,
        "             to where has the world come?
        "let b:dubs_style_index = s:dubs_style_2_char_spaced
        "let b:dubs_style_index = s:dubs_style_4_char_tabbed
        " 2016-11-18: Ug. I keep flip flopping. Here's the latest reasoning:
        " PEP 8 says use 4 spaces for indentation
        "   https://www.python.org/dev/peps/pep-0008/
        " and Bash scripts should also use spaces
        "   so copy-paste to terminal works
        "   (without triggering tab completion).
        "let b:dubs_style_index = s:dubs_style_4_char_spaced
        " 2018-01-29: Another 1, Back to 2.
        "   (Was I using 4 because of reST? Even then,
        "    you can make 4 from 2 but not 2 from 4,
        "    so 2 is more flexy.)
        let b:dubs_style_index = s:dubs_style_2_char_spaced
      endif
    endif

    if (&filetype == 'help')
      let b:dubs_styles_count_ft = s:dubs_style_8_char_tabbed + 1
    else
      let b:dubs_styles_count_ft = s:dubs_styles_count
    endif
  endif " end: if (a:dont_cycle == 1) && (l:use_style == 1)

  if (l:use_style == 0)
    " Default for Quickfix and other special windows is 2-spaced.
    "setlocal tabstop=2
    "setlocal shiftwidth=2
    "setlocal expandtab
    :
  elseif (b:dubs_style_index == s:dubs_style_2_char_spaced)
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal expandtab
  elseif (b:dubs_style_index == s:dubs_style_2_char_tabbed)
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal noexpandtab
  elseif (b:dubs_style_index == s:dubs_style_3_char_spaced)
    " Cyclopath uses trips! 321 Polo? 321 Cyclopath!
    setlocal tabstop=3
    setlocal shiftwidth=3
    setlocal expandtab
  elseif (b:dubs_style_index == s:dubs_style_3_char_tabbed)
    setlocal tabstop=3
    setlocal shiftwidth=3
    setlocal noexpandtab
  elseif (b:dubs_style_index == s:dubs_style_4_char_spaced)
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal expandtab
  elseif (b:dubs_style_index == s:dubs_style_4_char_tabbed)
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal noexpandtab
  elseif (b:dubs_style_index == s:dubs_style_8_char_tabbed)
    setlocal tabstop=8
    setlocal shiftwidth=8
    setlocal noexpandtab
  elseif (b:dubs_style_index == s:dubs_style_file_modeline)
    " Already setup.
    :
  else
    " assert(False)
    call confirm('Programmer Error: ' . b:dubs_style_index
                 \ . ' ' . expand('%'), 'OK')
  endif

  if (&expandtab == 1)
    let l:ws_style_units = 'sp/t (spaced)'
  else
    let l:ws_style_units = 'ch/t (tabbed)'
  endif
  if (a:dont_cycle == 0) || (a:do_echom == 1)
    echomsg 'Whitespace Style: ' . &tabstop . ' ' . l:ws_style_units
  endif
  DGCTSGEcho 'Whitespace Style: ' . &tabstop . ' ' . l:ws_style_units

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

" -------------------------------------------------------------------

" ------------------------------------------
" The Line Length Checker Cycler

" ONGNG/2024-12-21: I'm convert to autoload/ as I touch things, but I
" wouldn't expect me to tackle this whole file anytime soon.
" - Here's our first autoload/ conversion.

function! s:EnableLineLengthStyleToogle() abort
  let l:key_sequence_cycle = '<Leader>dr'
  let l:key_sequence_reset = '<Leader>dR'
  let l:default_line_style = 'colorcolumn_only'

  call g:embrace#col_col_cycle#Enable(
    \ l:key_sequence_cycle,
    \ l:key_sequence_reset,
    \ l:default_line_style,
    \ )
endfunction

call s:EnableLineLengthStyleToogle()

" -------------------------------------------------------------------

" ------------------------------------------
" EditorConfig enablement

" From editoconfig:README.rst:
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" 2020-03-29: Since when did this become necessary?
" - I think the EditorConfig rewrite of its vim-core parser
"   on 2019-05-20, but hard to tell, that was a very disruptive
"   commit.
"   - What's V. Strange is that this is not documented in the README,
"     though other topics are. But this seems key to the whole thing!
EditorConfigEnable

