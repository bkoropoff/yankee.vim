let g:yankee_ring_size = get(g:, 'yankee_ring_size', 50)

let s:ring = get(s:, 'ring', [])
let s:filter = ''
let s:idx = 0
let s:attached = get(s:, 'attached', 0)
let s:defer = 0
let s:deferred = []

" WTF
function! s:mod(n, m)
    return ((a:n % a:m) + a:m) % a:m
endfunction

" Selected entry update
"
" An offset of 0 only moves the index to satisfy a filter
function! s:Excursion(offset)
    let size = len(s:ring)
    if size == 0
        return ''
    endif
    let s:idx = s:mod(s:idx + a:offset, size)
    if s:filter != '' && !(s:ring[s:idx] =~ s:filter)
        let offset = a:offset ? a:offset : 1
        let idx = s:mod(s:idx + offset, size)
        while idx != s:idx
            if s:ring[idx] =~ s:filter
                let s:idx = idx
                return s:ring[idx]
            endif
            let idx = s:mod(idx + offset, size)
        endwhile
        return ''
    else
        return s:ring[s:idx]
    endif
endfunction

" Add entry to yank ring.
"
" If not deferred, this sets the selected entry to the one just added modulo
" filtering.  The selected entry is returned.
function! yankee#ring#add(contents)
    if s:defer
        call add(s:deferred, a:contents)
        return s:Excursion(0)
    endif

    let idx = index(s:ring, a:contents)
    if idx >= 0
        call remove(s:ring, idx)
    endif

    call insert(s:ring, a:contents)
    if len(s:ring) >= g:yankee_ring_size
        call remove(s:ring, g:yankee_ring_size - 1, -1)
    endif
    return yankee#ring#newest()
endfunction

" Synchronizes yank ring with the configured clipboard and returns the default
" register
function! yankee#ring#sync_clipboard()
    if &clipboard == 'unnamed'
        let reg = '*'
    elseif &clipboard == 'unnamedplus'
        let reg = '+'
    else
        return '"'
    endif
    let value = getreg(reg)
    if len(value) != 1 && (len(s:ring) == 0 || s:ring[0] != value)
        call yankee#ring#add(value)
    endif
    return reg
endfunction

function! yankee#ring#clear()
    let s:ring = []
    let s:idx = 0
endfunction

function! yankee#ring#current()
    return s:Excursion(0)
endfunction

function! yankee#ring#older()
    return s:Excursion(1)
endfunction

function! yankee#ring#newer()
    return s:Excursion(-1)
endfunction

function! yankee#ring#newest()
    let s:idx = 0
    return s:Excursion(0)
endfunction

function! yankee#ring#oldest()
    let size = len(s:ring)
    let s:idx = size ? size - 1 : 0
    return s:Excursion(0)
endfunction

function! yankee#ring#filter(filt)
    let s:filter = a:filt
    return s:Excursion(0)
endfunction

function! yankee#ring#reset()
    let s:idx = 0
    let s:filter = ''
    return s:Excursion(0)
endfunction

function! yankee#ring#defer()
    let s:deferred = []
    let s:defer = 1
endfunction

function! yankee#ring#undefer()
    let s:defer = 0
    for item in s:deferred
        call yankee#ring#add(item)
    endfor
    let s:deferred = []
endfunction

""
" Yank interception
""

function! s:Intercept(event)
    " Ignore yanks to non-default register
    if a:event.regname != ''
        return
    endif
    let contents = join(a:event.regcontents, "\n").(a:event.regtype == 'V' ? "\n" : "")
    if len(contents) == 1
        return
    endif
    call yankee#ring#add(contents)
endfunction

function! yankee#ring#attach()
    if !s:attached
        augroup yankee#ring
            autocmd!
            autocmd TextYankPost * call <sid>Intercept(v:event)
        augroup END
        let s:attached = 1
    endif
endfunction

function! yankee#ring#detach()
    if s:attached
        augroup yankee#ring
            autocmd!
        augroup END
        let s:attached = 0
    endif
endfunction
