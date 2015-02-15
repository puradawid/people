collection @users

cache "available_users_#{User.cache_key}", @users

extends "available_users/base"
extends "available_users/extra_info"
