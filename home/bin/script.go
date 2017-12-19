///bin/true && exec /usr/bin/env go run "$0" "$@"
//
// script.go is a Go program that can run itself as a shell script, as well as
// help other Go scripts to run themselves.
//
// To make your Go scripts work with this, use the following "shebang" header
// at the top of your script:
//
//	///bin/true && exec /usr/bin/env script.go "$0" "$@"
//	// vim:set ft=go:
//	package main
//
// The first line will cause your shell to run `script.go` passing the current
// filename and the rest of the command line arguments. The vim modeline comment
// may help your code editor to highlight the file as Go syntax.
package main

import (
	"crypto/rand"
	"encoding/hex"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"syscall"
)

// Version of this script.
const Version = "1.0.0"

// Command line arguments
var (
	debug   bool
	version bool
)

func init() {
	flag.BoolVar(&debug, "debug", false, "Verbose debug logging")
	flag.BoolVar(&version, "version", false, "Show version number and exit")
}

func main() {
	flag.Parse()
	if version {
		fmt.Printf("This is script.go v%s\n", Version)
		os.Exit(0)
	}

	// Parse the script name and remaining arguments.
	args := flag.Args()
	if len(args) == 0 {
		usage()
	}
	scriptName := args[0]
	argv := args[1:]

	// Verify it's a file.
	if _, err := os.Stat(scriptName); os.IsNotExist(err) {
		die("%s: not a file", scriptName)
	}

	// Make a temp file with a *.go extension
	tmpfile, err := NamedTempFile("", "script", ".go")
	if err != nil {
		die("tempfile error: %s", err)
	}
	log("scriptName: %s; tmpFile: %s", scriptName, tmpfile.Name())

	// Read the source and write it to the new file.
	src, err := ioutil.ReadFile(scriptName)
	dieIfError(err)
	_, err = tmpfile.Write(src)
	dieIfError(err)
	err = tmpfile.Close()
	dieIfError(err)

	// Catch interrupt signals to clean up the tempfile.
	interrupt := make(chan os.Signal, 2)
	signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-interrupt
		log("interrupt detected; cleaning up tempfile")
		err = os.Remove(tmpfile.Name())
		if err != nil {
			die("remove tmpfile error: %s", err)
		}
	}()

	// Finally, `go run` the script from $TMPDIR.
	goArgs := append([]string{"run", tmpfile.Name()}, argv...)
	c := exec.Command(
		"go",
		goArgs...,
	)
	c.Stdin = os.Stdin
	c.Stdout = os.Stdout
	c.Stderr = os.Stderr
	err = c.Run()
	if err != nil {
		fmt.Printf("[script.go] script error: %s\n", err)
	}

	log("cleaning up tempfile")
	os.Remove(tmpfile.Name())
}

// handler for Ctrl-C cleaning up the temp file.
func cleanup() {
	fmt.Println("cleanup")
}

// NamedTempFile is like ioutil.TempFile but accepts a suffix too.
func NamedTempFile(dir, prefix, suffix string) (f *os.File, err error) {
	if dir == "" {
		dir = os.TempDir()
	}

	// Random string generator.
	randomString := func() string {
		randBytes := make([]byte, 16)
		rand.Read(randBytes)
		return hex.EncodeToString(randBytes)
	}

	for i := 0; i < 10000; i++ {
		name := filepath.Join(dir, prefix+randomString()+suffix)
		f, err = os.OpenFile(name, os.O_RDWR|os.O_CREATE|os.O_EXCL, 0600)
		if os.IsExist(err) {
			continue
		}
		break
	}

	return
}

func usage() {
	fmt.Print(
		"Usage: script.go [options] <go script path>\n",
		"See script.go -h for command line options.\n",
	)
	os.Exit(0)
}

func log(message string, v ...interface{}) {
	if debug {
		fmt.Printf("[script.go] "+message+"\n", v...)
	}
}

func die(message string, v ...interface{}) {
	fmt.Printf(message+"\n", v...)
	os.Exit(1)
}

func dieIfError(err error) {
	if err != nil {
		die(err.Error())
	}
}
