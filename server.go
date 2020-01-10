package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

// TODO: move to utils
func strcat(strs ...string) string {
	var sb strings.Builder
	for _, str := range strs {
		sb.WriteString(str)
	}
	return sb.String()
}

// TODO: move to utils
func getenv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func buildCORSHandler(routers *mux.Router) http.Handler {
	corsHeaders := handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type", "Authorization"})
	corsMethods := handlers.AllowedMethods([]string{"GET", "POST", "PUT", "HEAD", "OPTIONS"})
	corsOrigins := handlers.AllowedOrigins([]string{"*"})
	cors := handlers.CORS(corsHeaders, corsMethods, corsOrigins)(routers)
	return cors
}

func serve(handler http.Handler) error {
	bind := getenv("LISTEN_ADDR", "0.0.0.0")
	port := getenv("LISTEN_PORT", "8080")
	listen := strcat(bind, ":", port)
	fmt.Printf("Binding to address - %s\n", listen)
	fmt.Println("Listening and Serving")

	return http.ListenAndServe(listen, handler)
}

// need to handle 404s better
func buildRouters() *mux.Router {
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.HandleFunc("/api/v1/login", login).Methods("POST")
	myRouter.HandleFunc("/api/v1/register", register).Methods("POST")
	myRouter.HandleFunc("/api/v1/code", register).Methods("POST")
	return myRouter
}

func buildHandler(router *mux.Router) http.Handler {
	return buildCORSHandler(router)
}

// TODO: clean this up, add graceful shutdown
func handleRequests() {
	fmt.Println("Rest API v1.0 - CodeComp")
	fmt.Println("Building Routers")
	myRouters := buildRouters()
	fmt.Println("Building Handlers")
	handler := buildHandler(myRouters)
	// routers := routers.Init()
	log.Fatal(serve(handler))
}

func main() {
	handleRequests()
}

func register(w http.ResponseWriter, r *http.Request) {
	fmt.Println("you just hit this endpoint yo")
	reqBody, _ := ioutil.ReadAll(r.Body)
	fmt.Println("request body", string(reqBody))
	fmt.Fprintf(w, "%+v", string(reqBody))
}

func login(w http.ResponseWriter, r *http.Request) {
	fmt.Println("you just hit this endpoint yo")
	reqBody, _ := ioutil.ReadAll(r.Body)
	fmt.Println("request body", string(reqBody))
	fmt.Fprintf(w, "%+v", string(reqBody))
}

func runCode(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)

	fmt.Println("you just hit this endpoint yo")
	reqBody, _ := ioutil.ReadAll(r.Body)
	fmt.Println("request body", string(reqBody))
	fmt.Fprintf(w, "%+v", string(reqBody))
}
