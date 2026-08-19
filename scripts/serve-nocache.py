"""Static file server that never lets the browser cache.

Verification runs load the same URLs over and over while the files underneath
are still being edited; the default http.server sends cacheable responses, so a
stale module can make a fixed screen look broken (or a broken one look fixed).
"""
import functools
import sys
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler


class NoCacheHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8018
    directory = sys.argv[2] if len(sys.argv) > 2 else 'shedrive-web'
    handler = functools.partial(NoCacheHandler, directory=directory)
    print(f'serving {directory} on http://localhost:{port} (no-store)')
    # Threading: a page opens several keep-alive connections at once and a
    # single-threaded server would deadlock waiting on the first.
    ThreadingHTTPServer(('127.0.0.1', port), handler).serve_forever()
