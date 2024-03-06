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
if v:version >= 801
	Plugin 'Valloric/YouCompleteMe'
	Plugin 'Yggdroot/indentLine'
	Plugin 'yuttie/comfortable-motion.vim'
endif
Plugin 'godlygeek/tabular'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'fholgado/minibufexpl.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-scripts/searchfold.vim'
Plugin 'andymass/vim-matchup'
Plugin 'editorconfig/editorconfig-vim'

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

set noswapfile
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
set tw=140
set cino=:0,l1,g0,t0,(s,U1,m1,j1,J1

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
	"hi Normal ctermfg=231 ctermbg=NONE cterm=NONE
	"hi Folded ctermfg=226 ctermbg=NONE cterm=NONE
	"hi FoldColumn ctermfg=226 ctermbg=NONE cterm=NONE
	if &term =~ "xterm"
		colo desert256
        hi cursorline cterm=none ctermbg=234 term=none
		set t_Co=256
		"if exists("&t_BE")
			"let &t_BE = "\e[?2004h"
			"let &t_BD = "\e[?2004l"
			"let &t_PS = "\e[200~"
			"let &t_PE = "\e[201~"
		"endif
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
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
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

set mouse=a

let g:vim_json_conceal=0

if v:version >= 801
	let g:comfortable_motion_interval = 1000.0 / 60.0
	let g:comfortable_motion_scroll_down_key = "j"
	let g:comfortable_motion_scroll_up_key = "k"
	let g:comfortable_motion_no_default_key_mappings = 1
	let g:comfortable_motion_impulse_multiplier = 1  " Feel free to increase/decrease this value.
	nnoremap <silent> <C-d> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 2)<CR>
	nnoremap <silent> <C-u> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -2)<CR>
	nnoremap <silent> <C-f> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 4)<CR>
	nnoremap <silent> <C-b> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -4)<CR>
	noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(40)<CR>
	noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-40)<CR>

	let g:indentLine_defaultGroup = 'SpecialKey'
	let g:indentLine_char = '┊'

	" YouCompleteMe
	" Let clangd fully control code completion
	let g:ycm_clangd_uses_ycmd_caching = 0
	let g:ycm_clangd_args = ['-background-index', '--query-driver=/opt/rh/devtoolset-11/root/usr/bin/c++']
	let g:ycm_auto_hover = ''
	let g:ycm_confirm_extra_conf = 0
endif

" GitGutter
highlight GitGutterAdd    guifg=#009900 guibg=NONE ctermfg=2 ctermbg=NONE
highlight GitGutterChange guifg=#bbbb00 guibg=NONE ctermfg=3 ctermbg=NONE
highlight GitGutterDelete guifg=#ff2222 guibg=NONE ctermfg=1 ctermbg=NONE

let g:miniBufExplorerMoreThanOne = 0
let g:miniBufExplForceSyntaxEnable = 1

let g:airline#extensions#wordcount#enabled = 0

map <Leader>x <plug>NERDCommenterComment
map <Leader>cc <plug>NERDCommenterComment
map <Leader>X <plug>NERDCommenterUncomment
map <Leader>cu <plug>NERDCommenterUncomment

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

nmap <F5> <plug>(YCMHover)
nmap <F7> :cp<CR>
nmap <F8> :cn<CR>


