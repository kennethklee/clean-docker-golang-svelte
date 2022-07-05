package main

import (
	"fmt"
	"net/http/httputil"
	"net/url"
	"os"

	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
)

var VERSION = "dev"
var app = gin.Default()

func init() {
	app.GET("/ping", Ping)

	// reverse proxy to 3000 if running in debug mode
	if os.Getenv("GIN_MODE") == "debug" {
		fmt.Println("DEBUG MODE: reverse proxying UI to web:3000")
		app.NoRoute(proxy("http://web:3000"))
	} else {
		// Serve files from ./static (built with vite)
		app.Use(static.ServeRoot("/", "static"))
	}
}

func Ping(context *gin.Context) {
	context.JSON(200, gin.H{"status": "ok"})
}

// Reverse proxy handler
func proxy(host string) gin.HandlerFunc {
	return func(c *gin.Context) {
		remote, _ := url.Parse(host)
		proxy := httputil.NewSingleHostReverseProxy(remote)
		proxy.ServeHTTP(c.Writer, c.Request)
	}
}

func main() {
	app.Run(":3000")
}
