package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/hashicorp/go-version"
	"github.com/hashicorp/hc-install/product"
	"github.com/hashicorp/hc-install/releases"
	"github.com/hashicorp/terraform-exec/tfexec"
)

type TerraformState struct {
	Version          int                    `json:"version"`
	TerraformVersion string                 `json:"terraform_version"`
	Resources        []Resource             `json:"resources"`
	Outputs          map[string]OutputValue `json:"outputs"`
}

type Resource struct {
	Type      string                   `json:"type"`
	Name      string                   `json:"name"`
	Instances []map[string]interface{} `json:"instances"`
}

type OutputValue struct {
	Value interface{} `json:"value"`
	Type  string      `json:"type"`
}

func testNginx(ip string) {
	// tests if nginx provisioner actually started something on 80
	client := &http.Client{
		Timeout: 10 * time.Second,
	}
	url := fmt.Sprintf("http://%s:80", ip)

	resp, err := client.Get(url)
	if err != nil {
		log.Fatalf("connection error: %v", err)
	} else {
		fmt.Println(ip, "responds")
	}

	defer resp.Body.Close()
}

func main() {
	installer := &releases.ExactVersion{
		Product: product.Terraform,
		Version: version.Must(version.NewVersion("1.0.6")),
	}

	execPath, err := installer.Install(context.Background())
	if err != nil {
		log.Fatalf("error installing Terraform: %s", err)
	}

	workingDir := "for_each/"
	tf, err := tfexec.NewTerraform(workingDir, execPath)
	if err != nil {
		log.Fatalf("error running NewTerraform: %s", err)
	}

	err = tf.Init(context.Background(), tfexec.Upgrade(true))
	if err != nil {
		log.Fatalf("error running Init: %s", err)
	}

	fmt.Println("Applying Terraform changes...")
	err = tf.Apply(context.Background())
	if err != nil {
		log.Fatalf("error running Apply: %s", err)
	}
	fmt.Println("Terraform apply complete")

	stateJSON, err := tf.StatePull(context.Background())
	if err != nil {
		log.Fatalf("error pulling state: %s", err)
	}

	var state TerraformState
	err = json.Unmarshal([]byte(stateJSON), &state)
	if err != nil {
		log.Fatalf("error unmarshaling state JSON: %s", err)
	}

	for _, resource := range state.Resources {
		for _, instance := range resource.Instances {
			attributes := instance["attributes"].(map[string]interface{})
			fmt.Println("instance", attributes["name"], "has ip", attributes["ipv4_address"])
			testNginx(attributes["ipv4_address"].(string))
		}
	}
}
