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

func main() {
	router := gin.Default()

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	// handle get_compute_engine requests
	router.POST("/get_compute_engines", getInstances)

	// handle
	router.POST("/set_state", setState)

	// listen and serve on 0.0.0.0:8080
	router.Run()
}

// Tries to authenticate to GCP Console using a supplied service account json key file
// If authentication is successfull a client Object will be returned, if not
// a error will be thrown.
func authToGCP(c *gin.Context) (*compute.InstancesClient, error) {

	//try binding post body message to AuthMessage struct
	msg := AuthMessage{}
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest,
			gin.H{
				"error":   "Validation",
				"message": "Invalid inputs. Please check your inputs"})
	}

	authMessage = msg
	jsonPayload, err := json.Marshal(msg)
	if err != nil {
		return nil, errors.New("Authentication using the supplied json token failed: " + err.Error())
	}

	//auth towards GCP
	ctx = context.Background()
	client, err := compute.NewInstancesRESTClient(ctx, option.WithCredentialsJSON(jsonPayload))
	if err != nil {
		return nil, errors.New("Authentication using the supplied json token failed: " + err.Error())
	}
	return client, nil
}

// Queries all zones for instances in project used in json key file
func getInstances(context *gin.Context) {
	client, err := authToGCP(context)
	if err != nil {
		context.JSON(401, gin.H{
			"message": err.Error(),
		})
	}

	defer client.Close()

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
				"message": err.Error(),
			})
		}
		_ = resp
	}

	context.JSON(200, gin.H{
		"result": instances.Response,
	})
}

func setState(context *gin.Context) {
	client, err := authToGCP(context)
	if err != nil {
		context.JSON(401, gin.H{
			"message": err.Error(),
		})
	}

	instanceName := context.Query("name")
	desiredState := context.Query("state")
	zone := context.Query("zone")

	println(instanceName)
	println(desiredState)

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
		"status": "State of " + instanceName + " changed to " + desiredState,
	})

}

// Await completion of get aggregated list of instances and return the result in a channel
func awaitList(client *compute.InstancesClient, ctx context.Context, c chan *compute.InstancesScopedListPairIterator) {
	req := &computepb.AggregatedListInstancesRequest{
		Project: authMessage.Project_Id,
	}
	c <- client.AggregatedList(ctx, req)
}

//TODO fix error handling
