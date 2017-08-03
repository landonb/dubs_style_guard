" File: dubs_style_guard.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Last Modified: 2017.08.02
" Project Page: https://github.com/landonb/dubs_style_guard
" Summary: Auto-sense Whitespace Style (spaces v. tabs)
" License: GPLv3
" -------------------------------------------------------------------
" Copyright © 2009, 2015-2017 Landon Bouma.
"
" This file is part of Dubsacks.
"
" Dubsacks is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
"
" Dubsacks is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with Dubsacks. If not, see <http://www.gnu.org/licenses/>
" or write Free Software Foundation, Inc., 51 Franklin Street,
"                     Fifth Floor, Boston, MA 02110-1301, USA.
" ===================================================================

" ------------------------------------------
" About:

" This script scans a file when the buffer is loaded and tries to
" guess the whitespace style of the document.
"
" For new documents, you can add a .dubs_style file somewhere in
" the path and specify the style therein. Use Vim modeline syntax,
" and filter by file type, if necessary.
"
" Or, you can manually switch between whitespace styles using <Leader>e.
" Caveat: The author prefers 2-character spaced indentation, but I also
"         work with 4-character tabbed indentation, so those are the two
"         recognized styles. You can easily modify the code below to use
"         different styles or to add more styles to the list.
"
" You can also enable and disable visual wrapping, automatic long-line
" breaking, and long-line highlighting using <Leader>w.

if exists("g:plugin_dubs_style_guard") || &cp
  finish
endif
let g:plugin_dubs_style_guard = 1

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Smart Style Guide Functionality
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Oftentimes, Vim settings are set to suit a particular developer's
" tastes, but sometimes the settings are set to match the style of a
" specific project.
"
" So while you might want to laugh derisively at anyone who doesn't
" vim:et:ts=2:sw=2, you should play well with others and conform when
" needed.

" Here we define a set or pre-canned styles.
let s:dubs_style_file_modeline = -1
let s:dubs_style_2_char_spaced = 0
let s:dubs_style_4_char_tabbed = 1
let s:dubs_style_4_char_spaced = 2
" These are not cycleable with \e (unless you bump dubs_styles_count [and reorder]):
let s:dubs_style_8_char_tabbed = 3
let s:dubs_style_2_char_tabbed = 4
let s:dubs_style_3_char_spaced = 5
let s:dubs_style_3_char_tabbed = 6
" We don't actually cycle through all of the styles above.
" We only cycle over a few of them, depending on our taste.
" Feel free to change this count to cycle over more styles.
" Too many: let s:dubs_styles_count = s:dubs_style_3_char_tabbed + 1
"let s:dubs_styles_count = s:dubs_style_4_char_tabbed + 1
let s:dubs_styles_count = s:dubs_style_4_char_spaced + 1

" User interface.
if !exists('g:dubs_style_preferred_expand_tab')
  let g:dubs_style_preferred_expand_tab = 0
endif
if !exists('g:dubs_style_preferred_indent')
  let g:dubs_style_preferred_indent = 2
endif

" ------------------------------------------------------
" Nuts to ~/.vim/ftplugin/ and setup global autocmd
" ------------------------------------------------------

" This style is applied by default for new files and other files without
" an apparent indent scheme already in place or whose file extension is
" not recognized, such that CycleThruStyleGuides doesn't enforce the style.

"autocmd BufEnter * call CycleThruStyleGuides_SetMatch(
autocmd BufEnter,BufRead * call CycleThruStyleGuides_SetMatch(
                            \ s:dubs_style_2_char_spaced)

" [lb] tried just BufEnter but it doesn't quite work -- e.g.,
" when toggling the Quickfix window, if we only catch BufEnter,
" when checking the buffer to see what it is, not all of its
" settings are set (so we don't know it's the Quickfix window
" on BufEnter, but on BufRead -- when it's settings are set --
" then we can deduce that the buffer is the Quickfix buffer).
"autocmd BufEnter * call s:CycleThruStyleGuides_FixMatch()
autocmd BufEnter,BufRead * call s:CycleThruStyleGuides_FixMatch()

" ------------------------------------------------------
" Map <Leader>e to Toggling Style Guide [E]nforcement
" ------------------------------------------------------

" The user can cycle through the set of pre-defined style guide templates.
if !hasmapto('<Plug>DubsStyleGuard_CycleThruStyleGuides')
  map <silent> <unique> <Leader>e
    \ <Plug>DubsStyleGuard_CycleThruStyleGuides
endif
" Map <Plug> to an <SID> function
noremap <silent> <unique> <script>
  \ <Plug>DubsStyleGuard_CycleThruStyleGuides
  \ :call <SID>CycleThruStyleGuides(0, 1, 0)<CR>
" And finally thunk to the script fcn.
""function <SID>CycleThruStyleGuides()
""  call s:CycleThruStyleGuides()
""endfunction

" 2012.10.03: I don't use the built-in Ctrl-e often -- in
" command and select mode, it moves the buffer one line up
" in the window; it doesn't do anything in insert mode. But
" it seems too built-in to remap (see :h Ctrl-e and you'll
" see it's only mapped to one key-combo).
"  NO: noremap <C-e> :call <SID>CycleThruStyleGuides()<CR><CR>
"  NO: inoremap <C-e> <C-O>:call <SID>CycleThruStyleGuides()<CR><CR>
" 2014.11.18: I started using <Leader>e more often to switch styles
" as I started working on different projects. But I also added more
" intelligence to auto-detect the current project's style whenever
" switching buffers. So I still don't manually switch styles very
" often, but it's still at least proving itself to be handy when
" needed.

" ------------------------------------------------------

" Initialize the variable used to track which template is active.
function CycleThruStyleGuides_SetMatch(style_index)

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

  if !exists('b:dubs_line_len_style')
    let b:dubs_line_len_style = 0
  endif

endfunction

" ------------------------------------------------------

" When a buffer is initially read, we'll try to guess its style.
function s:CycleThruStyleGuides_FixMatch()
  if exists('b:dubs_style_index')
    call <SID>CycleThruStyleGuides(1, 0, 0)
  endif
  if exists('b:dubs_line_len_style')
    call <SID>DG_CycleThruLineLengthGuides(1)
  endif
endfunction

" ------------------------------------------------------

" <Leader>E simply resets the style (possibly be reparsing the file).
if !hasmapto('<Plug>DG_CycleResetLocking')
  map <silent> <unique> <Leader>E
    \ <Plug>DG_CycleResetLocking
endif
noremap <silent> <unique> <script>
  \ <Plug>DG_CycleResetLocking
  \ :call <SID>DG_CycleResetLocking()<CR>
function s:DG_CycleResetLocking()
  let b:dubs_style_locked = 0
  call <SID>CycleThruStyleGuides(1, 1, 1)
endfunction

" ------------------------------------------------------
" Choose or Sense a Specific Indent Style or Manually Cycle Through
" ------------------------------------------------------

" ------------------------------------------
" "Echo" to variable

" https://stackoverflow.com/questions/8629452/is-it-possible-to-clear-message-history-in-gvim
"command! -nargs=1 -bar Echo :let g:messages=get(g:, 'messages', [])+[<q-args>]
" This gives errors when Echo is run:
"command! -nargs=1 -bar Echo :let g:messages=get(g:, 'messages', [])+[eval(<args>)] | echom <args>
" But using q-args works.
" FIXME: Correct stack overflow answer.
"command! -nargs=1 -bar Echo :let g:messages=get(g:, 'messages', [])+[eval(<q-args>)] | echom <args>
" Strange: Command name cannot be understored, e.g., DG_CTSG_Echo is no good.
" But without the echom:
command! -nargs=1 -bar DGCTSGEcho :let g:style_log=get(g:, 'style_log', [])+[eval(<q-args>)]
" ===============
" To see the log:
" ===============
"   echo g:style_log
"   TabMessage echo g:style_log
" ===============
" To clear the log:
" ===============
"   unlet g:style_log
" ===============
" NOTE: You have to use single quotes with Echo, e.g.,
"       __command__         __response__
"       Echo Whatever       E121: Undefined variable: Whatever
"       Echo "Whatever"     E471: Argument required
"       Echo 'Whatever'     Whatever

" ------------------------------------------
" The Style Guide Cycler

function s:CycleThruStyleGuides(dont_cycle, do_echom, force_reset)

  if exists('g:style_log')
    unlet g:style_log
  endif
  if (a:force_reset == 0)
    DGCTSGEcho 'Setting style: ' . expand('%:p')
  else
    DGCTSGEcho 'Resetting style: ' . expand('%:p')
  endif

  let l:change_style = 1

  if (a:dont_cycle == 1)
     \ && (b:dubs_style_locked == 1)
     \ && (a:force_reset == 0)
    DGCTSGEcho 'Style locked!'
    let l:change_style = 0
  endif

  if l:change_style == 1
    call <SID>CycleThruStyleGuides_(a:dont_cycle, a:do_echom, a:force_reset)
  endif

endfunction

function s:CycleThruStyleGuides_(dont_cycle, do_echom, force_reset)

  DGCTSGEcho 'Setting style_: ' . expand('%:p')

  " FIXME: Check that the editorconfig plugin is installed, otherwise skip this.
  " Prefer an .editorconfig file over a .dubs_style.vim file or guessing.
  let s:editconf_f = findfile('.editorconfig', '.;')

  let l:use_style = 1
  " NO: \ || (&tw == 0)
  if (!exists('b:dubs_style_index')
      \ || (&buflisted == 0)
      \ || (&buftype == 'quickfix')
      \ || (&modifiable == 0)
      \ || (bufname('%') == '-MiniBufExplorer-')
      \ || (s:editconf_f != ''))
    DGCTSGEcho 'Style guide: not use_style'
    let l:use_style = 0
  endif

  if (l:use_style == 1) && (a:dont_cycle == 0)
    if (&filetype == 'help')
      " When deliberately setting style, if a help file, make text, 8-tabbed.
      set filetype=text
      let b:dubs_style_index = s:dubs_style_8_char_tabbed
    else
      let b:dubs_style_index = b:dubs_style_index + 1
      if (b:dubs_style_index >= s:dubs_styles_count)
        let b:dubs_style_index = 0
      endif
    endif
    " A "locked" style simply means the user is deliberately
    " cycling through the styles, so we shouldn't reset the
    " style for the buffer automatically. This should only
    " matter if the autocmd specifies BufEnter, which it doesn't
    " anymore.
    let b:dubs_style_locked = 1
  endif

  " We always don't use "soft tabs".
  setlocal softtabstop=0
  " Note: If you use ctab.vim and set softtabstop, you'll bork the undo stack.
  " Bad?: setlocal softtabstop=3
  " Below, we'll set tabstop and shiftwidth.
  " Ignoring: copyindent, preserveindent.

  " 2014.11.18: [lb] happened to load the "Highlight long lines" page
  " on Wikia <http://vim.wikia.com/wiki/Highlight_long_lines> and
  " thankfully I found out Vim 7.3 includes a newer, better way to
  " highlight line length!
  " See below: :set colorcolumn=+1,+2,+3
  " The default color is a lightish pink.
  :hi ColorColumn ctermbg=lightgrey guibg=lightgrey
  " ErrorMsg defaults to
  "  xxx term=standout ctermfg=15 ctermbg=4 guifg=White guibg=Red
  " For color reference see :h cterm-colors
  " Here's the list of light colors:
  "  LightRed LightGreen LightCyan LightMagenta LightYellow LightGray
  " [lb] tried Red and LightRed but red is too loud and obnoxious.
  " So then I just tried LightBlue and it seems to fit in nicely.
  :hi MyErrorMsg term=standout ctermfg=15 ctermbg=4 guibg=LightBlue

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
    let l:n_spaced = (system('pcregrep "^ " ' . expand('%:p') . '| wc -l'))
    let l:n_tabbed = (system('pcregrep "^\t" ' . expand('%:p') . '| wc -l'))
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
    "       | /bin/sed 's/([\=\:a-z0-9]+)\W*$/\1/' \
    "       | /bin/sed 's/:/ /g'
    "
    " We'll look for a modeline in the file itself.
    let l:modeline_grep_prefix = 'egrep --max-count=1 "^\W*'
    " SYNC_ME: l:modeline_grep_postfix and l:modeline_seds_postfix.
    let l:modeline_grep_postfix = ':([\=\:a-z0-9 ]+)\W*$" '
    " NOTE: grep syntax is just '?' but in sed you'll see '\?'.
    let l:modeline_grep =
      \ l:modeline_grep_prefix . 'vim\s?' . l:modeline_grep_postfix
    let l:modeline_seds_prefix =
      \ '| /bin/sed "s/^\W*'
    " SYNC_ME: l:modeline_grep_postfix and l:modeline_seds_postfix.
    let l:modeline_seds_postfix =
      \ ':\([\=\:a-z0-9 ]\+\)\W*$/\1/"'
      \ . ' | /bin/sed "s/:/ /g"'
      \ . ' | /bin/sed "s/\bset\b/ /g"'
    let l:modeline_seds =
      \ l:modeline_seds_prefix . 'vim\s\?' . l:modeline_seds_postfix
    let l:modeline_search = l:modeline_grep . l:modeline_seds
    let l:modeline_embedded = ''
    if filereadable(expand('%:p'))
      " 2015.04.10: If you open a file with a space in it's path, you'll see, e.g.,
      "      "./Electronica-House/Daft Punk/.audfs" 2L, 64C^[[2;2R
      "      Error detected while processing function       "      <SNR>40_CycleThruStyleGuides_FixMatch..<SNR>40_CycleThruStyleGuides..<SNR>40_DG_CycleThru
      "      StyleGuides_:
      "      line  217:
      "      E518: Unknown option: /usr/bin/head:
      "      E486: Pattern not found: usr
      "      E518: Unknown option: /usr/bin/head:
      "      E486: Pattern not found: usr
      "      Press ENTER or type command to continue
      "
      let l:bash_cmd1 = '/usr/bin/head --lines=13 "' . expand('%:p') . '"'
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
      DGCTSGEcho 'Modeline search: 1st l:bash_cmd1: ' . l:bash_cmd1
      let l:modeline_embedded = system(l:bash_cmd1)
      if l:modeline_embedded == ''
        let l:bash_cmd1 = '/usr/bin/tail --lines=5 "' . expand('%:p') . '"'
                          \ . ' | ' . l:modeline_search
        DGCTSGEcho 'Modeline search: 2nd l:bash_cmd1: ' . l:bash_cmd1
        let l:modeline_embedded = system(l:bash_cmd1)
      endif
      if l:modeline_embedded != ''
        DGCTSGEcho 'Found embedded modeline: ' . l:modeline_embedded
      endif
    else
        DGCTSGEcho 'File is not readable: ' . expand('%:p')
    endif

    " Look for a dubs modeline file.
    " '.;' searches from the directory of the current
    "      file upwards until it finds the file.
    let s:modeline_f = findfile('.dubs_style.vim', '.;')
    let l:bash_cmd2 = ''
    let l:modeline_project = ''
    if (s:modeline_f != '')
      if (expand('%:e') != '')
        " expand('%:e') is the current file's extension, e.g., 'cpp'.
        let l:modeproj_grep =
          \ l:modeline_grep_prefix . expand('%:e') . l:modeline_grep_postfix
        let l:modeproj_seds =
          \ l:modeline_seds_prefix . expand('%:e') . l:modeline_seds_postfix
        let l:bash_cmd2 = l:modeproj_grep . s:modeline_f . l:modeproj_seds
        DGCTSGEcho '1st l:bash_cmd2: ' . l:bash_cmd2
        let l:modeline_project = system(l:bash_cmd2)
      endif
      if l:modeline_project != ''
        DGCTSGEcho 'Found exact modeline project file match: '
          \ . l:modeline_project
      else
        let l:modeproj_grep =
          \ l:modeline_grep_prefix . '\*' . l:modeline_grep_postfix
        let l:modeproj_seds =
          \ l:modeline_seds_prefix . '\*' . l:modeline_seds_postfix
        let l:bash_cmd2 = l:modeproj_grep . s:modeline_f . l:modeproj_seds
        DGCTSGEcho '2nd l:bash_cmd2: ' . l:bash_cmd2
        let l:modeline_project = system(l:bash_cmd2)
        if l:modeline_project != ''
          DGCTSGEcho 'Found default modeline project file match: '
            \ . l:modeline_project
        endif
      endif
    endif

    let l:found_modeline = ''
    if l:modeline_embedded != ''
      let l:found_modeline = l:modeline_embedded
    elseif l:modeline_project != ''
      let l:found_modeline = l:modeline_project
    endif

    if l:found_modeline != ''
      " Either the file or a .dubs_style.vim file contains a modeline.
      DGCTSGEcho 'execute set ' . l:found_modeline
      execute 'set ' . l:found_modeline
      let b:dubs_style_index = s:dubs_style_file_modeline
    elseif expand('%:e') == 'help'
      " From the bottom of most help files:
      "setlocal tw=78 ts=8 ft=help norl
      " Except *.help is a hack so we can get the same tab width...
      setlocal tw=78 ts=8 ft=text norl
      " 2011.01.27: Use setlocal, not set, so command applies just to cur buf.
      let b:dubs_style_index = s:dubs_style_file_modeline
      DGCTSGEcho 'a help file'
    elseif (l:n_tabbed > 10) && (l:n_tabbed > (2 * l:n_spaced))
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
      let b:dubs_style_index = s:dubs_style_4_char_spaced
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
      let b:dubs_style_index = s:dubs_style_4_char_spaced
    endif
  endif " (a:dont_cycle == 1)

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

  " See also: plugin/ctab.vim, which translates tabs to spaces
  " if we're tabbing but not indenting (i.e., if we're pressing
  " the tab key because we want to quickly add spaces to help us
  " align text).
  "  Note also: The Intelligent Indent smart tabber also smartly deletes
  "             by deleting to the previous tab stop... which might be
  "             annoying, so maybe change softtabstop to something less.
  " 2014.11.18: Weird: I set softtabstop to 3 after adding plugin/ctab.vim
  "             and now the undo stack doesn't work!
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

" ------------------------------------------
" The Line Length Checker Cycler

let s:dubs_llen_colorcolumn_only = 0
let s:dubs_llen_autowrap_and_highlight = 1
let s:dubs_llen_with_highlight = 2
let s:dubs_llen_all_off = 3
let s:dubs_llen_count = s:dubs_llen_all_off + 1

if !hasmapto('<Plug>DG_CycleThruLineLengthGuides')
  map <silent> <unique> <Leader>r
    \ <Plug>DG_CycleThruLineLengthGuides
endif
" Map <Plug> to an <SID> function
noremap <silent> <unique> <script>
  \ <Plug>DG_CycleThruLineLengthGuides
  \ :call <SID>DG_CycleThruLineLengthGuides(0)<CR>

" <Leader>E simply resets the style (possibly be reparsing the file).
if !hasmapto('<Plug>DG_CycleThruLineLengthReset')
  map <silent> <unique> <Leader>R
    \ <Plug>DG_CycleThruLineLengthReset
endif
noremap <silent> <unique> <script>
  \ <Plug>DG_CycleThruLineLengthReset
  \ :call <SID>DG_CycleThruLineLengthReset()<CR>
function s:DG_CycleThruLineLengthReset()
  let b:dubs_line_len_style = -1
  call <SID>DG_CycleThruLineLengthGuides(0)
endfunction

function s:DG_CycleThruLineLengthGuides(on_bufenter)
  if (exists('b:dubs_style_index')
      \ && (&buflisted == 1)
      \ && (&buftype != 'quickfix')
      \ && (&modifiable == 1)
      \ && (bufname('%') != '-MiniBufExplorer-'))
    call <SID>DG_CycleThruLineLengthGuides_(a:on_bufenter)
  else
    setlocal colorcolumn=
    match none
    setlocal textwidth=0
  endif
endfunction

function s:DG_CycleThruLineLengthGuides_(on_bufenter)

  if (a:on_bufenter == 0)
    let b:dubs_line_len_style = b:dubs_line_len_style + 1
    if (b:dubs_line_len_style >= s:dubs_llen_count)
      let b:dubs_line_len_style = 0
    endif
  endif

  if (b:dubs_line_len_style != s:dubs_llen_all_off)
    " Highlight the three columns after 'textwidth'.
    "setlocal colorcolumn=+1,+2,+3
    " On secondbetter thought, highlight the three columns *before* textwidth.
    "setlocal colorcolumn=-2,-1,-0
    " Except we don't always use textwidth, so be specific.
    " Lightly highlight a few columns after the 80-char width
    " to encourage frequent and effusive and copious wrapping.
    "setlocal colorcolumn=80,81,82
    setlocal colorcolumn=77,78,79
  else
    setlocal colorcolumn=
  endif

  let l:match_description = 'undef'
  if ((b:dubs_line_len_style == s:dubs_llen_autowrap_and_highlight)
      \ || (b:dubs_line_len_style == s:dubs_llen_with_highlight))
    " Highlight long lines.
    " Too red: match ErrorMsg '\%>79v.\+'
    match MyErrorMsg '\%>79v.\+'
    let l:match_description = '>79'
  else
  " Disable long-line highlights.
    match none
    let l:match_description = 'none'
  endif

  if (b:dubs_line_len_style == s:dubs_llen_autowrap_and_highlight)
    " Enforce a 79 character line max -- if the user is typing, forcefully
    " wrap the line at 80 chars, but if the user copies and pastes, or if
    " the user appends to an existing long line, then don't care.
    setlocal textwidth=79
  else
    " Don't interfere with the programmer and split long lines as they're
    " being typed.
    setlocal textwidth=0
  endif

  if a:on_bufenter == 0
    echomsg 'Long-line enforcement: '
            \ . printf('match=%-6s', l:match_description)
            \ . printf('tw=%-2s', &textwidth)
            \ . printf('cc=%-9s', &colorcolumn)
  endif

endfunction

