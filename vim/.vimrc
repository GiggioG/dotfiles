" From tilde.club, from https://web.archive.org/web/20161224112739/https://dougblack.io/words/a-good-vimrc.html
syntax enable
filetype indent on

set tabstop=4 " how many spc=tab
set softtabstop=4 " visual how many spc=tab
set shiftwidth=4 " for >> and << commands
set cursorline " convert tabs to spc

" set number " line numbers
set relativenumber " line numbers
set wildmenu " menu autocomplete
set lazyredraw " redraw only when required
set showmatch " show matching brackets/quotes/...

set incsearch " search while typing
set hlsearch " highlight search results
" remove highlighing from search with "\ <Spc>"
nnoremap <leader><space> :nohlsearch<CR>

set splitright
set splitbelow

" make j not skip over "visual lines" created by wrapping long lines
" nnoremap j gj
" " same for k
" nnoremap k gk


" reload .vimrc with "\ s v"
"nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>sv :source ~/.vimrc<CR>

"
" ============= MY CONFIG ======================
"

set textwidth=120 " the length of text wrapping
set ignorecase
set smartcase " case sensitive search only when it includes a capital letter
colorscheme unokai

" FOR LEARNING
nnoremap <left> <nop>
nnoremap <right> <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <home> <nop>
nnoremap <end> <nop>

inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <home> <nop>
inoremap <end> <nop>

vnoremap <left> <nop>
vnoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <home> <nop>
vnoremap <end> <nop>
