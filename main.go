// GCP REST Services for ACME CMDB
package main

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	compute "cloud.google.com/go/compute/apiv1"
	computepb "cloud.google.com/go/compute/apiv1/computepb"
	"github.com/gin-gonic/gin"
	"google.golang.org/api/iterator"
	"google.golang.org/api/option"
)

// AuthMessage struct serves to represent a Service Account JSON Keyfile
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

var authMessage AuthMessage
var ctx context.Context

// @title						Swagger ACME CMDB GCP API
// @version					1.0
// @description				GCP REST Services for ACME CMDB.
// @BasePath					/
// @externalDocs.description	OpenAPI
// @externalDocs.url			https://swagger.io/resources/open-api/
func main() {
	router := gin.Default()
	gin.SetMode(gin.ReleaseMode)

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	//router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	// handle get_compute_engine requests
	router.POST("/get_compute_engines", getInstances)

	// handle desired state changes
	router.POST("/set_state", setState)

	// listen and serve on 0.0.0.0:8080
	router.Run()
}

// Tries to authenticate to GCP Console using a supplied seco
func authToGCP(c *gin.Context) (*compute.InstancesClient, error) {

	//try binding post body message to AuthMessage struct
	msg := AuthMessage{}
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest,
			gin.H{
				"error":   "Validation",
				"message": "Invalid inputs. Please check your json key file."})
	}

	authMessage = msg
	jsonPayload, err := json.Marshal(msg)
	if err != nil {
		return nil, errors.New("JSON Key file couldn't be marshalled, please make sure its well formed : " + err.Error())
	}

	//auth towards GCP
	ctx = context.Background()
	client, err := compute.NewInstancesRESTClient(ctx, option.WithCredentialsJSON(jsonPayload))
	if err != nil {
		return nil, errors.New("Authentication using the supplied json token failed: " + err.Error())
	}
	return client, nil
}

// @Title			List Compute Engines
// @Version		1.0
// @Description	Queries all zones for instances in project used in json key file.
// @Description	Needs a service worker JSON Key file to authenticate inside the Body.
// @BasePath		/get_compute_engines
// @accept			json
// @produce		json
func getInstances(context *gin.Context) {
	client, err := authToGCP(context)
	if err != nil {
		context.JSON(401, gin.H{
			"message": "Failed to authenticate to GCP: " + err.Error(),
		})
	}

	defer client.Close()

	// pretty print json
	responseChannel := make(chan *compute.InstancesScopedListPairIterator)
	go awaitList(client, ctx, responseChannel)
	instances := <-responseChannel

	for {
		resp, err := instances.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			context.JSON(401, gin.H{
				"message": "Internal error iterating result set: " + err.Error(),
			})
		}
		_ = resp
	}

	context.JSON(200, gin.H{
		"result": instances.Response,
	})
}

// @Title			Change State of Compute Engines
// @Version		1.0
// @Description	Tries to set the desired state on a supplied instance in a supplied zone.
// @Description	Needs a service worker JSON Key file to authenticate inside the Body.
// @BasePath		/set_state
// @Param			name	query	string	true	"string default"	default(A)
// @Param			zone	query	string	true	"string default"	default(A)
// @accept			json
// @produce		json
func setState(context *gin.Context) {
	client, err := authToGCP(context)
	if err != nil {
		context.JSON(401, gin.H{
			"message": "Failed to authenticate to GCP: " + err.Error()})
	}

	instanceName := context.Query("name")
	desiredState := strings.ToLower(context.Query("state"))
	zone := context.Query("zone")

	supportedSates := []string{"start", "stop"}

	if contains(supportedSates, desiredState) {

		defer client.Close()

		var op *compute.Operation
		var errState error

		if strings.EqualFold("Start", desiredState) {
			req := &computepb.StartInstanceRequest{
				Instance: instanceName,
				Project:  authMessage.Project_Id,
				Zone:     zone,
			}

			op, errState = client.Start(ctx, req)
			if errState != nil {
				context.JSON(500, gin.H{
					"message": "Error occured while starting:" + errState.Error(),
				})
			}
		}
		if strings.EqualFold("Stop", desiredState) {
			req := &computepb.StopInstanceRequest{
				Instance: instanceName,
				Project:  authMessage.Project_Id,
				Zone:     zone,
			}

			op, errState = client.Stop(ctx, req)
			if errState != nil {
				context.JSON(500, gin.H{
					"message": "Error occured while stopping:" + errState.Error(),
				})
			}
		}

		errState = op.Wait(ctx)
		if errState != nil {
			context.JSON(500, gin.H{
				"message": "Failed to change state" + errState.Error(),
			})
		}

		context.JSON(http.StatusOK, gin.H{
			"result": "State of " + instanceName + " changed to " + desiredState,
		})
	} else {
		context.JSON(http.StatusUnprocessableEntity, gin.H{
			"message": desiredState + " is not supported.",
		})
	}

}

// Await completion of get aggregated list of instances and return the result in a channel
func awaitList(client *compute.InstancesClient, ctx context.Context, c chan *compute.InstancesScopedListPairIterator) {
	req := &computepb.AggregatedListInstancesRequest{
		Project: authMessage.Project_Id,
	}
	c <- client.AggregatedList(ctx, req)
}

// contains checks if a string is present in a slice
func contains(s []string, str string) bool {
	for _, v := range s {
		if v == str {
			return true
		}
	}

	return false
}
