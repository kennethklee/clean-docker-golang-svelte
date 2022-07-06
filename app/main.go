package main

import (
	"fmt"
	"net/http/httputil"
	"net/url"
	"os"

	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
)

var VERSION = "development"
var app = gin.Default()

func init() {
	app.GET("/ping", func(context *gin.Context) {
		context.JSON(200, gin.H{"status": "ok"})
	})

	// reverse proxy to 3000 if running in debug mode
	if os.Getenv("APP_ENV") == "development" {
		fmt.Println("[debug] reverse proxy to web:3000")
		gin.SetMode(gin.DebugMode)
		app.NoRoute(proxy("http://web:3000"))
	} else {
		// Serve files from ./static (built with vite)
		gin.SetMode(gin.ReleaseMode)
		app.Use(static.ServeRoot("/", "static"))
	}
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
	fmt.Println("running", os.Getenv("APP_ENV"), "app verion:", VERSION)
	app.Run(":3000")
}
