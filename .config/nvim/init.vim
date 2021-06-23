
"---------------PLUGINS------------------
call plug#begin('~/.vim/plugged')
   Plug 'szw/vim-maximizer'
   Plug 'Xuyuanp/nerdtree-git-plugin'
   Plug 'neoclide/coc.nvim', {'branch': 'release'}
   Plug 'neoclide/coc-snippets'
   Plug 'tomasiser/vim-code-dark'
   Plug 'Yggdroot/indentLine'
   Plug 'vim-scripts/indentpython'
   Plug 'tmhedberg/SimpylFold'
   Plug 'morhetz/gruvbox'
   Plug 'ap/vim-css-color' 
   Plug 'danilo-augusto/vim-afterglow'
   Plug 'itchyny/lightline.vim'
   Plug 'Raimondi/delimitMate'
   Plug 'jmcantrell/vim-virtualenv' 
   Plug 'ap/vim-css-color'
   Plug 'kassio/neoterm' 
   Plug 'preservim/nerdtree'
   Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-telescope/telescope.nvim'
call plug#end()

set laststatus=2
set incsearch
set showmatch
set relativenumber
set number
set scrolloff=10
set autoindent
set nowrap
set tabstop=4
set shiftwidth=4
set breakindent
set linebreak
set expandtab
set nohlsearch
set hidden
set noerrorbells
set softtabstop=4
set smartindent
set smartcase
set cursorcolumn
set incsearch
set termguicolors
set completeopt=menuone,noinsert,noselect
set signcolumn=yes
set nocompatible
filetype plugin on
colorscheme onedark
let &runtimepath.=',~/.vim/bundle/neoterm'
set showtabline=2
set mouse=a
let mapleader = " " " space as leader key
"leader  v to  edit .vimrc
nnoremap <leader>v :e $MYVIMRC<CR>

"split navigations 
nnoremap <C-J> <C-W><C-J> 
nnoremap <C-K> <C-W><C-K> 
nnoremap <C-L> <C-W><C-L> 
nnoremap <C-H> <C-W><C-H> 

"leader + e to save
nnoremap <silent><leader>e   :w<cr>
"leader + w to save and quit
nnoremap <silent><leader>w   :wq<cr>


" itchyny/lightline.vim and itchyny/vim-gitbranch
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ 'colorscheme': 'codedark',
      \ }

hi Normal ctermbg=259
"let airline_theme='fairyfloss' 
"let g:airline_powerline_fonts = 1
hi PmenuSel guibg=#98c379
hi Pmenu guibg=#282c34
"set background=dark 
let g:python_highlight_all = 1
"set completeopt-=preview

"highlight! StatusLineNC gui=underline guibg=NONE guifg=#383c44
set cursorline
"hi cursorlinenr guibg=NONE guifg=#abb2bf

"map ii inplace of Esc 
imap ii <Esc>

if executable('rg')
    let g:rg_derive_root= 'true'
endif
"let g:netrw_banner_split=2
"let g:netrw_banner= 0

" szw/vim-maximizer
nnoremap <leader>m :MaximizerToggle!<CR>

"NERDTREE SETTINGS
nnoremap <leader>p :NERDTreeFocus<CR>
nnoremap <S-p> :NERDTreeToggle<CR>
nnoremap <S-f> :NERDTreeFind<CR>
nnoremap  <C-n> :tabnew<CR>

" enable line numbers in nerdtree 
let NERDTreeShowLineNumbers=1

" make sure relative line numbers are used
autocmd FileType nerdtree setlocal relativenumber

"close NERDTree  after opening a file 
let NERDTreeDirArrows = 1


"open current nerdtree in every new tab
autocmd BufWinEnter * silent :NERDTreeMirror


"ctrl navigation for insert mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

"insert mode go to end of line
imap <C-e> <ESC>A
imap <C-r> <ESC>0i
"
let g:neoterm_default_mod='belowright' " open terminal in bottom split
let g:neoterm_size=16 " terminal split size
let g:neoterm_autoscroll=1 " scroll to the bottom when running a command
let g:neoterm_term_per_tab = 1
nnoremap <c-y> :Ttoggle<CR>
inoremap <c-y> <Esc>:Ttoggle<CR>
tnoremap <c-y> <c-\><c-n>:Ttoggle<CR>

" sbdchd/neoformat
nnoremap <leader>f :Neoformat prettier<CR>

"Shift s to switch to next tab
nnoremap <S-s> :tabnext<CR>

"open terminal
nnoremap <leader>t :term<CR>

"hide preview 
let g:netrw_banner = 0

"NERDTREE always  show bookmarks
let NERDTreeShowBookmarks=1

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif


"F9 to run python2 code
autocmd FileType python map <buffer> <F9> :w<CR>:term python3 "%"<CR>

"F8 to run C program
map <F7>  :w <CR> :!gcc % -o %< <CR>

map <F8> :vertical terminal %<<CR>

"CONFIG FOR COC COMPLETION
"
"if has("patch-8.1.1564")
"  " Recently vim can merge signcolumn and number column into one
"  set signcolumn=number
"else
"  set signcolumn=yes
"endif
"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

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

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}


" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
"nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>



"Mappings for Telescope


nnoremap <leader>fb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>ff :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>fo :lua require('telescope.builtin').oldfiles()<CR>
nnoremap <leader>fm :Neoformat<CR>


let g:code_runner_save_before_execute = 1
"let g:code_runner_command_config_file=~/.config/nvim/runnerconfig.vim
"Mappings for CodeRunner

 nmap <silent><leader>b <plug>CodeRunner

