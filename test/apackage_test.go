package apackage

import (
	"os"
	"testing"
)

func TestAFunct(t *testing.T) {
	err := Afunc(true)
	if err != nil {
		t.Errorf("Should have worked")
	}
}

// See https://pkg.go.dev/sigs.k8s.io/controller-runtime/pkg/envtest
func TestEnvironment(t *testing.T) {
	kbAssets := os.Getenv("KUBEBUILDER_ASSETS")
	if kbAssets == "" {
		t.Errorf("Did not find KUBEBUILDER_ASSETS environment variable set")
	}

}
