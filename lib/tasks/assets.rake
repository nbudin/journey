require 'sprite_factory'

namespace :assets do
  desc 'recreate sprite images and css'
  task :resprite => :environment do 
    SpriteFactory.style = "scss"
    SpriteFactory.selector = ".icon.icon-"
    SpriteFactory.cssurl = "image-url('$IMAGE')"    # use a sass-rails helper method to be evaluated by the rails asset pipeline
    SpriteFactory.run!('app/assets/images/icon',   :output_style => 'app/assets/stylesheets/icons.css.scss')
  end
end