let s:scriptpath = expand('<sfile>:p:h:h')

let s:open_command = 'open'

if !executable(s:open_command)
    let s:open_command = 'nohup xdg-open'
endif

function! s:CheckDependency(command) abort
    if !executable(a:command)
        echoerr a:command . ' not available'
    endif
endfunction

function! s:GetFilename() abort
    if bufname('%') ==# ''
        let l:filename = 'No Name.md'
    else
        let l:filename = fnamemodify(bufname('%'), ':t')
    endif

    return l:filename
endfunction

function! s:GenerateFilename(ext) abort
    let l:filename = s:GetFilename()
    return l:filename . '.' . a:ext
endfunction

function! s:GenerateHTML() abort
    let l:filename = s:GetFilename()
    let l:markdownwrapper = s:scriptpath . '/markdown-wrapper.js ' . l:filename
    let l:htmlcontent = system(l:markdownwrapper, join(getline(1,'$'),"\n"))

    return l:htmlcontent
endfunction

function! vim_markdown_preview#ConvertMarkdownToPDF() abort
    call s:CheckDependency('wkhtmltopdf')

    let l:filename = s:GenerateFilename('pdf')
    let l:html = s:GenerateHTML()
    call system('wkhtmltopdf - ' . l:filename, l:html)
    call system(s:open_command . ' ' . l:filename . '&')
endfunction

function! vim_markdown_preview#ConvertMarkdownToDocX() abort
    call s:CheckDependency('pandoc')

    let l:filename = s:GenerateFilename('docx')
    call system('pandoc -o ' . l:filename, join(getline(1,'$'),"\n"))
    call system(s:open_command . ' ' . l:filename . '&')
endfunction

function! vim_markdown_preview#ConvertMarkdownToHTML() abort
    let l:filename = s:GenerateFilename('html')
    let l:html = s:GenerateHTML()

    call writefile(split(l:html, "\n", 1), l:filename, 'b')
    call system(s:open_command . ' ' . l:filename)
endfunction
