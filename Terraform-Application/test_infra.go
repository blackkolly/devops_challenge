package test

import (
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"net/http"
)

func TestALBEndpoint(t *testing.T) {
	t := terraform.InitAndApplyAndIdempotent(t, &terraform.Options{
		TerraformDir: "../terraform-application",
	})

	albDns := terraform.Output(t, &terraform.Options{TerraformDir: "../terraform-application"}, "alb_dns_name")
	url := "http://" + albDns

	maxRetries := 10
	delay := 10 * time.Second
	var resp *http.Response
	var err error
	for i := 0; i < maxRetries; i++ {
		resp, err = http.Get(url)
		if err == nil && resp.StatusCode == 200 {
			break
		}
		time.Sleep(delay)
	}
	assert.NoError(t, err)
	assert.Equal(t, 200, resp.StatusCode)
}
