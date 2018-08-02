:let maplocalleader = ","

" Map <localleader>ev to open key mappings file
nnoremap <localleader>ev :vsp ~/vimrc_config/nvim/config/keys.vimrc<cr>

" Map <localleader>sv to source $MYVIMRC
nnoremap <localleader>sv :source $MYVIMRC<cr>:nohl<cr>

" Map ctrl-u in insert mode to convert a word to uppercase
inoremap <localleader><c-u> <esc>viwUea

" Map ctrl-u in normal mode to convert a word to uppercase
nnoremap <localleader><c-u> viwUe

" Auto save file if already in .vimrc
augroup file_type_vim
    autocmd!
    autocmd FileType vim nnoremap <localleader>sv :w<cr> :source $MYVIMRC<cr>:nohl<cr>
augroup END

" Map /"/" in insert mode to move into the quotation marks 
inoremap "" ""<esc>i

" Map '' in insert mode to move into the quotation marks 
inoremap '' ''<esc>i

" Map () in insert mode to move into the parentheses 
inoremap () ()<esc>i

" Map [] in insert mode to move into the square brackets 
inoremap [] []<esc>i

" Map <> in insert mode to move into the angular brackets 
inoremap <> <><esc>i

" Map {} in insert mode to move into the braces 
inoremap {} {}<esc>i

" Map H in normal mode to move to beginning of line
nnoremap H 0

" Map L in normal mode to move to end of line
nnoremap L $

" Map <localleader>hl in normal mode to set highlight off
nnoremap <localleader>hl :nohl<cr>

" Group html specific settings
augroup filetype_html
    autocmd!
    autocmd FileType html setlocal nowrap
    autocmd BufNewFile,BufRead *.html normal gg=G
augroup END

" Group cpp specific settings
augroup filetype_cpp
    autocmd!
    autocmd FileType cpp setlocal wrap
    autocmd FileType cpp nnoremap <localleader>c I// <esc>
    autocmd FileType cpp vnoremap // <esc>'<O<esc>i/*<esc>'>o<esc>i*/<esc>
augroup END

" Map jk in insert mode to <esc> and disable the old <esc>
inoremap jk <esc>l
inoremap <localleader>jk <localleader><esc>l
inoremap <c-[> <nop>

" Map jk in visual mode to <esc>
vnoremap jk <esc>
vnoremap <c-[> <nop>

" Disable arrow keys
noremap <left> <nop>
noremap <right> <nop>
noremap <up> <nop>
noremap <down> <nop>
