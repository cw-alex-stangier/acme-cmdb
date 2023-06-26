package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthMessage struct {
	Type                        string `json:"type"`
	Project_Id                  string `json:"project_id"`
	Private_Key_Id              string `json:"private_key_id"`
	Private_Key                 string `json:"private_key"`
	Client_Email                string `json:"client_email"`
	Client_Id                   string `json:"client_id"`
	Auth_Uri                    string `json:"auth_uri"`
	Token_Uri                   string `json:"token_uri"`
	Auth_Provider_X509_Cert_Url string `json:"auth_provider_x509_cert_url"`
	Client_X509_Cert_Url        string `json:"client_x509_cert_url"`
	Universe_Domain             string `json:"universe_domain"`
}

func main() {
	router := gin.Default()

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	// mirror post auth request back
	router.POST("/get_compute_engines", getInstances)

	// listen and serve on 0.0.0.0:8080
	router.Run()
}

func getInstances(context *gin.Context) {
	//id := context.Query("id")

	//TODO add branching for explicit id
	msg := AuthMessage{}

	if err := context.ShouldBindJSON(&msg); err != nil {
		context.AbortWithStatusJSON(http.StatusBadRequest,
			gin.H{
				"error":   "Validation",
				"message": "Invalid inputs. Please check your inputs"})
		return
	}
	context.JSON(200, &msg)
}
