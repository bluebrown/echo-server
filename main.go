package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		reqHeadersBytes, _ := json.Marshal(r.Header)
		text := fmt.Sprintf("RemoteAddr: %s\n", r.RemoteAddr)
		text += fmt.Sprintf("Method: %s\n", r.Method)
		text += fmt.Sprintf("RequestURI: %s\n", r.RequestURI)
		text += fmt.Sprintf("Proto: %s\n", r.Proto)
		text += fmt.Sprintf("ContentLength: %x\n", r.ContentLength)
		text += fmt.Sprintf("Headers: %s\n", string(reqHeadersBytes))
		fmt.Fprint(w, text)
	})
	log.Fatal(http.ListenAndServe(":80", nil))
}
