if exists('g:loaded_tnt') || &cp
	finish
endif
let g:loaded_tnt = 1

augroup TNT
  autocmd!
  autocmd BufRead,BufNewFile *.tnt*,*.ana* call tnt#outliner#on_open_file()
  " temporarily switch to manual folding when entering insert mode,
  " so that adjacent folds won't inaverdtently open when we create new folds.
  autocmd InsertEnter *.tnt*,*.ana* let w:last_fm=&foldmethod
    \ | setlocal foldmethod=manual
  autocmd InsertLeave *.tnt*,*.ana* let &l:foldmethod=w:last_fm
augroup END

let g:tnt_regex = {
  \ 'thread': '^\s*"\([^"]*"[^"]*"\)*[^"]*$'
  \ }

nnoremap <silent> <Space>w :TNTTriggerSession<CR>
command! -nargs=0 TNTTriggerSession call tnt#outliner#trigger_session(line('.'))

nnoremap <silent> <Space>W :TNTCreateWebpage<CR>
command! -nargs=0 TNTCreateWebpage call tnt#outliner#create_webpage()

nnoremap <silent> <Space>t :echo 'cmd-t for folds'<CR>

" go to current heading's next sibling.
nnoremap <silent> <Space>j :call tnt#outliner#go_next_sibling()<CR>
" go to current heading's previous sibling.
nnoremap <silent> <Space>k :call tnt#outliner#go_previous_sibling()<CR>
" go to current subtree's heading.
nnoremap <silent> <Space>h @=(tnt#outliner#indent_level('.')?'[z':'')<CR>
" go to next subtree's heading.
nnoremap <silent> <Space>n ]zj

" go to first heading of a lower level than the current.
nnoremap <silent> <Space>l :call tnt#outliner#go_first_lower('j')<CR>
" go to current subtree's last open item.
nnoremap <silent> <Space>e ]z
" go to current tree's (whole tree from root) last open item.
" for now go to subtree's last item, opening recursively.
nnoremap <silent> <Space>E ]zzO

" go back to find the first heading of a lower level than the current.
nnoremap <silent> <Space>gl :call tnt#outliner#go_first_lower('k')<CR>

" go to 0th-level heading of current fold, or nth-level with a count.
nnoremap <silent> <Space>H :<C-U>call tnt#outliner#go_summit(v:count)<CR>
" go to 0th-level next heading
nnoremap <silent> <Space>L :<C-U>call tnt#outliner#go_summit(0)<CR>
  \ :call tnt#outliner#go_next_sibling()<CR>

" close current subtree's heading
nnoremap <silent> <Space>c @=(tnt#outliner#indent_level('.')?'[z':'')<CR>zc
" close 0th-level heading of current fold, or nth-level with a count.
nnoremap <silent> <Space>C :<C-U>call tnt#outliner#go_summit(v:count)<CR>zc

" insert a new parent for the current item. 
"nnoremap <silent> <Space>i
" insert a new absolute parent for the current item, given a count.
" by default, if you don't supply a count, 1 is used, meaning it will insert
" a parent at the level below root--this is more useful in tnt, where you'll
" want to add a new top-level trigger when priorities change--but you can
" change it to another number such as 0 by using `let g:TNTIDefaultCount = 0`.
"nnoremap <silent> <Space>I

" add a new child to the current fold, prepending it to the list. 
"nnoremap <silent> <Space>a
" append a new child to the current fold.
"nnoremap <silent> <Space>A
" prepend a new sibling to the current fold's parent.
"nnoremap <silent> <Space>o
" append a new sibling to the current fold's parent.
"nnoremap <silent> <Space>O

" capital B should operate always on top level block.
" b should be aware of the current indentation's block.

" open all folds on current block.
nnoremap <silent> <Space>bo {v}zo
" close all folds on current block.
nnoremap <silent> <Space>bc {v}zc
" minimize all folds on current block.
nnoremap <silent> <Space>bm {v}zmzc
" open all threads on current block.
nnoremap <silent> <Space>bt {v}zmzo

" move down to next block
"nnoremap <silent> <Space>bj
" move up to previous block
"nnoremap <silent> <Space>bk

" search only visible text
nnoremap <silent> <Space>/
  \ :<C-U>call tnt#outliner#search(':wait', 'n', 1)<CR>
nnoremap <silent> <Space>? 
  \ :<C-U>call tnt#outliner#search(':wait', 'N', 1)<CR>
" go to next visible match
nnoremap <silent> <Space>n 
  \ :<C-U>call tnt#outliner#search(':next', 'n', 1)<CR>
" go to previous visible match
nnoremap <silent> <Space>N 
  \ :<C-U>call tnt#outliner#search(':next', 'N', 1)<CR>

" search for next/prev visible markdown heading
command! -nargs=0 TNTVisibleHeadingNext 
  \ call tnt#outliner#search("^\s*#", 'n')
nnoremap <silent> <Space>mh :TNTVisibleHeadingNext<CR>
command! -nargs=0 TNTVisibleHeadingPrev
  \ call tnt#outliner#search("^\s*#", 'N')
nnoremap <silent> <Space>ml :TNTVisibleHeadingPrev<CR>
" search for next/prev markdown heading
command! -nargs=0 TNTVisibleHeadingNext
  \ call tnt#outliner#search("^\s*#", 'n')
nnoremap <silent> <Space>mh :TNTVisibleHeadingNext<CR>
command! -nargs=0 TNTVisibleHeadingPrev 
  \ call tnt#outliner#search("^\s*#", 'N')
nnoremap <silent> <Space>ml :TNTVisibleHeadingPrev<CR>

command! -nargs=0 TNTVisibleSectionNext 
  \ call tnt#outliner#search('^$', 'n')
nnoremap <silent> <Space>} :TNTVisibleSectionNext<CR>
command! -nargs=0 TNTVisibleSectionPrev 
  \ call tnt#outliner#search('^$', 'N')
nnoremap <silent> <Space>{ :TNTVisibleSectionPrev<CR>

" search for next/prev visible thread
command! -nargs=0 TNTVisibleThreadNext 
  \ call tnt#outliner#search(g:tnt_regex.thread, 'n')
nnoremap <silent> <Space>m' :TNTVisibleThreadNext<CR>
command! -nargs=0 TNTVisibleThreadPrev 
  \ call tnt#outliner#search(g:tnt_regex.thread, 'N')
nnoremap <silent> <Space>m" :TNTVisibleThreadPrev<CR>
" search for next/prev thread
command! -nargs=0 TNTThreadNext 
  \ execute "normal! /" . g:tnt_regex.thread . "\<CR>"
nnoremap <silent> <Space>M' :TNTThreadNext<CR>
command! -nargs=0 TNTThreadPrev 
  \ execute "normal! ?" . g:tnt_regex.thread . "\<CR>"
nnoremap <silent> <Space>M" :TNTThreadPrev<CR>

" demote current heading.
nnoremap <silent> <Space>>> zc>>zo
" promote current heading.
nnoremap <silent> <Space><< zc<<zo
" move current fold down one position.
nnoremap <silent> <Space>mj zcddpzo
" move current fold up one position.
nnoremap <silent> <Space>mk zcddkPzo

" ----------------
" TNT-API COMMANDS
" ----------------

" DELETION COMMANDS
"
" mutinying a line promotes the first child to take it's place.
command! -nargs=+ TNTMutinyLine call tnt#api#mutinyLine(<f-args>)
" exploding a line eclodes it's children, i.e. it promotes each of them.
command! -nargs=+ TNTExplodeLine echo "TNTExplodeLine is not implemented."
" killing a line orphans it's children, sending them to the nearest inbox.
command! -nargs=+ TNTKillLine echo "TNTKillLine is not implemented."
" killing a fold deletes the heading and all it's children, recursively.
command! -nargs=+ TNTKillFold echo "TNTKillFold is not implemented."
