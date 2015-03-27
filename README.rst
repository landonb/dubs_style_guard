Dubsacks Vim — Style Guard
==========================

About This Plugin
-----------------

This plugin senses a file's whitespace style and sets Vim accordingly.

Note: The check is very basic: the script uses grep to count the
number of lines that start with spaces versus those that start with
tabs. The script does not attempt to discern how many spaces per tab
are used when space-indenting, nor how many spaces-per-tab are assumed
when tab-indenting.

This plugin makes it easy to switch between common whitespace styles:
type ``\e`` to cycle through a number of preset styles.

You can also cycle between common long-line styles:
type ``\r`` to cycle through a number of preset styles.
Some styles simply highlight long lines, while other
styles use ``textwidth`` to forcefully wrap a long line
as it's being typed.

The plugin prevents itself from running on special buffers,
like the Quickfix and Location lists.

Hint: When you first open a Vim *help* file, it'll be displayed
specially, like all help files. To edit it, just type
``set ft=text`` and start editing. To reset the style back
to help, type ``\E`` and the modeline will be re-read
(caveat: most help files use modelines, but not all of them).

Installation
------------

Standard Pathogen installation:

.. code-block:: bash

   cd ~/.vim/bundle/
   git clone https://github.com/landonb/dubs_style_guard.git

Or, Standard submodule installation:

.. code-block:: bash

   cd ~/.vim/bundle/
   git submodule add https://github.com/landonb/dubs_style_guard.git

Online help:

.. code-block:: vim

   :Helptags
   :help dubs-style-guard

Modeline and Modeline Files
---------------------------

Modelines are common to Vim, but they're generally only
read for help files. Dubsacks always looks for them in
the first five or last five lines of a file.

Dubsacks also searches up the directory hierarchy for a
special modeline file, ``.dubs_style.vim``, that can
contain a list of filetypes and modelines, so you can
easily define the style for different projects and for
different filetypes within projects.

For more help on the special modeline file, look at the
file of the same name in the source, in the same directory
as this readme.

Similar Plugins
---------------

Style-enforcers:

- `EditorConfig <http://editorconfig.org/>`__
  is a robust and universal style enforcer.

  - It uses an ``.editorconfig`` file similar
    (but more expressive) than ``.dubs_style.vim``.

  - There are plugins for most IDEs, in addition to Vim.

    - For the Vim plugin, download
      `EditorConfig Vim Plugin
      <https://github.com/editorconfig/editorconfig-vim>`__
      to your ``~/.vim/bundle`` directory.

  - I recommend using
    `EditorConfig <http://editorconfig.org/>`__
    if you have a large team and not everyone
    has grown into Vim yet.
    But the ``.dubs_style.vim`` solution is nice because
    it uses the standard modeline syntax -- whereas EditorConfig
    uses its own INI-style format -- so if you're already a Vimmer,
    it's quick 'n easy to make a ``.dubs_style.vim`` file and stuff
    a modeline in't.

    - Also, the ``dubs_style`` plugin has a few other features:
      it has a nice style sleuther
      and the ``\e`` and ``\E`` macros make it easy to cycle through and
      reset the style (based on the current modeline or sluethed answer).

Whitespace-detectors:

- `Vim-Sleuth <https://github.com/tpope/vim-sleuth>`__

- `DetectIndent <http://www.vim.org/scripts/script.php?script_id=1171>`__

Key Mappings
------------

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

