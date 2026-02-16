package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type Order struct {
	ID     int    `json:"id"`
	User   string `json:"user"`
	Status string `json:"status"`
}

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]string{
			"message": "Order Service is running 🚀",
		})
	})

	http.HandleFunc("/orders", func(w http.ResponseWriter, r *http.Request) {
		orders := []Order{
			{ID: 1, User: "Alice", Status: "shipped"},
			{ID: 2, User: "Bob", Status: "processing"},
		}
		json.NewEncoder(w).Encode(orders)
	})

	log.Println("Order Service listening on port 8003")
	log.Fatal(http.ListenAndServe(":8003", nil))
}
