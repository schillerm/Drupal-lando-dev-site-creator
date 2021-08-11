#!/bin/bash


red="\e[0;91m"
green="\e[0;92m"
blue="\e[0;94m"

reset="\e[0m"

clear
echo -e "${red}Drupal 9 dev site creator${reset}"

while true; do
    read -p "
This script creates a new Drupal 9 site and sets it up for development using composer and lando. It's designed to run on Ubuntu / Pop os 20, I have not tested it on Mac os. Before you begin you will need composer (https://getcomposer.org/) and lando (https://lando.dev/) installed. You should run this script in the directory where you want the new site to go.
    
You are currenly here .. $PWD. 

Please be aware that this script installs and enables some contrib modules (admin_toolbar, token, devel, composer-patches and config_direct_Save). It also installs and enables drush and drupal console. Some settings are altered (debugging and caching etc) to make theming and module development easier. The set up is similar to what's described here - https://matti.dev/post/setup-install-drupal-9-with-composer-and-drush

Are you ready to begin? (yes/no) [yes] : " yn
    yn=${yn:-yes}
    case $yn in
        [Yesyes]* ) break;;
        [Nono]* ) echo -e "Ok come back when you are ready."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

clear
echo -e "${blue}Creating new D9 dev site : please provide details${reset}"

read -p 'Sitename [Dev]: ' sitename
sitename=${sitename:-Dev}
clear
echo -e "${blue}Creating new D9 dev site : please provide details${reset}"
echo -e "Sitename : ${red}$sitename${reset}"
read -p "Username [Admin]: " username
username=${username:-Admin}

clear
echo -e "${blue}Creating new D9 dev site : please provide details${reset}"
echo -e "Sitename : ${red}$sitename${reset}"
echo -e "Username : ${red}$username${reset}"

while true; do
    read -p 'Email: ' email
    if [ -z "$email" ]; then
     echo "Please enter an email address!";
    else
     break;
    fi  
done

clear
echo -e "${blue}Creating new D9 dev site : please provide details${reset}"
echo -e "Sitename : ${red}$sitename${reset}"
echo -e "Username : ${red}$username${reset}"
echo -e "Email : ${red}$email${reset}"


while true; do
    read -p 'Password: ' password
    if [ -z "$password" ]; then
     echo "Please enter a password!";
    else
     break;
    fi  
done



version="drupal9"

# Create drupal project 
composer create-project drupal/recommended-project $sitename

# Change to new root directory
cd $sitename

# Add patches and config directorys
mkdir patches
mkdir config

# Create lando init file
lando init \
  --source cwd \
  --recipe $version \
  --webroot web \
  --name $sitename

# Add extra bits to .lando.yml file
sed -i "$ a\  xdebug: true\ntooling:\n  drush:\n    service: appserver\n    env:\n       DRUSH_OPTIONS_URI: "https://$sitename.lndo.site"\n  drupal:\n    service: appserver\n    cmd: "/app/vendor/drupal/console/bin/drupal"\nservices:\n appserver:\n  build:\n   - composer install" .lando.yml

# Start lando
lando start

# Install drush and other useful modules
lando composer require drush/drush
lando composer require drupal/admin_toolbar
lando composer require drupal/token
lando composer require drupal/devel
lando composer require kint-php/kint
lando composer require drupal/devel_kint_extras
lando composer require cweagans/composer-patches
lando composer require drupal/config_direct_save
lando composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader --sort-packages --no-update


# Update composer
lando composer update

# Install Drupal using Lando details
lando drush si standard \
  --db-url='mysql://drupal9:drupal9@database:3306/drupal9' -y \
  --account-name=Admin --account-pass=$password \
  --site-name=$sitename \
  --site-mail=$email \

echo "Drupal site installed !"

# Enable custom modules
lando drush en admin_toolbar
lando drush en admin_toolbar_tools
lando drush en media
lando drush en media_library
lando drush en layout_builder -y
lando drush en token
lando drush en devel
lando drush en devel_kint_extras
lando drush en devel_generate
lando drush en config_direct_save

# Clear the cache
lando drush cr

# Add recommended drupal 9 gitignore file 
curl -o .gitignore 'https://raw.githubusercontent.com/drupal/drupal/9.2.x/example.gitignore'

# Change .gitignore permissions
chmod 644 .gitignore

# Add extra line to .gitignore about settings.local.php
sed -i "30a # Ignore configuration files that may contain sensitive information.\n/web/sites/*/settings/settings.local.php\n" .gitignore

# Adjust settings files and folders settings
chmod +w web/sites/default
mkdir web/sites/default/settings
cd web/sites/default
cp settings.php settings/settings.shared.php
chmod 644 settings/settings.shared.php
chmod 644 settings.php

# Trusted host settings to settings.php
sed -i "717a \$settings['trusted_host_patterns'] = [\n   '^localhost$',\n   '^lando.site$',\n   '^.*\.lando\.site$',\n   ];" settings.php

# Changes to settings.php file
# Empty the file
cp /dev/null settings.php
# Add reference to shared settings file
printf "<?php\n\n include __DIR__ . '/settings/settings.shared.php';" >> settings.php;

# Add trusted host patterns to settings.shared.php
sed -i "717a \$settings['trusted_host_patterns'] = [\n   '^localhost$',\n   '^lando.site$',\n   '^.*\.lando\.site$',\n   ];" settings/settings.shared.php

sed -i "$ a if (file_exists(\$app_root . '/' . \$site_path . '/settings/settings.local.php')) {\n  include \$app_root . '/' . \$site_path . '/settings/settings.local.php';\n}" settings/settings.shared.php

# Create local settings file
cd ../..
cp sites/example.settings.local.php sites/default/settings/settings.local.php

# Move into the settings folder
cd sites/default/settings

# Add database settings to settings.local file
sed -i "$ a \$databases\['default'\]\['default'\] = array (\n  'database' => '$version',\n  'username' => '$version',\n  'password' => '$version',\n  'prefix' => '',\n  'host' => 'database',\n  'port' => '3306',\n  'namespace' => 'Drupal\\\\\\\Core\\\\\\\Database\\\\\\\Driver\\\\\\\mysql',\n  'driver' => 'mysql',\n);\n" settings.local.php

# Comment out DB settings in settings.shared.php
sed -e "/\$databases/ s/^#*/#/" -i settings.shared.php
sed -e "/  'database' => 'drupal9',/ s/^#*/#/" -i settings.shared.php
sed -e "/  'username' => 'drupal9',/ s/^#*/#/" -i settings.shared.php
sed -e "/  'password' => 'drupal9',/ s/^#*/#/" -i settings.shared.php
sed -e "/  'prefix' => '',/ s/^#*/#/" -i settings.shared.php
sed -e "/  'host' => 'database',/ s/^#*/#/" -i settings.shared.php
sed -e "/  'port' => '3306',/ s/^#*/#/" -i settings.shared.php
sed -e "/  'namespace' => 'Drupal/ s/^#*/#/" -i settings.shared.php
sed -e "/  'driver' => 'mysql',/ s/^#*/#/" -i settings.shared.php
sed -e "/);/ s/^#*/#/" -i settings.shared.php

# Uncommenting lines so that that we disable caching and enable logging
sed -ie '100s/^.//' settings.local.php
sed -ie '91s/^.//' settings.local.php
sed -ie '69s/^.//' settings.local.php

# Changes to development.services file.. 
cd ../../

# Empty the file
cp /dev/null development.services.yml

# Set up developement services file
printf "parameters:\n  http.response.debug_cacheability_headers: true\n  twig.config:\n   debug: true\n   auto_reload: true\nservices:\n  cache.backend.null:\n    class: Drupal\\Core\\Cache\\NullBackendFactory" >> development.services.yml;

# Change composer.json so that development.services.yml is not overwritten when site is rebuilt
cd ../../
sed -i '42i \            },\n            "file-mapping": {\n                "[web-root]/sites/development.services.yml": false,' composer.json

# Clear the cache
lando drush cr

# Give files directory and settings.php the right permissions
cd web/sites
chmod go-w default/settings.php
chmod go-w default








