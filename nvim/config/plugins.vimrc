" If vim-plug is not installed, install it in ~/.vim/autoload
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" List of plugins
Plug 'junegunn/vim-plug'

" Neomake
Plug 'neomake/neomake'

" neovim-complietion-manager
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" language client
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" some completion sources
Plug 'ncm2/ncm2-bufword'
" Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-jedi'

" nerdtree
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle'}

" vim-misc and vim-session
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

" END list of plugins
call plug#end()

" Neomake settings

" Full config: when writing or reading a buffer, and on changes in insert and
" normal mode (after 1s; no delay when writing)
let g:neomake_cpp_enabled_makers = ['clang']
let g:neomake_cpp_clang_args = ["-std=c++14", "-Wall"]
call neomake#configure#automake('w')

" END Neomake setting

" ncm2 settings

" Enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" Must keep noinsert
set completeopt=noinsert,menuone,noselect

" suppress 'match x of y', 'The only match' and 'Pattern not found' messages
set shortmess+=c

" map ctrl-c to <esc>
inoremap <c-c> <esc>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line. (commented out)
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
au User Ncm2Plugin call ncm2#register_source({
        \ 'name' : 'css',
        \ 'priority': 9, 
        \ 'subscope_enable': 1,
        \ 'scope': ['css','scss'],
        \ 'mark': 'css',
        \ 'word_pattern': '[\w\-]+',
        \ 'complete_pattern': ':\s*',
        \ 'on_complete': [ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
        \ })

" Required for operations modifying multiple buffers like rename.
set hidden

" NOTE: clangd requires that `compile_commands.json` exist in the current
"       directory or a parent directory!
"
"       Running `bear make` on a Makefile-based project will allow bear
"       to capture the compilation commands used and generate a matching
"       JSON file. If `compile_commands.json` is empty, try running
"       `make clean` first.
"
"       (Obviously, this only works if you have bear installed.)
let g:LanguageClient_serverCommands = {
    \ 'cpp': ['clangd'],
    \ 'c': ['clangd'],
    \ 'c.doxygen': ['clangd'],
    \ 'cpp.doxygen': ['clangd'],
    \ 'python': ['pyls']
    \ }

let g:LanguageClient_autoStart = 1

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" END ncm2 settings

" nerdtree settings

" map crtl-n to open nerdtree
map <c-n> :NERDTreeToggle<cr>

" END nerdtree settings

" vim-session settings
let g:session_autoload = 'no'
let g:session_autosave = 'no'
" END vim-session settings
