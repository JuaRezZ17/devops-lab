import os
import redis
from flask import Flask

app = Flask(__name__)

# We capture the environment variables injected by Docker Compose
REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))

# We establish a connection to Redis
cache = redis.Redis(host=REDIS_HOST, port=REDIS_PORT)

@app.route('/')
def hello():
    # Increment the 'visits' key in Redis each time the route is called
    visits = cache.incr('visits')
    return f"Hello! This page has been viewed {visits} times.\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)