///bin/true && exec /usr/bin/env script.go "$0" "$@"
// vim:set ft=go:
package main

// SimpleHTTPServer is a simple Go static file server, similar to the Python
// module of the same name, but which supports high concurrency and all the
// other niceties that you get from Go out of the box.
//
// It runs via my `gosh` wrapper for treating simple Go programs as shell
// scripts. See my `gosh` script, or just remove the shebang line at the top
// of this file to `go build` your own version.

import (
	"encoding/base64"
	"flag"
	"fmt"
	"log"
	"net/http"
	"regexp"
	"strings"
)

// Regular expression for the user:passwd format for HTTP Basic Auth (-auth)
var HTTPAuthRegexp = regexp.MustCompile(`^([A-Za-z0-9_]+?):(.+?)$`)

// If using HTTP Basic Auth, the username and password.
var HTTPAuthUsername string
var HTTPAuthPassword string

// LogMiddleware logs all HTTP requests.
func LogMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Using HTTP Basic Auth?
		if len(HTTPAuthUsername) > 0 {
			if !checkAuth(w, r) {
				w.Header().Set("WWW-Authenticate", `Basic realm="SimpleHTTPServer"`)
				w.WriteHeader(401)
				w.Write([]byte("401 Unauthorized\n"))
				return
			}
		}

		res := &ResponseWriter{w, 200}
		next.ServeHTTP(res, r)
		log.Printf("%s %d %s %s\n",
			r.RemoteAddr,
			res.Status,
			r.Method,
			r.RequestURI,
		)
	})
}

// checkAuth handles HTTP Basic Auth checking.
func checkAuth(w http.ResponseWriter, r *http.Request) bool {
	s := strings.SplitN(r.Header.Get("Authorization"), " ", 2)
	if len(s) != 2 {
		return false
	}

	b, err := base64.StdEncoding.DecodeString(s[1])
	if err != nil {
		return false
	}

	pair := strings.SplitN(string(b), ":", 2)
	if len(pair) != 2 {
		return false
	}

	return pair[0] == HTTPAuthUsername && pair[1] == HTTPAuthPassword
}

// ResponseWriter is my own wrapper around http.ResponseWriter that lets me
// capture its status code, for logging purposes.
type ResponseWriter struct {
	http.ResponseWriter
	Status int
}

// WriteHeader wraps http.WriteHeader to also capture the status code.
func (w *ResponseWriter) WriteHeader(code int) {
	w.ResponseWriter.WriteHeader(code)
	w.Status = code
}

func main() {
	// Command line flag: the port number to listen on.
	host := flag.String("host", "0.0.0.0", "The host address to listen on.")
	port := flag.Int("port", 8000, "The port number to listen on.")
	auth := flag.String("auth", "", "Use HTTP Basic Authentication. The "+
		"auth string should be in `user:passwd` format.")
	flag.Parse()

	// If using HTTP authentication...
	if len(*auth) > 0 {
		m := HTTPAuthRegexp.FindStringSubmatch(*auth)
		if len(m) == 0 {
			log.Panicf("The -auth parameter must be in user:passwd format.")
		}
		HTTPAuthUsername = m[1]
		HTTPAuthPassword = m[2]
	}

	fmt.Printf("Serving at http://%s:%d/\n", *host, *port)
	err := http.ListenAndServe(
		fmt.Sprintf("%s:%d", *host, *port),
		LogMiddleware(http.FileServer(http.Dir("."))),
	)
	panic(err)
}
