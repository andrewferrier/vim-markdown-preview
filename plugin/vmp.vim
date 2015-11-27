function! ConvertMarkdownToHTML()
  ruby << RUBY
    VIM.evaluate('&runtimepath').split(',').each do |path|
      $LOAD_PATH.unshift(File.join(path, 'plugin', 'vim-markdown-preview'))
    end

    require('kramdown/kramdown')

    text = Array.new(VIM::Buffer.current.count) do |i|
      VIM::Buffer.current[i + 1]
    end.join("\n")

    VIM::Buffer.current.name.nil? ? (name = 'No Name.md') : (name = Vim::Buffer.current.name)

    preview_path = VIM.evaluate('&runtimepath').split(',').select{|path| path =~ /vim-markdown-preview/}.first
    cssfile = File.open("#{preview_path}/plugin/markdown-preview.css")
    style = cssfile.read

    layout = <<-LAYOUT
    <!DOCTYPE html>
    <html lang="en">
      <head>
          <meta charset="utf-8"/>
          <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
          <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
          <style type="text/css">
            #{style}
          </style>
          <title>#{File.basename(name)}</title>
      </head>
      <body>
          #{Kramdown::Document.new(text).to_html}
          <script>
            $('table').addClass('table');
          </script>
        </div>
      </body>
    </html>
    LAYOUT


    unless File.extname(name) =~ /\.(md|mkd|markdown|txt)/
      VIM.message('This file extension is not supported for Markdown previews')
    else
      file = File.join('/tmp', File.basename(name) + '.html')
      File.open('%s' % [ file ], 'w') { |f| f.write(layout) }
      Vim.command("silent !open '%s'" % [ file ])
    end
RUBY
endfunction

function! ConvertMarkdownToDocX()
    ruby << RUBY
    VIM::Buffer.current.name.nil? ? (name = 'No Name.md') : (name = Vim::Buffer.current.name)
    file = File.join('/tmp', File.basename(name) + '.docx')
    Vim.command("silent w !pandoc -o '%s'" % [ file ])
    Vim.command("silent !open -n '%s'" % [ file ])
RUBY
endfunction
