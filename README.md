People
======

[![Code Climate](http://img.shields.io/codeclimate/github/netguru/people.svg)](https://codeclimate.com/github/netguru/people)
[![Dependencies](http://img.shields.io/gemnasium/netguru/people.svg)](https://gemnasium.com/netguru/people)

##About the app

The main purpose of the app is to manage people within the projects.

The main table shows the current teams in each project, but you can also add people who will start working on the project in the future, and see the people who are going to join or leave the project team by clicking “highlight ending” and “highlight next”. The app also gathers the information about a team member, like role, telephone number, github nick, or the city in which we work.

![People_View](https://netguruco-production.s3.amazonaws.com/uploads/1401956759-1401228321-people_main.jpg)

## System Setup
You need MongoDB and ImageMagick installed on your system, on OS X this is a simple as:
```shell
  brew update && brew install mongodb imagemagick
```

On other systems check out the official [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) and [MongoDB documentation](http://docs.mongodb.org/manual/installation/)

## Project setup

 * ```cd``` into project and ```bundle install``` to install all of the gem dependencies
 * run ```rake db:create``` & ```rake db:seed``` - it will create your database and populate it with sample data
 * this app uses Google Auth. In order to configure it, checkout section **Dev auth setup** and **Local settings**.
 * once you have authentication credentials go to config/config.yml and update your google_client_id, google_secret, google_domain, github_client_id, github_secret accordingly

### Local settings

All the required app settings are located in `config/config.yml` file.
You should put your local settings in `config/sec_config.yml` file which is not checked in version control.

Take a note that emails->internal: in `config/config.yml` should be domain used to login users eg. example.com not test@example.com

Get started: https://devcenter.heroku.com/articles/getting-started-with-rails4

### Additional Info
 * after logging in, go to your Profile's settings and update your role to 'senior' or 'pm'
 * by default only 'pm' and 'senior' roles have admin privilages - creating new projects, managing privileges, memberships etc.
 * optionally update your emails and company_name
 * after deploy run `rake team:set_fields` - it sets avatars and team colors.

## Dev auth setup

### Google Auth

  * goto [https://cloud.google.com/console](https://cloud.google.com/console)
  * create new project
  * choose API & Auth > Credentials tab (on the left)
  * create new Client Id
  * choose `web application` option
  * set `Authorized JavaScript origins` to `http://localhost:3000`
  * set `Authorized redirect URI` to `http://localhost:3000/users/auth/google_oauth2/callback`
  * goto API & Auth > Consent screen
  * fill in "Email address" and "Product name" and save

### Github Auth

  * do the same for github account (callback address is `http://localhost:3000/users/auth/github/callback`)

### Feature flags

Feature flags toggle is available at `/features`.
Admin Role is required.

### Read More

[Introducing: People. A simple open source app for managing devs within projects](https://netguru.co/blog/posts/introducing-people-a-simple-open-source-app-for-managing-devs-within-projects).

###Contributing

First, thank you for contributing!

Here a few guidelines to follow:

1. Write tests
2. Make sure the entire test suite passes
3. Make sure rubocop passes, our [config](https://github.com/netguru/hound/blob/master/config/rubocop.yml)
3. Open a pull request on GitHub
4. [Squash your commits](http://blog.steveklabnik.com/posts/2012-11-08-how-to-squash-commits-in-a-github-pull-request) after receiving feedback

Copyright (c) 2014 [Netguru](https://netguru.co). See LICENSE for further details.
