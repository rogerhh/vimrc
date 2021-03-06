syntax on

syntax enable

set hlsearch

set number

set backspace=indent,eol,start

set undofile
set undolevels=100
set undoreload=1000

set ruler
set cursorline

set showcmd

if has('mouse')
    set mouse=n
endif

" tabs
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent

" autoread
set autoread
au CursorHold * checktime
