from starter import settings

wsgi_app = "core.wsgi:application"

raw_env = ["DJANGO_SETTINGS_MODULE=core.settings"]

# NOTE: Bind to a socket path instead of using a network port
bind = "unix:./gunicorn.sock"

reload = settings.DEBUG
