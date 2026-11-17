#!/usr/bin/env python3
"""
HTTP server with aggressive no-cache headers for instant web testing verification.
"""
import http.server
import socketserver
import sys
import os

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

def run(port=8080, directory=None):
    if directory is None:
        directory = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'build', 'web')
    
    os.chdir(directory)
    handler = NoCacheHTTPRequestHandler
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", port), handler) as httpd:
        print(f"Serving {directory} at http://localhost:{port} (Cache-Control: no-cache)")
        sys.stdout.flush()
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    run(port)
