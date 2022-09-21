##############################
Dubs Vim |em_dash| Style Guard
##############################

.. |em_dash| unicode:: 0x2014 .. em dash

About This Plugin
=================

This plugin senses a file's whitespace style and sets up Vim accordingly.

- The check is very basic: the script uses grep to count the
  number of lines that start with spaces versus those that start with
  tabs. The script does not attempt to discern how many spaces per tab
  are used when space-indenting, nor how many spaces-per-tab are assumed
  when tab-indenting.

This plugin also adds a command makes it easy to switch between common
whitespace styles: type ``\e`` to cycle through a number of preset styles.

- There are three styles it'll cycle between:

  - *Tab and auto-indent using 2 spaces per tab*;

  - *Tab and auto-indent using a 4-character-wide tab*; and

  - *Tab and auto-indent using a 2-character-wide tab*.

- Note that the author long ago settled on using 2 spaces per tab,
  i.e., ``expandtab``, ``shitfwidth=2``, and ``tabstop=2``.

You can also cycle between common long-line styles, which will either
automatically wrap long lines as you type, and/or show a different color
in columns on the right, so you can manually wrap as you see fit.
Simply type ``\r`` to cycle through a number of preset styles.

- There are three long-ling styles it'll cycle between:

  - ``textwidth=0 colorcolumn=``

  - ``textwidth=0 colorcolumn=77,78,79``

  - ``textwidth=79 colorcolumn=77,78,79``

- Note that the author prefers a *colorcolumn* without *textwidth*
  enforcement.

Note that this plugin prevents itself from running on special buffers,
such as within the Quickfix buffer.

Hint: When you first open a Vim *help* file (``ft=help``), it'll
be formatted specially. But if you want to edit it, you can type
``set ft=text``, and then it'll be formatted like a normal text file.

- To reset the style back to a help file, type ``\E``, and the
  modeline will be re-read, and the file will reappear as a help file.
  (Note that most of the core Vim help files have a modeline at the
  bottom of the file, which specifies ``ft=help``.) You can also use
  Vim's built-in ``:e`` command to re-read an open buffer and reset
  its editing settings.

Installation
============

Installation is easy using the packages feature (see ``:help packages``).

To install the package so that it will automatically load on Vim startup,
use a ``start`` directory, e.g.,

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/start
    cd ~/.vim/pack/landonb/start

If you want to test the package first, make it optional instead
(see ``:help pack-add``):

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/opt
    cd ~/.vim/pack/landonb/opt

Clone the project to the desired path:

.. code-block:: bash

    git clone https://github.com/landonb/dubs_style_guard.git

If you installed to the optional path, tell Vim to load the package:

.. code-block:: vim

   :packadd! dubs_style_guard

Just once, tell Vim to build the online help:

.. code-block:: vim

   :Helptags

Then whenever you want to reference the help from Vim, run:

.. code-block:: vim

   :help dubs-style-guard

Modeline and Modeline Files
===========================

Vim has built-in support for modelines (refer to ``:help modeline``).

By default, Vim checks the first 5 and list 5 lines of a file for
a modeline (see the ``modelines`` setting).

- For an example, open any core Vim help file, and you'll typically
  find a modeline on the last line of the file.

This plugins also checks for a modeline. (2022-09-21: But the author
does not remember why this plugin duplicates functionality that Vim
implements. Perhaps, over a decade ago when I originally wrote this
plugin, Vim didn't read the modeline? I don't recall.)

This plugin also searches up the directory hierarchy for a special
modeline file, ``.dubs_style.vim``, that can contain a list of
filetypes and modelines. So you can easily define the style for
different projects and for different filetypes within projects.

- See the example ``.dubs_style.vim`` modeline file in
  the same directory as this README.

Note, however, that there are better style rule solutions.

- The author prefers the *EditorConfig* plugin, described next, to
  manage style rules. It works with other editors, and not just Vim.
  So if you collaborate with other developers, you'll benefit from a
  better solution, such as *EditorConfig*, that all team members can
  use, regardless of their preferred editor.

Similar Plugins
===============

Style-enforcers:

- `EditorConfig <http://editorconfig.org/>`__
  is a robust and universal style enforcer.

  - It uses an ``.editorconfig`` file similar
    (but more expressive) than ``.dubs_style.vim``.

  - There are plugins for most IDEs, in addition to Vim.

    - For the Vim plugin, download
      `EditorConfig Vim Plugin
      <https://github.com/editorconfig/editorconfig-vim>`__
      to, e.g., ``~/.vim/pack/editorconfig/start/editorconfig-vim``.

  - I recommend using
    `EditorConfig <http://editorconfig.org/>`__
    if you have a large team and not everyone
    has grown into Vim yet.

    But the ``.dubs_style.vim`` solution is nice because
    it uses the standard modeline syntax -- whereas *EditorConfig*
    uses its own INI-style format -- so if you're already a Vimmer,
    it's quick 'n easy to make a ``.dubs_style.vim`` file and stuff
    a modeline inside.

    - Also, the ``dubs_style_guard`` plugin has a few other features:

      - It'll tries to sleuth the style, if there's no modeline;

      - And the ``\e`` and ``\E`` macros make it easy to cycle through
        different styles and to reset the style.

Whitespace-detectors:

- `Vim-Sleuth <https://github.com/tpope/vim-sleuth>`__

- `DetectIndent <http://www.vim.org/scripts/script.php?script_id=1171>`__

Key Mappings
============

=================================  ==================================  ==============================================================================
 Key Mapping                        Description                         Notes
=================================  ==================================  ==============================================================================
 ``\e``                             Cycle Through Whitespace Styles     Cycles through the various syntax enforcement profiles.
                                                                        Currently, just two are active (spaced with 2 spaces/indent,
                                                                        and tabbed with 4 character widths/indent), though more are
                                                                        defined (six total for the combinations of tabbed or spaced
                                                                        and 2, 3, or 4 characters/indent).
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``\E``                             Reset Whitespace Style              Resets the buffer's whitespace configuration to either the
                                                                        file's modeline, the project's modeline, the deduced value
                                                                        (by counting and comparing lines that start with spaces versus
                                                                        tabs), or the default value set by the user
                                                                        (using ``g:dubs_style_preferred_expand_tab``
                                                                        and ``g:dubs_style_preferred_indent``).
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``\r``                             Cycle Through Long-Line Features    Cycles through the various long-line sytles.
                                                                        Currently, there are four styles -- just show a subtle column
                                                                        near the 80-character mark, also highlight long lines and
                                                                        automatically wrap long lines as they're typed, only autowrap,
                                                                        and show and do nothing with regard to long lines.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``\R``                             Reset Long-Line Feature             Resets the long-line feature to the default, which is to just show
                                                                        a subtle column near the 80-character mark but not to do anything else.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``:match none``                    Hide highlighted                    Use the command ``:match none`` to disable highlighting,
                                    too-wide text                       if you've enabled long-line highlighting.
=================================  ==================================  ==============================================================================

