package apackage

import "fmt"

// Afunc ...
func Afunc(b bool) error {
	if !b {
		return fmt.Errorf("This is why we can't have nice things")
	}
	return nil
}
