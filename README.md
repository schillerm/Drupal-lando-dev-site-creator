# Drupal 9 lando dev site creator

This project enables linux/ubuntu users to quickly set up a local Drupal 9 development site using composer and lando. This makes it super quick and easy to set up and configure a local Drupal 9 site (2 mins aprox). This means you can try quickly stuff out on a test Drupal 9 sites without spending time configuring and setting everything up the way you want.

This is done using a bash script which uses composer (composer create-project drupal/recommended-project), bash sed commands, lando and drush. The script asks a number of questions before automatically setting up the site for you. 

This is a personal project based on automating the steps in this article.. https://matti.dev/post/setup-install-drupal-9-with-composer-and-drush. I'm sharing with others in case it saves someone some time.

The script installs and enables a few drupal modules that I have found useful in local development. These are admin_toolbar, admin_toolbar_tools, media, media_library, layout_builder, token, devel, devel_kint_extras, devel_generate, and config_direct_save. You may want to customise it yourself so it has the modules you want enabled. 

I hope to make changes to it so that the drupal config is handled differently in the future. Please note that I have only tested this on Ubuntu/Pop_OS 20, also you will need to have installed composer and lando on your machine before you begin.

Useful links:

https://matti.dev/post/setup-install-drupal-9-with-composer-and-drush
https://docs.lando.dev/
https://docs.lando.dev/config/drupal9.html

