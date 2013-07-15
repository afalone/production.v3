set :application, "production.rails.v3"
set :repository,  "https://svn.ddc-media.ru:443/production.rails.v3/trunk"

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "production.ddc-media.ru"                          # This may be the same as your `Web` server
role :db,  "production.ddc-media.ru", :primary => true # This is where Rails migrations will run
role :p2f, "192.168.225.40", "192.168.225.41", "192.168.225.42", "192.168.225.43", "192.168.225.44", "192.168.225.45", "192.168.225.91", "192.168.225.92",
role :locklizard, "192.168.225.22"




# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
require 'config/boot'
require 'hoptoad_notifier/capistrano'
