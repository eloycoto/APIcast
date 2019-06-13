import SimpleHTTPServer
import SocketServer
from time import sleep

PORT = 5000
SLEEP_TIME = 6


class SlowHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        sleep(SLEEP_TIME)
        SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

Handler = SlowHandler
httpd = SocketServer.TCPServer(("", PORT), Handler)

print "serving at port", PORT
httpd.serve_forever()
