People
======

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
