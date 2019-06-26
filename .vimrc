" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
"set runtimepath=$VIMRUNTIME


" VUNDLE
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'godlygeek/tabular'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'fholgado/minibufexpl.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-scripts/searchfold.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
" END VUNDLE

" A clean-looking font for gvim
set guifont=dejavu\ sans\ mono\ 12

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup            " don't make backup files
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set list
set lcs=tab:\|\ ,trail:-,precedes:<,extends:>
set ts=4
set sw=4
set noet
set nowrap
set sidescroll=5
set ch=1
set noerrorbells
set vb t_vb=
set autowrite
set autoread
set ffs=unix,dos
set pastetoggle=<F6>
set fdo-=search
set title
set t_BE=

"set tags+=./tags;

" Don't use Ex mode, use Q for formatting
map Q gq

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  if &term =~ "xterm"
   set t_Co=256
   colo desert256
   if has("terminfo")
     let &t_Sf=nr2char(27).'[3%p1%dm'
     let &t_Sb=nr2char(27).'[4%p1%dm'
   else
     let &t_Sf=nr2char(27).'[3%dm'
     let &t_Sb=nr2char(27).'[4%dm'
   endif
  else
    colo desert
  endif
  " highlight Over100 guibg=grey25
  " match Over100 /.\%>101v/
  autocmd BufEnter * setlocal cursorline
  hi cursorline ctermbg=236 guibg=grey30
endif

function! SpaceInBraces()
	normal! di(
	let @" = substitute(@", '^\s*\(.\{-}\)\s*$', ' \1 ', '')
	normal! P
endfunction

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
  " autocmd FileType cpp setlocal omnifunc=GtagsComplete
  " autocmd FileType c setlocal omnifunc=GtagsComplete

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  au BufRead,BufNewFile *.make setfiletype make
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  fu! LoadProj()
      let fname = findfile("build.sh", "./;~")

      if strlen(fname)
          exe ":setl makeprg=" . escape(fnamemodify(fname, ":p") . " ". expand(expand("%:p:h")), ' ')
      else
          let fname = findfile("Makefile", "./;~")

          if strlen(fname)
              exe ":setl makeprg=make\\ -f\\ \\\"" . fnamemodify(fname, ":p:gs/ /\\\\ /") .
                                  \ "\\\"\\ -C\\ \\\"" . fnamemodify(fname, ":p:h:gs/ /\\\\ /") . "\\\""
          endif
      endif

      let fname = findfile(".myvimrc", "./;~")

      if strlen(fname)  && filereadable(fname)
          exe ":so " . fnamemodify(fname, ":p:gs/ /\\\\ /")
      endif
  endfun

  autocmd BufEnter * call LoadProj()

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" GitGutter
highlight GitGutterAdd    guifg=#009900 guibg=NONE ctermfg=2 ctermbg=NONE
highlight GitGutterChange guifg=#bbbb00 guibg=NONE ctermfg=3 ctermbg=NONE
highlight GitGutterDelete guifg=#ff2222 guibg=NONE ctermfg=1 ctermbg=NONE

" YouCompleteMe
" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = exepath("clangd-8")
let g:ycm_clangd_args = ['-background-index']

let g:miniBufExplorerMoreThanOne = 0
let g:miniBufExplForceSyntaxEnable = 1

let g:airline#extensions#wordcount#enabled = 0

let g:localvimrc_persistent = 2

if exists('&signcolumn')  " Vim 7.4.2201
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif

set completeopt=menuone,menu,longest
set complete-=i

vnoremap < <gv
vnoremap > >gv
noremap \p gP"_de
nmap <Leader>bb vi{<Plug>VisualComment
nmap <Leader>bd vi{<Plug>VisualDeComment

nmap <F7> :cp<CR>
nmap <F8> :cn<CR>

vmap <leader>w :w! /tmp/vitmp<CR>
nmap <leader>r :r! cat /tmp/vitmp<CR>

nnoremap <leader>( :call SpaceInBraces()<CR>

