
" Basic settings {{{
syntax on
set noerrorbells
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set incsearch
set relativenumber
set scrolloff=8
set colorcolumn=80
set signcolumn=yes
let mapleader = " "
" }}}

" Plugins and plugin tools {{{
function! s:local_plug(package_name)
  if isdirectory(expand("~/test-projects/plugins/" . a:package_name))
    execute "Plug '~/test-projects/plugins/" . a:package_name . "'"
  endif
endfunction

call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'
Plug 'vim-airline/vim-airline'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'
Plug 'vim-test/vim-test'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'stsewd/fzf-checkout.vim'
Plug 'liuchengxu/vim-which-key'
Plug 'jiangmiao/auto-pairs'
Plug 'joshdick/onedark.vim'
Plug 'preservim/nerdtree'
Plug 'mhinz/vim-startify'
Plug 'hzchirs/vim-material'
Plug 'honza/vim-snippets'
call s:local_plug('java_file_creator.vim')
call plug#end()
" }}}

colorscheme gruvbox
set background=dark

if executable('rg')
    let g:rg_derive_root='true'
endif


let g:ctrlp_use_caching =0
nnoremap <expr> <leader>b  'mqA;<Esc>`q<CR>'

" Window mappings {{{
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>r :Rg<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>
nnoremap <Leader>m :MaximizerToggle<CR>

" }}}
" Git {{{
" Sweet Sweet FuGITive
let $FZF_DEFAULT_OPTS='--reverse'
nmap <leader>gh :diffget //3<CR>
nmap <leader>gu :diffget //2<CR>
nmap <leader>gs :G<CR>
nnoremap <leader>gc :GBranches<CR>
nnoremap <leader>gp :Git -c push.default=current push<CR>
" }}}

" coc and vimspector remaps {{{
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> fm <Plug>(coc-format)
nmap <silent> qf <Plug>(coc-fix-current)
nmap <silent> cl <Plug>(coc-codelens-action)
nmap <silent> ne <Plug>(coc-diagnostic-next-error)
nmap <silent> re <Plug>(coc-rename)
nmap <silent> la <Plug>(coc-codeaction-cursor)

nmap <silent> dl <Plug>VimspectorStepInto
nmap <silent> dj <Plug>VimspectorStepOver
nmap <silent> dk <Plug>VimspectorStepOut
nmap <silent> d_ <Plug>VimspectorRestart
nnoremap <silent> K :call <SID>show_documentation()<CR>

nnoremap <Leader>o :CocList outline<CR>
nnoremap <Leader>tb :call vimspector#ToggleBreakpoint()<CR>
nnoremap <Leader>cb :call vimspector#ClearBreakpoints()<CR>
nnoremap <Leader>st :call vimspector#Reset()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <silent> run :CocList mainClassListRun<CR>
nnoremap <Leader>d :CocCommand java.debug.debugJavaFile<CR>
" }}}


nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

" Back to terminal normal mode
tnoremap <Esc> <C-\><C-n>

" NERDTree remaps {{{
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" }}}

" Edit and source vimrc {{{
:nnoremap <leader>ev :vsplit $MYVIMRC<cr>
:nnoremap <leader>sv :source $MYVIMRC<cr>
" }}}

nnoremap - ddp
nnoremap _ ddkP
inoremap jk <esc>
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
" autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    " \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,              -- false will disable the whole extension
  }
}
EOF
" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif

" Vimscript file settings ---------------------- {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup end
" }}}

" Conventional commits {{{
function! s:Add_conventional_commits()
  inoreabbrev <buffer> BB BREAKING CHANGE:
  nnoremap    <buffer> i  i<C-r>=<sid>Commit_type()<CR>
endfunction

function! s:Commit_type()
  call complete(1, ['fix: ', 'feat: ', 'refactor: ', 'docs: ', 'test: '])
  nunmap <buffer> i
  return ''
endfun

augroup conventional_commits
  autocmd!
  autocmd FileType gitcommit :call s:Add_conventional_commits()
augroup END
" }}}

" Abbrevs {{{
iabbrev @@ ramin.siach@gmail.com
iabbrev dont don't
" }}}

" quoting words {{{
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
nnoremap <leader>"- viw<esc>exbhxe
nnoremap <leader>'- viw<esc>exbhxe
vnoremap <leader>' <esc>`>a'<esc>`<i'<esc>lv`>l
nnoremap H 0
nnoremap L $
" }}}


augroup java_abbrev
  autocmd!
  autocmd FileType java :iabbrev <buffer> cs CompletionStage
augroup END