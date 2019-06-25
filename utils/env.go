package utils

import "os"

// Get Environment Variables or default value
func Getenv(key string, def string) string {
	env := os.Getenv(key)
	if len(env) == 0 {
		return def
	} else {
		return env
	}
}
