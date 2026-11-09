{{range .}}{"name":{{printf "%q" .Name}},"version":{{printf "%q" .Version}},"license":{{printf "%q" .LicenseName}}}
{{end}}
