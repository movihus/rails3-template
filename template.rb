# This was template was borrowed from http://github.com/leshill/rails3-app/raw/master/app.rb
# 
#  TODO:
#   * create a new generator that gets downloaded into lib/generators, where we call after app is built
#     and it sets up all the remaining dependencies, including setting up devise, and running tests.
#
#   * setup up a default controller to handle root action (possibly create new account/signin)
#
#   * look into setting up on heroku, staging and production environment
#
#   * include Tim's SASS templates
#
#   * create a public layout, and add more common elements to the layout such as flash messages.    
#
#   * might need to supply a FormBuilder, since Formtastic isn't Rails3 ready (but we should try using it first)
#
#   * add files to .gitignore, must come before other git steps
#
#   * Google Fonts???
#
#   * Look at including http://github.com/himmel/html5-boilerplate
#
# Graeme Nelson, 2010

# If we are running rvm, lets create a new gemset based on 
# the application name and gets set when ever we cd into
# the directory.  This information is store in a .rvmrc 
# file in the application root directory.
rvmrc = <<-RVMRC
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name}
RVMRC

create_file ".rvmrc", rvmrc
                              
# Remove unnecessary files that rails creates for us.
remove_file     "public/index.html"
remove_file     "public/images/rails.png"
remove_file     "public/javascripts"
empty_directory "public/javascripts"
create_file     "public/javascripts/application.js"

# Let's setup our gems used in all environments
gem "haml", ">= 3.0.18"
gem "haml-rails"
gem "devise", ">= 1.1.3"
gem 'formtastic', ">= 1.1.0"

# Let's setup the gems we only need for testing
gem "shoulda", ">= 2.11.2", :group => :test
gem "factory_girl_rails", ">= 1.0.0", :group => :test
gem "mocha", ">= 0.9.8", :group => :test 

# add cover_me to the test/test_helper.rb, if we add more things to the test_helper.rb
# we might want to consider overwriting the file since there isn't much in the default
# version.
# gsub_file("test/test_helper.rb", "require 'rails/test_help'", "require 'rails/test_help'\nrequire 'cover_me'")

# Let's get the generators we want from rails generator, factory_girl, shoulda
git :clone => "--depth 0 git://github.com/indirect/rails3-generators.git"
empty_directory "lib"
run             "cp -r rails3-generators/lib/generators lib"
remove_file     "rails3-generators"

generators_to_keep = %w(factory_girl formtastic helpers jquery shoulda)
Dir["lib/generators/*"].each do |file|
  basename = File.basename(file, ".rb")
  remove_file file unless generators_to_keep.include?( basename )
end


# Let's checkout the bootstrapping generator
git :clone => "--depth 0 git://github.com/graemenelson/rails3-template.git"
run "cp -r rails3-template/bootstrap* lib/generators"
remove_file "rails3-template"                        

# let's get rid of any .git directory in the lib/generators
remove_dir "lib/generators/.git"


# setup the javascript
remove_file "public/javascripts/rails.js" 
get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js",  "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js", "public/javascripts/jquery-ui.js"
get "http://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

# Let's setup the generators.
# 
# Template        -- HAML
# Test Framework  -- Shoulda & Mocha
# Fixtures        -- Factory
generators = <<-GENERATORS
    
    config.generators do |g|
      g.template_engine     :haml
      g.test_framework      :shoulda, :fixture => true, :views => false      
      g.fixture_replacement :factory_girl, :dir => "test/factories"
      g.mock_with           :mocha
      
      # fallbacks
      g.fallbacks[:shoulda] = :test_unit
    end
    
    # change the default javascript to use jquery, jquery-ui, and rails        
    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ui rails)
        
GENERATORS

application generators

#
#  NOTE: need to add flash message partial, and also create a public view using the same layout
#        And any other common view stuff add here.
#
layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body{ :id => controller_name, :class => action_name }
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout
create_file "app/views/layouts/public.html.haml", layout

# Setup our GIT settings.
create_file "log/.gitkeep"
create_file "tmp/.gitkeep"    

# NOTE: need to look into staging environment with CI on Heroku, it would be nice to set this all up here.
git :init
git :add => "."


# Display the next steps.
# TODO: it would be nice if some of the steps could be included in this file, or
# have one generator that would be responsible for setting up all the other stuff.
# (maybe rails g composer:install) and just down load the generator into the lib/generator dir
docs = <<-DOCS

Run the following commands to complete the setup of #{app_name.humanize}:

% cd #{app_name}
% gem install bundler --version '>= 1.0.0'
% bundle install
% rails g bootstrap:setup <ModelName>

DOCS

log docs
  