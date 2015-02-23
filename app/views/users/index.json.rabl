collection @users

cache "users_#{User.cache_key}", @users

extends "users/base"
extends "users/extra_info"
