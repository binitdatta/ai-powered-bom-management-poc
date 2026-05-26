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


def post_fork(server, worker):
    """Reconfigure audit logging in each worker process after fork."""
    import logging
    import os

    log_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs")
    os.makedirs(log_dir, exist_ok=True)
    log_path = os.path.join(log_dir, "anthropic_audit.log")

    formatter = logging.Formatter(
        "%(asctime)s  %(levelname)-8s  %(name)s\n%(message)s\n"
        "----------------------------------------------------------------------"
    )

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(formatter)

    file_handler = logging.FileHandler(log_path)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    audit_logger = logging.getLogger("anthropic.audit")
    audit_logger.setLevel(logging.DEBUG)
    audit_logger.handlers.clear()   # drop any handlers inherited from master
    audit_logger.addHandler(console_handler)
    audit_logger.addHandler(file_handler)
    audit_logger.propagate = False