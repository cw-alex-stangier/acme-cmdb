package auth

import (
	"context"
	"errors"

	compute "cloud.google.com/go/compute/apiv1"
	"google.golang.org/api/option"
)

func authToGCP(authFile string) any {
	ctx := context.Background()
	client, err := compute.NewInstancesRESTClient(ctx, option.WithCredentialsFile(authFile))
	if err != nil {
		return errors.New("Authentication using the supplied json token failed: " + err.Error())
	}
	return client
}
