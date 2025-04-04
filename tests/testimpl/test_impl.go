package common

import (
	"context"
	"io"
	"net/http"
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestStorageAccount(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	options := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}

	storageAccountClient, err := armstorage.NewAccountsClient(subscriptionId, credential, &options)
	if err != nil {
		t.Fatalf("Error getting Storage Account client: %v", err)
	}

	t.Run("DoesStorageAccountExist", func(t *testing.T) {
		resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
		storageAccountName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")

		storageAccount, err := storageAccountClient.GetProperties(context.Background(), resourceGroupName, storageAccountName, nil)
		if err != nil {
			t.Fatalf("Error getting storage account: %v", err)
		}

		assert.Equal(t, getStorageAccountName(*storageAccount.Name), strings.Trim(getStorageAccountName(storageAccountName), "]"))
	})

	t.Run("RequestDefaultIndexFromStaticWebsiteStorageAccount", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "static_website")
		webEndpoint := terraform.Output(t, ctx.TerratestTerraformOptions(), "web_endpoint")

		resp, err := http.Get(webEndpoint)
		if err != nil {
			t.Errorf("Failure during HTTP GET: %v", err)
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Errorf("Failure reading Body: %v", err)
		}

		assert.Contains(t, string(body), "<h1>Example Storage Account Website</h1>", "Body did not contain expected response!")
	})
}

func getStorageAccountName(input string) string {
	parts := strings.Split(input, "/")
	return parts[len(parts)-1]
}
