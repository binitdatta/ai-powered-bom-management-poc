"""
gunicorn.conf.py  —  Gunicorn configuration for bomiq SDM ChatBot
"""
# Binding
bind            = "0.0.0.0:5001"

# Single worker — required for session-based PKCE state to survive login→callback
# (PKCE state is stored in Flask session; multi-worker routing breaks this)
worker_class    = "gthread"
workers         = 1
threads         = 8
timeout         = 120          # allow long SSE streams

# Logging
accesslog       = "-"          # stdout
errorlog        = "-"          # stderr
loglevel        = "info"
access_log_format = '%(h)s "%(r)s" %(s)s %(b)s %(D)sµs'

# Process naming
proc_name       = "bomiq-chatbot"