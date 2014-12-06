" vimrc, http://sh.kirsle.net/
" Last Modified 2013/09/27

" https://www.mail-archive.com/fish-users@lists.sourceforge.net/msg01425.html
if $SHELL =~ 'bin/fish'
	set shell=/bin/bash
endif

set encoding=utf8             " Unicode support
set nocompatible              " use vim defaults
set background=dark           " my terminal has a black background
set tabstop=4                 " number of spaces for tab character
set softtabstop=4             " insert/delete 4 spaces when hitting a tab/backspace
set shiftwidth=4              " number of spaces to auto-indent
set shiftround                " round indent to multiple of 'shiftwidth'
set scrolloff=3               " keep 3 lines when scrolling
set smartindent               " smart auto-indenting (recognizes C-like code)
set showmatch                 " hilite the matching brace when we type the closing brace
set nohls                     " don't highlight search matches
set incsearch                 " incremental search (search while you type)
set ignorecase                " case-insensitive search
set showcmd                   " display incomplete commands
set ttyfast                   " smoother changes
set autowrite                 " automatic saving when quitting and switching buffer
set autoread                  " automatic read when file is modified from outside
syntax on                     " syntax highlighting

" Leader Key
map <space> <leader>

" When vimrc is edited, reload it.
autocmd! BufWritePost .vimrc source ~/.vimrc

" Enable filetype plugin
filetype plugin on
filetype indent on

" Mouse support that keeps the fast scroll wheel speed.
set mouse=a
set ttymouse=xterm2
map <MouseUp> 12j
map <MouseDown> 12k
map <MiddleMouse> <Nop>
imap <MouseUp> <C-O>12j
imap <MouseDown> <C-O>12k
imap <MiddleMouse> <Nop>

" Make movement make sense across wrapped lines.
nnoremap j gj
nnoremap k gk
imap <Up> <C-O>gk
imap <Down> <C-O>gj
map <Up> gk
map <Down> gj

" Tell Vim to remember things when we exit:
"  '10  : marks will be remembered for up to 10 previously edited files
"  "100 : will save up to 100 lines for each register
"  :20  : up to 20 lines of command-line history remembered
"  %    : saves and restores the buffer list
"  n... : where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo'

" Restore the cursor position.
function! ResCur()
	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction
augroup resCur
	autocmd!
	autocmd BufWinEnter * call ResCur()
augroup END

" make tab in v mode indent code
vmap <tab> >gv
vmap <s-tab> <gv

" make tab in normal mode indent code
nmap <tab> I<tab><esc>
nmap <s-tab> ^i<bs><esc>

" change the bash title so the filename is first in the title bar
let &titlestring = expand("%:t") . " - vim on " . hostname()
if &term == "screen"
	set t_ts=k
	set t_fs=\
endif
if &term == "screen" || &term == "xterm" || &term == "xterm-256color"
	set title
endif

" custom file extensions
au BufNewFile,BufRead *.panel set filetype=html
au BufNewFile,BufRead *.tt set filetype=html
au BufNewFile,BufRead *.tp set filetype=html

" Tab Navigation
nnoremap [t :tabprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [T :tabfirst<CR>
nnoremap ]T :tablast<CR>

" Buffer Navigation
nnoremap [b :bprev<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>

""""""""""""""""""""""""
""" General coding stuff
""""""""""""""""""""""""

" git commit messages
autocmd Filetype gitcommit setlocal spell textwidth=72

" reStructuredText
autocmd FileType rst set tabstop=3 softtabstop=3 shiftwidth=3 expandtab

" Make sure the syntax is always right, even when in the middle of
" a huge javascript inside an html file.
autocmd BufEnter * :syntax sync fromstart

" Map F12 to sync the syntax too.
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>

" Markdown syntax
autocmd BufRead,BufNewFile *.md set ft=markdown

" Show tab characters
set list listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:x
highlight SpecialKey ctermfg=darkgrey guifg=darkgrey

" Show a divider line at the 80 column mark
if v:version > 702
	set colorcolumn=80,120
	highlight ColorColumn ctermbg=darkgrey guibg=darkgrey
endif

""""""""""""""
""" Perl stuff
""""""""""""""

" check perl code with :make
autocmd FileType perl set makeprg=perl\ -c\ %\ $*
autocmd FileType perl set errorformat=%f:%l%m

" syntax highlight pod documentation correctly
let perl_include_pod = 1

" syntax color complex things like @{${"foo"}}
let perl_extended_vars = 1

"""""""""""""""
""" vim plugins
"""""""""""""""

" My vim plugins. https://github.com/gmarik/Vundle.vim
filetype off

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Layout Plugins
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'bling/vim-airline'
Plugin 'majutsushi/tagbar'
Plugin 'tomasr/molokai'

" Editor Enhancements
Plugin 'kien/ctrlp.vim'

" Languages
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-markdown'
Plugin 'editorconfig/editorconfig-vim'

call vundle#end()         " required
filetype plugin indent on " required

" Brief help:
" :PluginList
" :PluginInstall    - installs plugins; append '!' to update or :PluginUpdate
" :PluginSearch foo - searches for foo; append '!' to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append '!'
"                     to auto-approve removal
"
" See :h vundle for more details

"""""""""""""""""""""""""
""" Plugin Configurations
"""""""""""""""""""""""""

colorscheme molokai

"----------
" NERD Tree
"----------

" Auto-open the NERDTree
autocmd VimEnter * NERDTree

" The same, but for when you open vim w/o a specific file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" map Space-d to show/hide the NERDTree
nmap <leader>d :NERDTreeToggle<CR>

" close VIM if the only window left open is the NERDTree
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" NERD Tree Tabs
map <leader>n <Plug>NERDTreeTabsToggle<CR>

"--------
" Airline
"--------

" Sexier tab bar
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#tab_nr_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

"--------
" Tag bar
"--------

" F8 to show/hide the tag bar
nmap <F8> :TagbarToggle<CR>

"------
" CtrlP
"------

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

"-----
" Misc
"-----

autocmd BufNewFile,BufReadPost *.md set filetype=markdown
