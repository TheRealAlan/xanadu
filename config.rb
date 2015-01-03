#   Development Specific Configs
# -----------------------------------------

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Enable Autoprefixer
activate :autoprefixer

#   Routes
# -----------------------------------------

# Remove .html in URLs
activate :directory_indexes

page "404.html", :directory_index => false

#   Assets
# -----------------------------------------

set :css_dir, 'assets/css'
set :js_dir, 'assets/js'
set :images_dir, 'assets/img'
set :fonts_dir, 'assets/fonts'

after_configuration do
  sprockets.append_path File.join root.to_s, "bower_components"
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css do |c|
    c.ignore = [ /assets\/css\/240268\/.*\.css$/ ]
  end

  # Minify Javascript on build
  activate :minify_javascript

  # Minify HTML on build
  activate :minify_html
end
