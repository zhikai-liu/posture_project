function export_svg_jpg(filename)
print([filename,'.svg'],'-dsvg','-painters')
print([filename,'.jpg'],'-djpeg','-r300')
end