# Drupal lando dev site creator

This project enables linux/ubuntu users to quickly set up a local Drupal development site using lando. This makes it super quick and easy to set up and configure a local Drupal site (4 mins aprox). 

This is done using a bash script which uses composer (composer create-project drupal/recommended-project), bash sed commands, lando and drush. The script asks a number of questions before automatically setting up the site for you. 

This is a personal project based on automating the steps in this article.. https://matti.dev/post/setup-install-drupal-9-with-composer-and-drush. I'm sharing with others in case it saves someone some time.

The script installs and enables a few drupal modules that I have found useful in local development. These are admin_toolbar, admin_toolbar_tools, media, media_library, layout_builder, token, devel, and devel_generate. You may want to customise it yourself so it has the modules you want enabled. 

Please note that I have only tested this on Ubuntu/Pop_OS, also you will need to have installed composer and lando on your machine before you begin. 

Also be aware that you should pick a version of PHP that works with your version of Drupal other wise you will get errors. 

At the moment a drupal 10 install installs the latest version of drush and a drupal 9 install uses the earlier drush: version 11.5.1. I would like to do more work on this in the future.

I would also like to auto list the drupal versions (including dev and minor versions), rather than have it hard coded.

To use .. download/clone the D.sh file, set the permissions so it can execute (chmod). Move the file to a location where you want your new site to be and run it (bash D.sh). You may have to click y when prompted (cweagans/composer-patches related prompt for example). After the script has run change directory (cd) to the new site folder.

Useful links:

https://matti.dev/post/setup-install-drupal-9-with-composer-and-drush
https://docs.lando.dev/

