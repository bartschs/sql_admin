" Vim
" An example for a vimrc file.
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"             for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc

set nocompatible        " Use Vim defaults (much better!)
set bs=2                " allow backspacing over everything in insert mode
set noai                  " always set autoindenting on
set nows                  " always set nowrapscan  on
" set tw=78               " always limit the width of text to 78
set backup              " keep a backup file
set viminfo='20,\"50    " read/write a .viminfo file, don't store more
			" than 50 lines of registers

if &term == "xterm"
  set t_kb=
  fixdel
endif

" Don't use Ex mode, use Q for formatting
map Q gq

