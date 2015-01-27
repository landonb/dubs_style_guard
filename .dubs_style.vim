" This is an example .dubs_style.vim file.
" The dubs_style_guard.vim plugin will look
" for this file in a file's path. Files whose
" file extension matches herein will have that
" modeline sourced; files whose file extension
" does not match will be setup according to the
" default "*:" modeline.
" CAVEAT: The plugin does not verify the syntax
"         of your modeline. It just removes the
"         file_extension: prefix, changes colons
"         to spaces, and then calls
"         "source 'set '.modeline". If there's
"         a problem with the modeline, Vim will
"         indicate an error when opening files
"         in this project.
*:tw=0:ts=2:sw=2:et:norl:
txt:tw=0:ts=8:sw=8:noet:norl:

