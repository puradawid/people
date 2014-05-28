People
======

##About the app

The main purpose of the app is to manage people within the projects. 

The main table shows the current teams in each project, but you can also add people who will start working on the project in the future, and see the people who are going to join or leave the project team by clicking “highlight ending” and “highlight next”. The app also gathers the information about a team member, like role, telephone number, github nick, or the city in which we work.

![People_View](https://netguruco-production.s3.amazonaws.com/uploads/1401228321-people_main.jpg)

##MongoDB OSX installation:

```shell
  brew update
  brew install mongodb
```

## Dev auth setup

### Google Auth

  * goto [https://cloud.google.com/console](https://cloud.google.com/console)
  * create new project
  * choose credentials tab (on the left)
  * create both new client id
  * choose web application
  * set `Authorized JavaScript origins` to `http://localhost:3000`
  * set `Authorized redirect URI` to `http://localhost:3000/users/auth/google_oauth2/callback`
  * goto next tab "Consent screen"
  * fill in "Email address" and "Product name" and save

### Github Auth

  * do the same for github account (callback address is `http://localhost:3000/users/auth/github/callback`)

### Local settings

All the required app settings are located in `config/config.yml` file.

Get started: https://devcenter.heroku.com/articles/getting-started-with-rails4

Copyright (c) 2014 [Netguru](https://netguru.co). See LICENSE for further details.
