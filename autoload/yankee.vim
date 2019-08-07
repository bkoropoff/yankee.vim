let g:yankee_older_key = get(g:, 'paste_older_key', 'p')
let g:yankee_newer_key = get(g:, 'paste_newer_key', 'P')
let g:yankee_filter_key = get(g:, 'paste_filter_key', '/')

function! s:Paste(text)
    " Undo last paste
    if s:last != ''
        silent normal! u
        let s:last = ''
    endif

    if a:text == ''
        return
    endif
    
    " Paste text
    let old = @@
    let @@ = a:text
    exec 'silent normal!' s:cmd
    let @@ = old

    " Set visual range to paste
    if s:select
        exec "silent normal! `[v`]\<esc>"
    endif

    let s:last = a:text
endfunction

function! s:Highlight(filt)
    if a:filt == ''
        set nohlsearch
    else
        let @/ = '\%V'.a:filt
        set hlsearch
    endif
endfunction

function! s:Filter()
    call inputsave()
    let filt = input("filter: ")
    call inputrestore()

    let text = yankee#ring#filter(filt)
    if text == ''
        call s:Paste(yankee#ring#filter(''))
        call s:Highlight(filt)
        return {'hl': 'ErrorMsg', 'text': 'No match in yank ring'}
    else
        call s:Paste(text)
        call s:Highlight(filt)
    endif
endfunction

function! s:Enter()
    " Save search register and highlight option
    let s:slash = @/
    let s:hlsearch = &hlsearch

    " Initialize session var
    let s:last = ''
    
    " Defer new yanks entering ring (e.g. overwritten region in visual mode)
    call yankee#ring#defer()
    " Reset filter on each new paste to avoid confusion (where'd my yank go?!)
    call yankee#ring#filter('')
    " Clear highlighting
    call s:Highlight('')

    let text = yankee#ring#current()
    " Refuse to use an empty ring
    if text == ''
        throw "yankee#ring:Yank ring is empty"
    endif

    call s:Paste(text)
endfunction

function! s:Leave()
    " Restore saved vars
    let @/ = s:slash
    let &hlsearch = s:hlsearch

    " Add deferred yanks to ring
    call yankee#ring#undefer()
endfunction

let s:mode = minimode#compile({
            \    'name': 'yankee',
            \    'enter': funcref('s:Enter'),
            \    'leave': funcref('s:Leave'),
            \    'actions': {
            \        g:yankee_older_key : {
            \            'name': 'older',
            \            'call': {-> s:Paste(yankee#ring#older())}
            \        },
            \        g:yankee_newer_key : {
            \            'name': 'newer',
            \            'call': {-> s:Paste(yankee#ring#newer())}
            \        },
            \        g:yankee_filter_key : {
            \            'name': 'filter',
            \            'call': funcref('s:Filter')
            \        }
            \    }
            \})

function! yankee#paste(cmd, visual)
    let s:select = !a:visual && &l:modifiable
    let c = v:count ? v:count : ''
    let gv = a:visual ? 'gv' : ''
    
    let reg = yankee#ring#sync_clipboard()
    if v:register != reg
        " If asked to paste from specific register, just do the put
        exec 'normal! '.gv.c.'"'.v:register.a:cmd
        return
    endif

    let s:cmd = gv.c.'""'.a:cmd

    " Handle terminals, etc.
    if !&l:modifiable
        " Can't undo last paste, so always reset var
        let s:last = ''
        " Just paste from the head of the yankee#ring
        call s:Paste(yankee#ring#newest())
        return
    endif

    return minimode#run(s:mode)
endfunction
